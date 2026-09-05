import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/news/bloc/bloc.dart';
import 'package:tracksu/src/news/domain/news.dart';
import 'package:tracksu/src/news/widgets/article_content.dart';

final class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.newsTitle),
      actions: <Widget>[
        BlocSelector<NewsBloc, NewsState, bool>(
          selector: (NewsState state) =>
              state is NewsInitialState ||
              state is NewsLoadingState ||
              (state is NewsContentState && state.operation != null),
          builder: (BuildContext context, bool busy) => IconButton(
            tooltip: context.t.newsRefresh,
            onPressed: busy
                ? null
                : () => context.read<NewsBloc>().add(
                    const NewsRefreshRequested(),
                  ),
            icon: const Icon(Icons.refresh),
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
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(context.t.newsEmpty),
                        ),
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
                          child: TextButton(
                            onPressed: state.operation == null
                                ? () => context.read<NewsBloc>().add(
                                    const NewsMoreRequested(),
                                  )
                                : null,
                            child: Text(context.t.newsLoadMore),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      spacing: 10,
      children: <Widget>[
        const CircularProgressIndicator(),
        Text(context.t.newsLoading),
      ],
    ),
  );
}

final class _NewsError extends StatelessWidget {
  const _NewsError(this.failure, {this.keepingContent = false, this.operation});
  final NewsFailureKind failure;
  final bool keepingContent;
  final NewsOperation? operation;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      spacing: 10,
      children: <Widget>[
        if (keepingContent) Text(context.t.newsKeepingContent),
        Text(switch (failure) {
          NewsFailureKind.notFound => context.t.newsNotFound,
          NewsFailureKind.cancelled => context.t.newsCancelled,
          NewsFailureKind.accessDenied => context.t.newsAccessDenied,
          NewsFailureKind.rateLimited => context.t.profileRateLimited,
          NewsFailureKind.connection => context.t.profileConnectionFailed,
          NewsFailureKind.invalidResponse => context.t.newsInvalidResponse,
          NewsFailureKind.unavailable => context.t.newsUnavailable,
        }, textAlign: TextAlign.center),
        TextButton(
          onPressed: () => context.read<NewsBloc>().add(
            operation == NewsOperation.loadMore
                ? const NewsMoreRequested()
                : const NewsRefreshRequested(),
          ),
          child: Text(context.t.retry),
        ),
      ],
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
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    child: InkWell(
      onTap: _opening ? null : _open,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: <Widget>[
            NewsPostHeading(post: widget.post),
            if (widget.post.preview case final String preview
                when preview.isNotEmpty)
              Text(preview),
          ],
        ),
      ),
    ),
  );
}
