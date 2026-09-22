import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/beatmap/leaderboard/bloc/bloc.dart';
import 'package:tracksu/src/beatmap/leaderboard/data/remote_source.dart';
import 'package:tracksu/src/beatmap/leaderboard/data/repository_impl.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';
import 'package:tracksu/src/beatmap/leaderboard/widgets/section.dart';

final class LeaderboardMain extends StatelessWidget {
  const LeaderboardMain({required this.query, this.coverUri, super.key});
  final LeaderboardQuery query;
  final Uri? coverUri;
  @override
  Widget build(BuildContext context) => BlocProvider<LeaderboardBloc>(
    key: ValueKey<(int, ProfileRuleset, bool)>((
      query.beatmapId,
      query.ruleset,
      query.legacy,
    )),
    create: (_) => LeaderboardBloc(
      cache: DepsScope.of(context).pageCache,
      repository: LeaderboardRepositoryImpl(
        source: LeaderboardRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
      query: query,
    )..add(const LeaderboardLoadRequested()),
    child: LeaderboardSection(coverUri: coverUri),
  );
}
