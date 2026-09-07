import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/data/osu_profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_repository_impl.dart';
import 'package:tracksu/src/profile/widgets/screen.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

final class ProfileMain extends StatelessWidget {
  const ProfileMain({required ProfileParams this.params, super.key});
  const ProfileMain.current({super.key}) : params = null;

  final ProfileParams? params;

  @override
  Widget build(BuildContext context) {
    final deps = DepsScope.of(context);
    return BlocProvider<ProfileBloc>(
      create: (_) {
        final ProfileBloc bloc = ProfileBloc(
          initialRuleset: params?.ruleset ?? ProfileRuleset.osu,
          repository: ProfileRepositoryImpl(
            remoteSource: OsuProfileRemoteSource(
              restClient: deps.restClient,
              publicRestClient: deps.publicRestClient,
            ),
          ),
        );
        if (params case final ProfileParams target) {
          bloc.add(ProfileLookupRequested(target.user));
        } else {
          bloc.add(const CurrentProfileLoadRequested());
        }
        return bloc;
      },
      child: const ProfileScreen(),
    );
  }
}
