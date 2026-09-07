import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/data/rankings_repository_impl.dart';
import 'package:tracksu/src/rankings/widgets/rankings_section.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Owns this route's repository and Bloc.
final class RankingsMain extends StatelessWidget {
  const RankingsMain({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<RankingsBloc>(
    create: (_) => RankingsBloc(
      repository: RankingsRepositoryImpl(
        remoteSource: OsuRankingsRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
    )..add(const RankingsStarted()),
    child: Scaffold(
      appBar: AppBar(title: UiText.titleLarge(context.t.rankingsTitle)),
      body: const SafeArea(
        child: CustomScrollView(slivers: <Widget>[RankingsSection()]),
      ),
    ),
  );
}
