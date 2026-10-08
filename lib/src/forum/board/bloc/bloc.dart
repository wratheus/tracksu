import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/forum/data/forum_repository.dart';
import 'package:tracksu/src/forum/domain/forum.dart';

part 'event.dart';
part 'state.dart';

/// One forum: header, subforums and pinned topics, then its topics by last
/// post with cursor paging. The first screen is cached for the session.
final class ForumBoardBloc extends Bloc<ForumBoardEvent, ForumBoardState> {
  ForumBoardBloc({
    required this.forumId,
    required this._repository,
    required this._cache,
  }) : super(const ForumBoardState()) {
    on<ForumBoardEvent>(_onLoad, transformer: sequential());
  }

  final int forumId;
  final ForumRepository _repository;
  final PageCache _cache;
  static const Duration _minPageInterval = Duration(seconds: 1);
  DateTime _lastPage = DateTime.fromMillisecondsSinceEpoch(0);

  Object get _cacheKey => ('forum-board', forumId);

  Future<void> _onLoad(
    ForumBoardEvent event,
    Emitter<ForumBoardState> emit,
  ) async {
    final ForumBoardOperation operation;
    switch (event) {
      case ForumBoardStarted():
        if (state.board != null || state.busy) return;
        if (_cache.read<ForumBoardState>(_cacheKey) case final cached?) {
          emit(cached);
          return;
        }
        operation = ForumBoardOperation.refresh;
      case ForumBoardRefreshRequested():
        if (state.busy) return;
        operation = ForumBoardOperation.refresh;
      case ForumBoardMoreRequested():
        if (state.busy ||
            state.cursor == null ||
            state.failedOperation == ForumBoardOperation.refresh) {
          return;
        }
        operation = ForumBoardOperation.loadMore;
        // Paging follows the reader, never faster than a page a second.
        final Duration wait =
            _minPageInterval - DateTime.now().difference(_lastPage);
        if (wait > Duration.zero) await Future<void>.delayed(wait);
        if (isClosed) return;
        _lastPage = DateTime.now();
    }
    final ForumBoardState before = state;
    emit(before.copyWith(operation: operation));
    final int revision = _cache.revision;
    try {
      if (operation == ForumBoardOperation.refresh) {
        // Both requests run together; the first failure wins.
        final List<Object> results = await Future.wait<Object>(<Future<Object>>[
          _repository.board(forumId),
          _repository.topics(forumId),
        ]);
        final ForumBoard loadedBoard = results[0] as ForumBoard;
        final ForumTopicsPage loadedPage = results[1] as ForumTopicsPage;
        if (isClosed) return;
        final ForumBoardState loaded = ForumBoardState(
          board: loadedBoard,
          topics: _withoutPinned(loadedPage.topics, loadedBoard.pinned),
          cursor: loadedPage.cursor,
        );
        _cache.write(_cacheKey, loaded, revision: revision);
        emit(loaded);
      } else {
        final ForumTopicsPage page = await _repository.topics(
          forumId,
          cursor: before.cursor,
        );
        if (isClosed) return;
        final Map<int, ForumTopic> unique = <int, ForumTopic>{
          for (final ForumTopic topic in before.topics ?? const <ForumTopic>[])
            topic.id: topic,
          for (final ForumTopic topic in _withoutPinned(
            page.topics,
            before.board?.pinned ?? const <ForumTopic>[],
          ))
            topic.id: topic,
        };
        emit(
          ForumBoardState(
            board: before.board,
            topics: unique.values.toList(growable: false),
            cursor: page.cursor,
          ),
        );
      }
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        ForumBoardState(
          board: before.board,
          topics: before.topics,
          cursor: before.cursor,
          failure: error is ForumFailure
              ? error.kind
              : ForumFailureKind.unavailable,
          failedOperation: operation,
        ),
      );
    }
  }

  /// The topic list repeats pinned topics in date order; they stay on top.
  static List<ForumTopic> _withoutPinned(
    List<ForumTopic> topics,
    List<ForumTopic> pinned,
  ) {
    final Set<int> top = <int>{for (final ForumTopic topic in pinned) topic.id};
    return <ForumTopic>[
      for (final ForumTopic topic in topics)
        if (!topic.pinned && !top.contains(topic.id)) topic,
    ];
  }

  @override
  Future<void> close() {
    _repository.cancelPending();
    return super.close();
  }
}
