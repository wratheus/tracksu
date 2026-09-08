part of 'bloc.dart';

@immutable
sealed class ProfileState {
  const ProfileState({required this.ruleset});
  final ProfileRuleset ruleset;
}

final class ProfileInitialState extends ProfileState {
  const ProfileInitialState({super.ruleset = ProfileRuleset.osu});
}

final class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState({required super.ruleset});
}

final class ProfileLoadedState extends ProfileState {
  const ProfileLoadedState({
    required super.ruleset,
    required this.profile,
    this.isRefreshing = false,
    this.refreshFailure,
    this.requestedRuleset,
    this.failedRuleset,
  });
  final Profile profile;
  final bool isRefreshing;
  final ProfileFailureKind? refreshFailure;

  /// ruleset still describes the visible data until the requested mode loads.
  final ProfileRuleset? requestedRuleset;
  final ProfileRuleset? failedRuleset;
  bool get isBusy => isRefreshing || requestedRuleset != null;
}

final class ProfileFailureState extends ProfileState {
  const ProfileFailureState({required super.ruleset, required this.failure});
  final ProfileFailureKind failure;
}
