import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/beatmap/bloc/bloc.dart';
import 'package:tracksu/src/beatmap/data/remote_source.dart';
import 'package:tracksu/src/beatmap/data/repository_impl.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/widgets/screen.dart';

final class BeatmapMain extends StatelessWidget {
  const BeatmapMain({required this.params, super.key});
  final BeatmapParams params;
  @override
  Widget build(BuildContext context) => BlocProvider<BeatmapBloc>(
    create: (_) => BeatmapBloc(
      repository: BeatmapRepositoryImpl(
        source: BeatmapRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
      params: params,
    )..add(const BeatmapLoadRequested()),
    child: BeatmapScreen(params: params),
  );
}
