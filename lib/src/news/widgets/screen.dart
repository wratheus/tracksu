import 'package:flutter/material.dart';
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
              NewsInitialState() || NewsLoadingState() =>
                const SliverToBoxAdapter(child: _NewsProgress()),
              NewsFailureState(:final failure) => SliverToBoxAdapter(
                child: _NewsError(failure),
              ),
              NewsContentState() => SliverMainAxisGroup(
                slivers: <Widget>[
                  if (state.operation == NewsOperation.refresh)
                    const SliverToBoxAdapter(child: _NewsProgress()),
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
                    SliverList.builder(
                      key: const ValueKey<String>('news-list'),
                      itemCount: state.items.length,
                      itemBuilder: (_, int index) => _NewsPostTile(
                        key: ValueKey<int>(state.items[index].id),
                        post: state.items[index],
                      ),
                    ),
                  ],
                  if (state.operation == NewsOperation.loadMore)
                    const SliverToBoxAdapter(child: _NewsProgress())
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
                        padding: const EdgeInsets.all(20),
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

final class _NewsProgress extends StatelessWidget {
  const _NewsProgress();
  @override
  Widget build(BuildContext context) =>
      UiContentState.loading(title: context.t.newsLoading);
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
  const _NewsPostTile({required this.post, super.key});
  final NewsPost post;
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
    dateLabel: widget.post.publishedAt.toLocal().toString(),
    preview: widget.post.preview?.isEmpty ?? true ? null : widget.post.preview,
    onTap: _opening ? null : _open,
  );
}
