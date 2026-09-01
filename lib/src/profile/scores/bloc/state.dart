part of 'bloc.dart';

sealed class ProfileScoresState {
  const ProfileScoresState({required this.type});
  final ProfileScoresType type;
}

final class ProfileScoresInitialState extends ProfileScoresState {
  const ProfileScoresInitialState() : super(type: ProfileScoresType.best);
}

final class ProfileScoresLoadingState extends ProfileScoresState {
  const ProfileScoresLoadingState({required super.type});
}

final class ProfileScoresFailureState extends ProfileScoresState {
  const ProfileScoresFailureState({required super.type, required this.failure});
  final ProfileScoresFailureKind failure;
}

enum ProfileScoresOperation { refresh, loadMore }

final class ProfileScoresLoadedState extends ProfileScoresState {
  ProfileScoresLoadedState({
    required super.type,
    required List<ProfileScore> items,
    required this.nextOffset,
    this.operation,
    this.failure,
    this.failedOperation,
  }) : items = List<ProfileScore>.unmodifiable(items);

  final List<ProfileScore> items;
  final int? nextOffset;
  final ProfileScoresOperation? operation;
  final ProfileScoresFailureKind? failure;
  final ProfileScoresOperation? failedOperation;
}
