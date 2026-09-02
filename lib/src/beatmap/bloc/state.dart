part of 'bloc.dart';

sealed class BeatmapState {
  const BeatmapState();
}

final class BeatmapLoadingState extends BeatmapState {
  const BeatmapLoadingState();
}

final class BeatmapErrorState extends BeatmapState {
  const BeatmapErrorState(this.failure);
  final BeatmapFailureKind failure;
}

final class BeatmapLoadedState extends BeatmapState {
  const BeatmapLoadedState({
    required this.details,
    required this.selectedId,
    this.refreshing = false,
    this.failure,
  });
  final BeatmapDetails details;
  final int? selectedId;
  final bool refreshing;
  final BeatmapFailureKind? failure;
}
