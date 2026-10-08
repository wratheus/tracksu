part of 'bloc.dart';

sealed class ForumBoardEvent {
  const ForumBoardEvent();
}

final class ForumBoardStarted extends ForumBoardEvent {
  const ForumBoardStarted();
}

final class ForumBoardRefreshRequested extends ForumBoardEvent {
  const ForumBoardRefreshRequested();
}

final class ForumBoardMoreRequested extends ForumBoardEvent {
  const ForumBoardMoreRequested();
}
