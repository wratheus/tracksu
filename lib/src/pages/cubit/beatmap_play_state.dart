part of 'beatmap_play_cubit.dart';


@immutable
abstract class BeatmapPlayState {}

class BeatmapPlayInitial extends BeatmapPlayState {
  final double percent;

  BeatmapPlayInitial(this.percent);
}

class BeatmapRunState extends BeatmapPlayState {
  final double percent;

  BeatmapRunState(this.percent);
}

class BeatmapPauseState extends BeatmapPlayState {
  final double percent;

  BeatmapPauseState(this.percent);
}


