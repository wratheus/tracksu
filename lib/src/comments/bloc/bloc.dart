import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';
import 'package:tracksu/src/comments/domain/comment.dart';

sealed class CommentsEvent {
  const CommentsEvent();
}

final class CommentsStarted extends CommentsEvent {
  const CommentsStarted();
}

final class CommentsSortChanged extends CommentsEvent {
  const CommentsSortChanged(this.sort);
  final CommentSort sort;
}

final class CommentsRefreshRequested extends CommentsEvent {
  const CommentsRefreshRequested();
}

final class CommentsMoreRequested extends CommentsEvent {
  const CommentsMoreRequested();
}

/// Loads (more) replies of one comment.
final class CommentsRepliesRequested extends CommentsEvent {
  const CommentsRepliesRequested(this.parentId);
  final int parentId;
}

enum CommentsOperation { refresh, loadMore }

/// [roots] is null until the first page of the current sort arrives.
/// Replies live in [children] by parent id, in server order.
@immutable
final class CommentsState {
  CommentsState({
    required this.sort,
    this.roots,
    List<Comment> pinned = const <Comment>[],
    Map<int, List<Comment>> children = const <int, List<Comment>>{},
    Map<int, CommentAuthor> users = const <int, CommentAuthor>{},
    Map<int, CommentCursor> replyCursors = const <int, CommentCursor>{},
    Set<int> repliesDone = const <int>{},
    Set<int> loadingReplies = const <int>{},
    this.total,
    this.cursor,
    this.hasMore = false,
    this.operation,
    this.failure,
    this.failedOperation,
    this.started = false,
  }) : pinned = List<Comment>.unmodifiable(pinned),
       children = Map<int, List<Comment>>.unmodifiable(children),
       users = Map<int, CommentAuthor>.unmodifiable(users),
       replyCursors = Map<int, CommentCursor>.unmodifiable(replyCursors),
       repliesDone = Set<int>.unmodifiable(repliesDone),
       loadingReplies = Set<int>.unmodifiable(loadingReplies);

  final CommentSort sort;
  final List<Comment>? roots;
  final List<Comment> pinned;
  final Map<int, List<Comment>> children;
  final Map<int, CommentAuthor> users;

  /// Next page of a parent's replies once its first page was requested.
  final Map<int, CommentCursor> replyCursors;

  /// Parents whose replies are fully loaded.
  final Set<int> repliesDone;
  final Set<int> loadingReplies;
  final int? total;
  final CommentCursor? cursor;
  final bool hasMore;
  final CommentsOperation? operation;
  final CommentsFailureKind? failure;
  final CommentsOperation? failedOperation;
  final bool started;

  bool get busy => operation != null;

  /// More replies exist than are loaded for [comment].
  bool canLoadReplies(Comment comment) =>
      !repliesDone.contains(comment.id) &&
      (children[comment.id]?.length ?? 0) < comment.repliesCount;

  CommentsState copyWith({
    List<Comment>? roots,
    List<Comment>? pinned,
    Map<int, List<Comment>>? children,
    Map<int, CommentAuthor>? users,
    Map<int, CommentCursor>? replyCursors,
    Set<int>? repliesDone,
    Set<int>? loadingReplies,
  }) => CommentsState(
    sort: sort,
    roots: roots ?? this.roots,
    pinned: pinned ?? this.pinned,
    children: children ?? this.children,
    users: users ?? this.users,
    replyCursors: replyCursors ?? this.replyCursors,
    repliesDone: repliesDone ?? this.repliesDone,
    loadingReplies: loadingReplies ?? this.loadingReplies,
    total: total,
    cursor: cursor,
    hasMore: hasMore,
    operation: operation,
    failure: failure,
    failedOperation: failedOperation,
    started: started,
  );
}

