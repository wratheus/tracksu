part of 'bloc.dart';

sealed class ProfileScoresEvent {
  const ProfileScoresEvent();
}

final class ProfileScoresStarted extends ProfileScoresEvent {
  const ProfileScoresStarted();
}

final class ProfileScoresTypeSelected extends ProfileScoresEvent {
  const ProfileScoresTypeSelected(this.value);
  final ProfileScoresType value;
}

final class ProfileScoresRefreshRequested extends ProfileScoresEvent {
  const ProfileScoresRefreshRequested();
}

final class ProfileScoresMoreRequested extends ProfileScoresEvent {
  const ProfileScoresMoreRequested();
}
