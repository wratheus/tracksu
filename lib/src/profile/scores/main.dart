import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/scores/bloc/bloc.dart';
import 'package:tracksu/src/profile/scores/data/scores_remote_source.dart';
import 'package:tracksu/src/profile/scores/data/scores_repository_impl.dart';

/// Owns the Results section's repository/Bloc for one player and ruleset.
/// Placed above the profile tabs and created eagerly, so the first page is
/// requested as soon as the profile opens — not when the tab is first shown.
final class ProfileScoresProvider extends StatelessWidget {
  const ProfileScoresProvider({
    required this.userId,
    required this.ruleset,
    required this.child,
    super.key,
  });
  final int userId;
  final ProfileRuleset ruleset;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileScoresBloc>(
    key: ValueKey<(int, ProfileRuleset)>((userId, ruleset)),
    lazy: false,
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
    child: child,
  );
}