/// Latest sort wins: pages and replies of an older sort/refresh are dropped.
/// Top-level paging, refresh and per-comment replies never duplicate rows.
final class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc({
    required this._repository,
    required this._target,
  }) : super(CommentsState(sort: CommentSort.newest)) {
    on<CommentsEvent>(_onEvent, transformer: concurrent());
  }

  final CommentsRepository _repository;
  final CommentTarget _target;
  int _generation = 0;

  Future<void> _onEvent(
    CommentsEvent event,
    Emitter<CommentsState> emit,
  ) async {
    switch (event) {
      case CommentsStarted():
        if (state.started) return;
        await _page(emit, sort: state.sort, more: false);
      case CommentsSortChanged(:final CommentSort sort):
        if (state.started && sort == state.sort) return;
        await _page(emit, sort: sort, more: false);
      case CommentsRefreshRequested():
        if (state.busy) return;
        await _page(emit, sort: state.sort, more: false);
      case CommentsMoreRequested():
        if (state.busy ||
            state.roots == null ||
            !state.hasMore ||
            state.failedOperation == CommentsOperation.refresh) {
          return;
        }
        await _page(emit, sort: state.sort, more: true);
      case CommentsRepliesRequested(:final int parentId):
        await _replies(emit, parentId);
    }
  }

  Future<void> _page(
    Emitter<CommentsState> emit, {
    required CommentSort sort,
    required bool more,
  }) async {
    final int generation = more ? _generation : ++_generation;
    final CommentsState base = state;
    final bool sameSort = sort == base.sort;
    final CommentsOperation operation = more
        ? CommentsOperation.loadMore
        : CommentsOperation.refresh;
    emit(
      CommentsState(
        sort: sort,
        // A new sort starts empty; a refresh keeps rows until it lands.
        roots: sameSort ? base.roots : null,
        pinned: sameSort ? base.pinned : const <Comment>[],
        children: sameSort ? base.children : const <int, List<Comment>>{},
        users: base.users,
        replyCursors: sameSort ? base.replyCursors : const {},
        repliesDone: sameSort ? base.repliesDone : const <int>{},
        total: base.total,
        cursor: base.cursor,
        hasMore: base.hasMore,
        operation: operation,
        started: true,
      ),
    );
    try {
      final CommentsPage page = await _repository.load(
        _target,
        sort: sort,
        cursor: more ? base.cursor : null,
      );
      if (generation != _generation || isClosed) return;
      final Set<int> pinnedIds = <int>{
        for (final Comment c in more ? state.pinned : page.pinned) c.id,
      };
      final List<Comment> roots = _merge(
        more ? state.roots ?? const <Comment>[] : const <Comment>[],
        page.comments.where((Comment c) => !pinnedIds.contains(c.id)),
      );
      if (more && page.hasMore && roots.length == (state.roots?.length ?? 0)) {
        throw const CommentsFailure(CommentsFailureKind.invalidResponse);
      }
      emit(
        CommentsState(
          sort: sort,
          roots: roots,
          pinned: more ? state.pinned : page.pinned,
          children: _withChildren(
            more ? state.children : const <int, List<Comment>>{},
            page.included,
          ),
          users: <int, CommentAuthor>{...state.users, ...page.users},
          replyCursors: more ? state.replyCursors : const {},
          repliesDone: more ? state.repliesDone : const <int>{},
          total: page.total ?? state.total,
          cursor: page.hasMore ? page.cursor : null,
          hasMore: page.hasMore && page.cursor != null,
          started: true,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _generation || isClosed) return;
      final CommentsFailureKind kind = error is CommentsFailure
          ? error.kind
          : CommentsFailureKind.unavailable;
      addError(CommentsFailure(kind), stackTrace);
      emit(
        CommentsState(
          sort: sort,
          roots: state.roots,
          pinned: state.pinned,
          children: state.children,
          users: state.users,
          replyCursors: state.replyCursors,
          repliesDone: state.repliesDone,
          total: state.total,
          cursor: state.cursor,
          hasMore: state.hasMore,
          failure: kind,
          failedOperation: operation,
          started: true,
        ),
      );
    }
  }

  Future<void> _replies(Emitter<CommentsState> emit, int parentId) async {
    if (state.loadingReplies.contains(parentId) ||
        state.repliesDone.contains(parentId)) {
      return;
    }
    final int generation = _generation;
    emit(state.copyWith(loadingReplies: {...state.loadingReplies, parentId}));
    try {
      final CommentsPage page = await _repository.load(
        _target,
        sort: state.sort,
        parentId: parentId,
        cursor: state.replyCursors[parentId],
      );
      if (generation != _generation || isClosed) return;
      final Map<int, List<Comment>> children = _withChildren(
        _withChildren(state.children, page.comments),
        page.included,
      );
      final bool done = !page.hasMore || page.cursor == null;
      emit(
        state.copyWith(
          children: children,
          users: <int, CommentAuthor>{...state.users, ...page.users},
          replyCursors: <int, CommentCursor>{
            ...state.replyCursors,
            if (!done) parentId: page.cursor!,
          }..removeWhere((int key, _) => done && key == parentId),
          repliesDone: <int>{...state.repliesDone, if (done) parentId},
          loadingReplies: <int>{...state.loadingReplies}..remove(parentId),
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _generation || isClosed) return;
      addError(
        error is CommentsFailure
            ? error
            : const CommentsFailure(CommentsFailureKind.unavailable),
        stackTrace,
      );
      emit(
        state.copyWith(
          loadingReplies: <int>{...state.loadingReplies}..remove(parentId),
        ),
      );
    }
  }

  static List<Comment> _merge(
    Iterable<Comment> existing,
    Iterable<Comment> incoming,
  ) {
    final Map<int, Comment> byId = <int, Comment>{
      for (final Comment c in existing) c.id: c,
    };
    for (final Comment c in incoming) {
      byId.putIfAbsent(c.id, () => c);
    }
    return byId.values.toList(growable: false);
  }

  static Map<int, List<Comment>> _withChildren(
    Map<int, List<Comment>> existing,
    Iterable<Comment> replies,
  ) {
    final Map<int, List<Comment>> result = <int, List<Comment>>{
      for (final MapEntry<int, List<Comment>> e in existing.entries)
        e.key: e.value,
    };
    for (final Comment reply in replies) {
      final int? parent = reply.parentId;
      if (parent == null) continue;
      result[parent] = _merge(result[parent] ?? const <Comment>[], <Comment>[
        reply,
      ]);
    }
    return result;
  }
}
