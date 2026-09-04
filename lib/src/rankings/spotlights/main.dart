import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/rankings/spotlights/bloc/bloc.dart';
import 'package:tracksu/src/rankings/spotlights/data/remote_source.dart';
import 'package:tracksu/src/rankings/spotlights/data/repository_impl.dart';
import 'package:tracksu/src/rankings/spotlights/widgets/screen.dart';

final class SpotlightsMain extends StatelessWidget {
  const SpotlightsMain({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider<SpotlightsBloc>(
    create: (_) => SpotlightsBloc(
      repository: SpotlightsRepositoryImpl(
        remoteSource: OsuSpotlightsRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
    )..add(const SpotlightsStarted()),
    child: const SpotlightsScreen(),
  );
}
