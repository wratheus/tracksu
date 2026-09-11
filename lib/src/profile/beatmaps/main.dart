import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/beatmaps/bloc/bloc.dart';
import 'package:tracksu/src/profile/beatmaps/data/beatmaps_remote_source.dart';
import 'package:tracksu/src/profile/beatmaps/data/beatmaps_repository_impl.dart';
import 'package:tracksu/src/profile/beatmaps/widgets/beatmaps_section.dart';

/// Mounted with a player key; owns only this section's repository/Bloc.
final class ProfileBeatmapsMain extends StatelessWidget {
  const ProfileBeatmapsMain({required this.userId, super.key});
  final int userId;

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileBeatmapsBloc>(
    create: (_) => ProfileBeatmapsBloc(
      cache: DepsScope.of(context).pageCache,
      repository: ProfileBeatmapsRepositoryImpl(
        remoteSource: OsuProfileBeatmapsRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
      user: ProfileUserId(userId),
    )..add(const ProfileBeatmapsStarted()),
    child: const ProfileBeatmapsSection(),
  );
}
