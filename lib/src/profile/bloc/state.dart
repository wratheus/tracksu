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
  });
  final Profile profile;
  final bool isRefreshing;
  final ProfileFailureKind? refreshFailure;
}

final class ProfileFailureState extends ProfileState {
  const ProfileFailureState({required super.ruleset, required this.failure});
  final ProfileFailureKind failure;
}
