import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/scores/bloc/bloc.dart';
import 'package:tracksu/src/profile/scores/data/scores_remote_source.dart';
import 'package:tracksu/src/profile/scores/data/scores_repository_impl.dart';
import 'package:tracksu/src/profile/scores/widgets/scores_section.dart';

/// Mounted with a player/ruleset key; owns only this section's repository/Bloc.
final class ProfileScoresMain extends StatelessWidget {
  const ProfileScoresMain({
    required this.userId,
    required this.ruleset,
    super.key,
  });
  final int userId;
  final ProfileRuleset ruleset;

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileScoresBloc>(
    create: (_) => ProfileScoresBloc(
      cache: DepsScope.of(context).pageCache,
      repository: ProfileScoresRepositoryImpl(
        remoteSource: OsuProfileScoresRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
      user: ProfileUserId(userId),
      ruleset: ruleset,
    )..add(const ProfileScoresStarted()),
    child: const ProfileScoresSection(),
  );
}
