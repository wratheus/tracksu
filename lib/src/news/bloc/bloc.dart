import 'package:bloc/bloc.dart';
import 'package:tracksu/src/news/domain/news.dart';
part 'event.dart';
part 'state.dart';

/// Each list/article route owns an independent instance. No shared UI state.
final class NewsBloc extends Bloc<NewsEvent, NewsState> {
  factory NewsBloc({
    required NewsRepository repository,
    NewsArticleParams? params,
  }) => NewsBloc._(repository, params);
  NewsBloc._(this._repository, this._params) : super(const NewsInitialState()) {
    // A synchronous busy-state emission guards all events before the first await.
    on<NewsEvent>(_onEvent);
  }
  final NewsRepository _repository;
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
    emit(
      previous?.withActivity(operation: operation) ?? const NewsLoadingState(),
    );
    try {
      final NewsContentState result;
      if (_params case final NewsArticleParams params) {
        result = NewsArticleState(await _repository.article(params));
      } else {
        final NewsPage page = await _repository.list(cursor: cursor);
        if (operation == NewsOperation.loadMore &&
            page.cursor != null &&
            _usedCursors.contains(page.cursor)) {
          throw const NewsFailure(NewsFailureKind.invalidResponse);
        }
        final Map<int, NewsPost> unique = <int, NewsPost>{
          if (operation == NewsOperation.loadMore && previous is NewsListState)
            for (final NewsPost item in previous.items) item.id: item,
          for (final NewsPost item in page.items) item.id: item,
        };
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
