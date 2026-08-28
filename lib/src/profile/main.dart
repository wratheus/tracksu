import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/data/osu_profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_repository_impl.dart';
import 'package:tracksu/src/profile/widgets/screen.dart';

final class ProfileMain extends StatelessWidget {
  const ProfileMain({required this.actions, super.key});

  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final deps = DepsScope.of(context);
    return BlocProvider<ProfileBloc>(
      create: (_) => ProfileBloc(
        repository: ProfileRepositoryImpl(
          remoteSource: OsuProfileRemoteSource(
            restClient: deps.restClient,
            publicRestClient: deps.publicRestClient,
          ),
        ),
      ),
      child: ProfileScreen(actions: actions),
    );
  }
}
