import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_shared/content/data/content_media_loader.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/_shared/content/widgets/content_image.dart';
import 'package:tracksu/src/_shared/content/widgets/content_media_scope.dart';
import 'package:tracksu/src/_shared/content/widgets/content_media_settings.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/news/bloc/bloc.dart';
import 'package:tracksu/src/news/domain/news.dart';
import 'package:tracksu/src/news/widgets/article_content.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(context.t.newsTitle),
      actions: <Widget>[
        BlocBuilder<NewsBloc, NewsState>(
          builder: (BuildContext context, NewsState state) =>
              state is NewsArticleState
              ? ShareButton.icon(
                  target: ShareTarget.news(
                    state.article.post.uri,
                    state.article.post.title,
                  ),
                )
              : ShareButton.icon(
                  target: ShareTarget.newsList(context.t.newsTitle),
                ),
        ),
        BlocSelector<NewsBloc, NewsState, bool>(
          selector: (NewsState state) =>
              state is NewsInitialState ||
              state is NewsLoadingState ||
              (state is NewsContentState && state.operation != null),
          builder: (BuildContext context, bool busy) => UiIconButton.standard(
            tooltip: context.t.newsRefresh,
            onPressed: busy
                ? null
                : () => context.read<NewsBloc>().add(
                    const NewsRefreshRequested(),
                  ),
            icon: Icons.refresh,
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          BlocBuilder<NewsBloc, NewsState>(
            builder: (BuildContext context, NewsState state) => switch (state) {
              NewsInitialState() || NewsLoadingState() => SliverToBoxAdapter(
                child: UiPageSkeleton.list(label: context.t.newsLoading),
              ),
              NewsFailureState(:final failure) => SliverToBoxAdapter(
                child: _NewsError(failure),
              ),
              NewsContentState() => SliverMainAxisGroup(
                slivers: <Widget>[
                  if (state.operation == NewsOperation.refresh)
                    SliverToBoxAdapter(
                      child: LinearProgressIndicator(
                        semanticsLabel: context.t.newsLoading,
                      ),
                    ),
                  if (state.failure case final NewsFailureKind failure
                      when state.failedOperation == NewsOperation.refresh)
                    SliverToBoxAdapter(
                      child: _NewsError(
                        failure,
                        keepingContent:
                            state is NewsArticleState ||
                            (state is NewsListState && state.items.isNotEmpty),
                      ),
                    ),
                  if (state is NewsArticleState)
                    NewsArticleContent(
                      key: ValueKey<int>(state.article.post.id),
                      article: state.article,
                    ),
                  if (state is NewsListState) ...<Widget>[
                    if (state.items.isEmpty)
                      SliverToBoxAdapter(
                        child: UiContentState.empty(title: context.t.newsEmpty),
                      ),
                    _NewsList(
                      key: const ValueKey<String>('news-media-list'),
                      items: state.items,
                    ),
                  ],
                  if (state.operation == NewsOperation.loadMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(UiSpace.lg),
                        child: Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: context.t.newsLoading,
                          ),
                        ),
                      ),
                    )
                  else if (state.failure case final NewsFailureKind failure
                      when state.failedOperation == NewsOperation.loadMore)
                    SliverToBoxAdapter(
                      child: _NewsError(
                        failure,
                        keepingContent: true,
                        operation: state.failedOperation,
                      ),
                    )
                  else if (state is NewsListState &&
                      state.cursor != null &&
                      state.failure == null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(UiSpace.lg),
                        child: Center(
                          child: UiButton.secondary(
                            onPressed: state.operation == null
                                ? () => context.read<NewsBloc>().add(
                                    const NewsMoreRequested(),
                                  )
                                : null,
                            label: context.t.newsLoadMore,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            },
          ),
        ],
      ),
    ),
  );
}

final class _NewsError extends StatelessWidget {
  const _NewsError(this.failure, {this.keepingContent = false, this.operation});
  final NewsFailureKind failure;
  final bool keepingContent;
  final NewsOperation? operation;
  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      NewsFailureKind.notFound => context.t.newsNotFound,
      NewsFailureKind.cancelled => context.t.newsCancelled,
      NewsFailureKind.accessDenied => context.t.newsAccessDenied,
      NewsFailureKind.rateLimited => context.t.profileRateLimited,
      NewsFailureKind.connection => context.t.profileConnectionFailed,
      NewsFailureKind.invalidResponse => context.t.newsInvalidResponse,
      NewsFailureKind.unavailable => context.t.newsUnavailable,
    },
    message: keepingContent ? context.t.newsKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () => context.read<NewsBloc>().add(
      operation == NewsOperation.loadMore
          ? const NewsMoreRequested()
          : const NewsRefreshRequested(),
    ),
  );
}

final class _NewsPostTile extends StatefulWidget {
  const _NewsPostTile({required this.post, this.loader});
  final NewsPost post;
  final ContentMediaLoader? loader;
  @override
  State<_NewsPostTile> createState() => _NewsPostTileState();
}

final class _NewsPostTileState extends State<_NewsPostTile> {
  bool _opening = false;
  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await DepsScope.of(context).appRouter
          .openNewsArticle(context, NewsArticleParams(widget.post.id));
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => OsuNewsCard(
    title: widget.post.title,
    authorLabel: widget.post.author,
    dateLabel: DateFormat.yMMMd(context.t.localeName)
        .format(widget.post.publishedAt.toLocal()),
    coverContent:
        widget.post.coverUri != null &&
            DepsScope.of(context).contentMediaController.allowed
        ? widget.loader == null
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ColoredBox(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                )
              : ContentImageView.preview(
                  image: ContentImage(
                    widget.post.id,
                    uri: widget.post.coverUri,
                    alt: widget.post.title,
                  ),
                  loader: widget.loader!,
                )
        : null,
    preview: widget.post.preview?.isEmpty ?? true ? null : widget.post.preview,
    onTap: _opening ? null : _open,
  );
}

final class _NewsList extends StatelessWidget {
  const _NewsList({required this.items, super.key});
  final List<NewsPost> items;

  @override
  Widget build(BuildContext context) => ContentMediaScope(
    permission: DepsScope.of(context).contentMediaController,
    builder: (BuildContext context, ContentMediaLoader? loader) =>
        SliverPadding(
          padding: const EdgeInsets.all(UiSpace.lg),
          sliver: SliverMainAxisGroup(
            slivers: <Widget>[
              if (DepsScope.of(context).contentMediaController.choice == null &&
                  items.any((NewsPost post) => post.coverUri != null))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: UiSpace.md),
                    child: UiSurface.inset(
                      child: ContentMediaSettings(
                        controller: DepsScope.of(context)
                            .contentMediaController,
                      ),
                    ),
                  ),
                ),
              SliverList.builder(
                key: const ValueKey<String>('news-list'),
                itemCount: items.length,
                findChildIndexCallback: (Key key) {
                  final int index = items.indexWhere(
                    (NewsPost post) => ValueKey<int>(post.id) == key,
                  );
                  return index < 0 ? null : index;
                },
                itemBuilder: (BuildContext context, int index) => Padding(
                  key: ValueKey<int>(items[index].id),
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : UiSpace.md,
                  ),
                  child: _NewsPostTile(post: items[index], loader: loader),
                ),
              ),
            ],
          ),
        ),
  );
}
