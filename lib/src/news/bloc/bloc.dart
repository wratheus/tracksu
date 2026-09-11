import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/news/domain/news.dart';
part 'event.dart';
part 'state.dart';

/// Each list/article route owns an independent instance. No shared UI state.
final class NewsBloc extends Bloc<NewsEvent, NewsState> {
  factory NewsBloc({
    required NewsRepository repository,
    required PageCache cache,
    NewsArticleParams? params,
  }) => NewsBloc._(repository, cache, params);
  NewsBloc._(this._repository, this._cache, this._params)
    : super(const NewsInitialState()) {
    // A synchronous busy-state emission guards all events before the first await.
    on<NewsEvent>(_onEvent, transformer: droppable());
  }
  final NewsRepository _repository;
  final PageCache _cache;
  final NewsArticleParams? _params;
  final Set<String> _usedCursors = <String>{};

  Future<void> _onEvent(NewsEvent event, Emitter<NewsState> emit) async {
    final NewsState current = state;
    if (current is NewsLoadingState ||
        (current is NewsContentState && current.operation != null)) {
      return;
    }
    NewsContentState? previous;
    var operation = NewsOperation.refresh;
    String? cursor;
    switch (event) {
      case NewsStarted():
        if (current is! NewsInitialState) return;
      case NewsRefreshRequested():
        if (current is NewsContentState) previous = current;
      case NewsMoreRequested():
        if (current is! NewsListState ||
            current.cursor == null ||
            current.failedOperation == NewsOperation.refresh) {
          return;
        }
        previous = current;
        cursor = current.cursor;
        operation = NewsOperation.loadMore;
    }
    final Object cacheKey = ('news', _params?.id);
    final int cacheRevision = _cache.revision;
    if (previous == null) {
      if (_params != null) {
        final NewsArticle? cached = _cache.read<NewsArticle>(cacheKey);
        if (cached != null) previous = NewsArticleState(cached);
      } else {
        final NewsPage? cached = _cache.read<NewsPage>(cacheKey);
        if (cached != null) {
          previous = NewsListState(items: cached.items, cursor: cached.cursor);
        }
      }
    }
    emit(
      previous?.withActivity(operation: operation) ?? const NewsLoadingState(),
    );
    try {
      final NewsContentState result;
      if (_params case final NewsArticleParams params) {
        final NewsArticle article = await _repository.article(params);
        if (isClosed || emit.isDone) return;
        _cache.write(cacheKey, article, revision: cacheRevision);
        result = NewsArticleState(article);
      } else {
        final NewsPage page = await _repository.list(cursor: cursor);
        if (isClosed || emit.isDone) return;
        if (operation == NewsOperation.refresh) {
          _cache.write(cacheKey, page, revision: cacheRevision);
        }
        if (operation == NewsOperation.loadMore &&
            page.cursor != null &&
            (page.cursor == cursor || _usedCursors.contains(page.cursor))) {
          throw const NewsFailure(NewsFailureKind.invalidResponse);
        }
        final Map<int, NewsPost> unique = <int, NewsPost>{
          if (operation == NewsOperation.loadMore && previous is NewsListState)
            for (final NewsPost item in previous.items) item.id: item,
          for (final NewsPost item in page.items) item.id: item,
        };
        if (operation == NewsOperation.loadMore &&
            previous is NewsListState &&
            page.cursor != null &&
            unique.length == previous.items.length) {
          throw const NewsFailure(NewsFailureKind.invalidResponse);
        }
        result = NewsListState(
          items: unique.values.toList(growable: false),
          cursor: page.cursor,
        );
        if (operation == NewsOperation.refresh) _usedCursors.clear();
        if (cursor != null) _usedCursors.add(cursor);
      }
      if (isClosed || emit.isDone) return;
      emit(result);
    } on Object catch (error, stackTrace) {
      if (isClosed || emit.isDone) return;
      final NewsFailureKind failure = error is NewsFailure
          ? error.kind
          : NewsFailureKind.unavailable;
      addError(NewsFailure(failure), stackTrace);
      emit(
        previous?.withActivity(failure: failure, failedOperation: operation) ??
            NewsFailureState(failure),
      );
    }
  }

  @override
  Future<void> close() {
    _repository.cancelPending();
    return super.close();
  }
}
