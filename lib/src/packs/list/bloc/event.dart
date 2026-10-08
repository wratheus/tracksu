part of 'bloc.dart';

sealed class BeatmapPacksEvent {
  const BeatmapPacksEvent();
}

final class BeatmapPacksStarted extends BeatmapPacksEvent {
  const BeatmapPacksStarted();
}

final class BeatmapPacksTypeSelected extends BeatmapPacksEvent {
  const BeatmapPacksTypeSelected(this.type);
  final BeatmapPackType type;
}

final class BeatmapPacksRefreshRequested extends BeatmapPacksEvent {
  const BeatmapPacksRefreshRequested();
}

final class BeatmapPacksMoreRequested extends BeatmapPacksEvent {
  const BeatmapPacksMoreRequested();
}
