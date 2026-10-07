import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/daily/bloc/bloc.dart';
import 'package:tracksu/src/daily/data/remote_source.dart';
import 'package:tracksu/src/daily/data/repository_impl.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu/src/daily/widgets/history_screen.dart';
import 'package:tracksu/src/daily/widgets/screen.dart';

/// Takes the container, not a context: a BlocProvider `create` context must
/// not subscribe to inherited widgets (DepsScope.of would assert there).
DailyChallengeBloc createDailyChallengeBloc(
  DepsContainer deps, {
  bool withLeaderboard = false,
  int? pastRoomId,
}) => DailyChallengeBloc(
  withLeaderboard: withLeaderboard,
  pastRoomId: pastRoomId,
  // A day opened from the history list is handed over through the session
  // cache; a restored route without it looks the day up again.
  past: pastRoomId == null
      ? null
      : deps.pageCache.read<DailyChallenge>(dailyRoomCacheKey(pastRoomId)),
  repository: DailyChallengeRepositoryImpl(
    remoteSource: OsuDailyChallengeRemoteSource(
      restClient: deps.publicRestClient,
    ),
  ),
)..add(const DailyChallengeRequested());

/// Route: today's challenge, or a past day ([pastRoomId]), with its
/// leaderboard.
final class DailyChallengeMain extends StatelessWidget {
  const DailyChallengeMain({this.pastRoomId, super.key});
  final int? pastRoomId;

  @override
  Widget build(BuildContext context) => BlocProvider<DailyChallengeBloc>(
    create: (_) => createDailyChallengeBloc(
      DepsScope.of(context),
      withLeaderboard: true,
      pastRoomId: pastRoomId,
    ),
    child: DailyChallengeScreen(past: pastRoomId != null),
  );
}

/// Route: list of past daily challenges.
final class DailyHistoryMain extends StatelessWidget {
  const DailyHistoryMain({super.key});

  @override
  Widget build(BuildContext context) {
    final DepsContainer deps = DepsScope.of(context);
    return BlocProvider<DailyHistoryBloc>(
      create: (_) => DailyHistoryBloc(
        repository: DailyChallengeRepositoryImpl(
          remoteSource: OsuDailyChallengeRemoteSource(
            restClient: deps.publicRestClient,
          ),
        ),
      )..add(const DailyHistoryRequested()),
      child: const DailyHistoryScreen(),
    );
  }
}
