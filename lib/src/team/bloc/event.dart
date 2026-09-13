part of 'bloc.dart';

sealed class TeamEvent {
  const TeamEvent();
}

final class TeamStarted extends TeamEvent {
  const TeamStarted();
}

final class TeamRefreshRequested extends TeamEvent {
  const TeamRefreshRequested();
}

final class TeamModeSelected extends TeamEvent {
  const TeamModeSelected(this.mode);
  final ProfileRuleset mode;
}
