part of 'bloc.dart';

sealed class ForumIndexEvent {
  const ForumIndexEvent();
}

/// Shows the cached sections or loads them once.
final class ForumIndexStarted extends ForumIndexEvent {
  const ForumIndexStarted();
}

final class ForumIndexRefreshRequested extends ForumIndexEvent {
  const ForumIndexRefreshRequested();
}
