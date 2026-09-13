import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/team/bloc/bloc.dart';
import 'package:tracksu/src/team/data/remote_source.dart';
import 'package:tracksu/src/team/data/repository_impl.dart';
import 'package:tracksu/src/team/domain/team.dart';
import 'package:tracksu/src/team/widgets/screen.dart';

final class TeamMain extends StatelessWidget {
  const TeamMain({required this.params, super.key});
  final TeamParams params;
  @override
  Widget build(BuildContext context) {
    final deps = DepsScope.of(context);
    return BlocProvider<TeamBloc>(
      create: (_) => TeamBloc(
        repository: TeamRepositoryImpl(
          OsuTeamRemoteSource(deps.publicRestClient),
        ),
        cache: deps.pageCache,
        params: params,
      )..add(const TeamStarted()),
      child: TeamScreen(id: params.id),
    );
  }
}
