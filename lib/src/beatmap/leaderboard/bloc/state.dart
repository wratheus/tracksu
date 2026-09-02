part of 'bloc.dart';

sealed class LeaderboardState {
  const LeaderboardState();
}

final class LeaderboardLoadingState extends LeaderboardState {
  const LeaderboardLoadingState();
}

final class LeaderboardErrorState extends LeaderboardState {
  const LeaderboardErrorState(this.failure);
  final BeatmapFailureKind failure;
}

final class LeaderboardLoadedState extends LeaderboardState {
  LeaderboardLoadedState(
    List<LeaderboardEntry> entries, {
    this.refreshing = false,
    this.failure,
  }) : entries = List<LeaderboardEntry>.unmodifiable(entries);
  final List<LeaderboardEntry> entries;
  final bool refreshing;
  final BeatmapFailureKind? failure;
}
