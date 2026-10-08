part of 'bloc.dart';

sealed class BeatmapPackEvent {
  const BeatmapPackEvent();
}

final class BeatmapPackStarted extends BeatmapPackEvent {
  const BeatmapPackStarted();
}

final class BeatmapPackRefreshRequested extends BeatmapPackEvent {
  const BeatmapPackRefreshRequested();
}
