part of 'bloc.dart';

sealed class ProfileBeatmapsEvent {
  const ProfileBeatmapsEvent();
}

final class ProfileBeatmapsStarted extends ProfileBeatmapsEvent {
  const ProfileBeatmapsStarted();
}

final class ProfileBeatmapsTypeSelected extends ProfileBeatmapsEvent {
  const ProfileBeatmapsTypeSelected(this.value);
  final ProfileBeatmapsType value;
}

final class ProfileBeatmapsRefreshRequested extends ProfileBeatmapsEvent {
  const ProfileBeatmapsRefreshRequested();
}

final class ProfileBeatmapsMoreRequested extends ProfileBeatmapsEvent {
  const ProfileBeatmapsMoreRequested();
}
