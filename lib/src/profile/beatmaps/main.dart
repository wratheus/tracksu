import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/beatmaps/bloc/bloc.dart';
import 'package:tracksu/src/profile/beatmaps/data/beatmaps_remote_source.dart';
import 'package:tracksu/src/profile/beatmaps/data/beatmaps_repository_impl.dart';

/// Owns the Maps section's repository/Bloc for one player. Placed above the
/// profile tabs and created eagerly (see ProfileScoresProvider).
final class ProfileBeatmapsProvider extends StatelessWidget {
  const ProfileBeatmapsProvider({
    required this.userId,
    required this.child,
    super.key,
  });
  final int userId;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileBeatmapsBloc>(
    key: ValueKey<int>(userId),
    lazy: false,
    create: (_) => ProfileBeatmapsBloc(
      cache: DepsScope.of(context).pageCache,
      repository: ProfileBeatmapsRepositoryImpl(
        remoteSource: OsuProfileBeatmapsRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
      user: ProfileUserId(userId),
    )..add(const ProfileBeatmapsStarted()),
    child: child,
  );
}
