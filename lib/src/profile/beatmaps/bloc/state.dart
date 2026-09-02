part of 'bloc.dart';

sealed class ProfileBeatmapsState {
  const ProfileBeatmapsState({required this.type});
  final ProfileBeatmapsType type;
}

final class ProfileBeatmapsInitialState extends ProfileBeatmapsState {
  const ProfileBeatmapsInitialState()
    : super(type: ProfileBeatmapsType.mostPlayed);
}

final class ProfileBeatmapsLoadingState extends ProfileBeatmapsState {
  const ProfileBeatmapsLoadingState({required super.type});
}

final class ProfileBeatmapsFailureState extends ProfileBeatmapsState {
  const ProfileBeatmapsFailureState({
    required super.type,
    required this.failure,
  });
  final ProfileBeatmapsFailureKind failure;
}

enum ProfileBeatmapsOperation { refresh, loadMore }

final class ProfileBeatmapsLoadedState extends ProfileBeatmapsState {
  ProfileBeatmapsLoadedState({
    required super.type,
    required List<ProfileBeatmap> items,
    required this.nextOffset,
    this.operation,
    this.failure,
    this.failedOperation,
  }) : items = List<ProfileBeatmap>.unmodifiable(items);

  final List<ProfileBeatmap> items;
  final int? nextOffset;
  final ProfileBeatmapsOperation? operation;
  final ProfileBeatmapsFailureKind? failure;
  final ProfileBeatmapsOperation? failedOperation;
}
