part of 'bloc.dart';

sealed class ForumTopicEvent {
  const ForumTopicEvent();
}

final class ForumTopicStarted extends ForumTopicEvent {
  const ForumTopicStarted();
}

/// Reloads from the first post.
final class ForumTopicRefreshRequested extends ForumTopicEvent {
  const ForumTopicRefreshRequested();
}

final class ForumTopicMoreRequested extends ForumTopicEvent {
  const ForumTopicMoreRequested();
}
