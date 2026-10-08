part of 'bloc.dart';

sealed class ChangelogEvent {
  const ChangelogEvent();
}

final class ChangelogStarted extends ChangelogEvent {
  const ChangelogStarted();
}

/// Null selects all streams.
final class ChangelogStreamSelected extends ChangelogEvent {
  const ChangelogStreamSelected(this.value);
  final String? value;
}

final class ChangelogRefreshRequested extends ChangelogEvent {
  const ChangelogRefreshRequested();
}

final class ChangelogMoreRequested extends ChangelogEvent {
  const ChangelogMoreRequested();
}
