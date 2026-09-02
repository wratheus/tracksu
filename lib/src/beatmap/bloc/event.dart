part of 'bloc.dart';

sealed class BeatmapEvent {
  const BeatmapEvent();
}

final class BeatmapLoadRequested extends BeatmapEvent {
  const BeatmapLoadRequested();
}

final class BeatmapSelected extends BeatmapEvent {
  const BeatmapSelected(this.id);
  final int id;
}
