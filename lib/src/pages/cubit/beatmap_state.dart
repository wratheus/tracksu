part of 'beatmap_cubit.dart';


@immutable
abstract class BeatmapState {}

class BeatmapInitial extends BeatmapState {

}

class BeatmapLoadedState extends BeatmapState {
  final Beatmap beatmapInstance;
  final List<BeatmapScore> beatmapLeaderboard;

  BeatmapLoadedState(this.beatmapInstance, this.beatmapLeaderboard);
}

class BeatmapErrorState extends BeatmapState {
  final String errorMessage;

  BeatmapErrorState(this.errorMessage);
}


