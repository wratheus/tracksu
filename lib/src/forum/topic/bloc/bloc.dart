import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/forum/data/forum_repository.dart';
import 'package:tracksu/src/forum/domain/forum.dart';

part 'event.dart';
part 'state.dart';

/// One topic: posts oldest first, 20 per page, plus their authors (one
/// `/users` request per page for ids not seen yet). Missing authors are not
/// an error: posts show without a name.
final class ForumTopicBloc extends Bloc<ForumTopicEvent, ForumTopicState> {
  ForumTopicBloc({required this.topicId, required this._repository})
    : super(const ForumTopicState()) {
    on<ForumTopicEvent>(_onLoad, transformer: sequential());
  }

  final int topicId;
  final ForumRepository _repository;
  static const Duration _minPageInterval = Duration(seconds: 1);
  DateTime _lastPage = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _onLoad(
    ForumTopicEvent event,
    Emitter<ForumTopicState> emit,
  ) async {
    final ForumTopicOperation operation;
    switch (event) {
      case ForumTopicStarted():
        if (state.topic != null || state.busy) return;
        operation = ForumTopicOperation.refresh;
      case ForumTopicRefreshRequested():
        if (state.busy) return;
        operation = ForumTopicOperation.refresh;
      case ForumTopicMoreRequested():
        if (state.busy ||
            state.cursor == null ||
            state.failedOperation == ForumTopicOperation.refresh) {
          return;
        }
        operation = ForumTopicOperation.loadMore;
        final Duration wait =
            _minPageInterval - DateTime.now().difference(_lastPage);
        if (wait > Duration.zero) await Future<void>.delayed(wait);
        if (isClosed) return;
        _lastPage = DateTime.now();
    }
    final ForumTopicState before = state;
    emit(before.copyWith(operation: operation));
    try {
      final ForumPostsPage page = await _repository.posts(
        topicId,
        cursor: operation == ForumTopicOperation.loadMore
            ? before.cursor
            : null,
      );
      if (isClosed) return;
      final Map<int, ForumPost> posts = <int, ForumPost>{
        if (operation == ForumTopicOperation.loadMore)
          for (final ForumPost post in before.posts ?? const <ForumPost>[])
            post.id: post,
        for (final ForumPost post in page.posts) post.id: post,
      };
      final Map<int, ForumAuthor> authors = <int, ForumAuthor>{
        ...before.authors,
      };
      final Set<int> missing = <int>{
        for (final ForumPost post in page.posts)
          if (post.userId > 0 && !authors.containsKey(post.userId)) post.userId,
      };
      if (missing.isNotEmpty) {
        try {
          for (final ForumAuthor author in await _repository.authors(missing)) {
            authors[author.id] = author;
          }
        } on ForumFailure {
          // Names are optional; the posts are already here.
        }
        if (isClosed) return;
      }
      emit(
        ForumTopicState(
          topic: page.topic,
          posts: posts.values.toList(growable: false),
          authors: authors,
          cursor: page.cursor,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        ForumTopicState(
          topic: before.topic,
          posts: before.posts,
          authors: before.authors,
          cursor: before.cursor,
          failure: error is ForumFailure
              ? error.kind
              : ForumFailureKind.unavailable,
          failedOperation: operation,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _repository.cancelPending();
    return super.close();
  }
}
