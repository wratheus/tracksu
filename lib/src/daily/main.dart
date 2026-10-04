import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/daily/bloc/bloc.dart';
import 'package:tracksu/src/daily/data/remote_source.dart';
import 'package:tracksu/src/daily/data/repository_impl.dart';
import 'package:tracksu/src/daily/widgets/screen.dart';

/// Takes the container, not a context: a BlocProvider `create` context must
/// not subscribe to inherited widgets (DepsScope.of would assert there).
DailyChallengeBloc createDailyChallengeBloc(
  DepsContainer deps, {
  bool withLeaderboard = false,
}) => DailyChallengeBloc(
  withLeaderboard: withLeaderboard,
  repository: DailyChallengeRepositoryImpl(
    remoteSource: OsuDailyChallengeRemoteSource(
      restClient: deps.publicRestClient,
    ),
  ),
)..add(const DailyChallengeRequested());

/// Route: today's challenge and its leaderboard.
final class DailyChallengeMain extends StatelessWidget {
  const DailyChallengeMain({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<DailyChallengeBloc>(
    create: (_) => createDailyChallengeBloc(
      DepsScope.of(context),
      withLeaderboard: true,
    ),
    child: const DailyChallengeScreen(),
  );
}
