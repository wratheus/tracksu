part of 'bloc.dart';

sealed class TeamState {
  const TeamState();
}

final class TeamInitial extends TeamState {
  const TeamInitial();
}

final class TeamLoading extends TeamState {
  const TeamLoading(this.mode);
  final ProfileRuleset? mode;
}

final class TeamLoaded extends TeamState {
  const TeamLoaded(
    this.data, {
    this.refreshing = false,
    this.failure,
    this.requestedMode,
  });
  final TeamDetails data;
  final bool refreshing;
  final TeamFailureKind? failure;
  final ProfileRuleset? requestedMode;
}

final class TeamError extends TeamState {
  const TeamError(this.failure, this.mode);
  final TeamFailureKind failure;
  final ProfileRuleset? mode;
}
