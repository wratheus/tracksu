part of 'bloc.dart';

@immutable
sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileLookupRequested extends ProfileEvent {
  const ProfileLookupRequested(this.user);
  final ProfileUserReference user;
}

final class CurrentProfileLoadRequested extends ProfileEvent {
  const CurrentProfileLoadRequested();
}

final class ProfileRulesetSelected extends ProfileEvent {
  const ProfileRulesetSelected(this.value);
  final ProfileRuleset value;
}

final class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}
