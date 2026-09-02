part of 'bloc.dart';

sealed class LeaderboardEvent {
  const LeaderboardEvent();
}

final class LeaderboardLoadRequested extends LeaderboardEvent {
  const LeaderboardLoadRequested();
}
