part of 'bloc.dart';

enum ForumBoardOperation { refresh, loadMore }

/// [board] and [topics] null until the first load; a failure keeps what is
/// visible and records which [failedOperation] to retry.
final class ForumBoardState {
  const ForumBoardState({
    this.board,
    this.topics,
    this.cursor,
    this.operation,
    this.failure,
    this.failedOperation,
  });
  final ForumBoard? board;
  final List<ForumTopic>? topics;
  final String? cursor;
  final ForumBoardOperation? operation;
  final ForumFailureKind? failure;
  final ForumBoardOperation? failedOperation;

  bool get busy => operation != null;

  ForumBoardState copyWith({ForumBoardOperation? operation}) => ForumBoardState(
    board: board,
    topics: topics,
    cursor: cursor,
    operation: operation,
  );
}
