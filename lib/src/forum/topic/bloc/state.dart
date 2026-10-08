part of 'bloc.dart';

enum ForumTopicOperation { refresh, loadMore }

/// [topic] and [posts] null until the first page; a failure keeps the posts
/// on screen and records which [failedOperation] to retry.
final class ForumTopicState {
  const ForumTopicState({
    this.topic,
    this.posts,
    this.authors = const <int, ForumAuthor>{},
    this.cursor,
    this.operation,
    this.failure,
    this.failedOperation,
  });
  final ForumTopic? topic;
  final List<ForumPost>? posts;
  final Map<int, ForumAuthor> authors;
  final String? cursor;
  final ForumTopicOperation? operation;
  final ForumFailureKind? failure;
  final ForumTopicOperation? failedOperation;

  bool get busy => operation != null;

  ForumTopicState copyWith({ForumTopicOperation? operation}) =>
      ForumTopicState(
        topic: topic,
        posts: posts,
        authors: authors,
        cursor: cursor,
        operation: operation,
      );
}
