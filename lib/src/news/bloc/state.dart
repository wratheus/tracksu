part of 'bloc.dart';

sealed class NewsState {
  const NewsState();
}

final class NewsInitialState extends NewsState {
  const NewsInitialState();
}

final class NewsLoadingState extends NewsState {
  const NewsLoadingState();
}

final class NewsFailureState extends NewsState {
  const NewsFailureState(this.failure);
  final NewsFailureKind failure;
}

enum NewsOperation { refresh, loadMore }

sealed class NewsContentState extends NewsState {
  const NewsContentState({this.operation, this.failure, this.failedOperation});
  final NewsOperation? operation;
  final NewsFailureKind? failure;
  final NewsOperation? failedOperation;
  NewsContentState withActivity({
    NewsOperation? operation,
    NewsFailureKind? failure,
    NewsOperation? failedOperation,
  });
}

final class NewsListState extends NewsContentState {
  NewsListState({
    required List<NewsPost> items,
    required this.cursor,
    super.operation,
    super.failure,
    super.failedOperation,
  }) : items = List<NewsPost>.unmodifiable(items);
  final List<NewsPost> items;
  final String? cursor;
  @override
  NewsListState withActivity({
    NewsOperation? operation,
    NewsFailureKind? failure,
    NewsOperation? failedOperation,
  }) => NewsListState(
    items: items,
    cursor: cursor,
    operation: operation,
    failure: failure,
    failedOperation: failedOperation,
  );
}

final class NewsArticleState extends NewsContentState {
  const NewsArticleState(
    this.article, {
    super.operation,
    super.failure,
    super.failedOperation,
  });
  final NewsArticle article;
  @override
  NewsArticleState withActivity({
    NewsOperation? operation,
    NewsFailureKind? failure,
    NewsOperation? failedOperation,
  }) => NewsArticleState(
    article,
    operation: operation,
    failure: failure,
    failedOperation: failedOperation,
  );
}
