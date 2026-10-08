part of 'bloc.dart';

sealed class ProfileActivityState {
  const ProfileActivityState();
}

final class ProfileActivityInitialState extends ProfileActivityState {
  const ProfileActivityInitialState();
}

final class ProfileActivityLoadingState extends ProfileActivityState {
  const ProfileActivityLoadingState();
}

final class ProfileActivityFailureState extends ProfileActivityState {
  const ProfileActivityFailureState(this.failure);
  final ProfileActivityFailureKind failure;
}

enum ProfileActivityOperation { refresh, loadMore }

final class ProfileActivityLoadedState extends ProfileActivityState {
  ProfileActivityLoadedState({
    required List<OsuEvent> items,
    required this.nextOffset,
    this.operation,
    this.failure,
    this.failedOperation,
  }) : items = List<OsuEvent>.unmodifiable(items);

  final List<OsuEvent> items;
  final int? nextOffset;
  final ProfileActivityOperation? operation;
  final ProfileActivityFailureKind? failure;
  final ProfileActivityOperation? failedOperation;
}
