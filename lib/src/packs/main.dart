import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/packs/data/packs_repository.dart';
import 'package:tracksu/src/packs/domain/packs.dart';
import 'package:tracksu/src/packs/list/bloc/bloc.dart';
import 'package:tracksu/src/packs/pack/bloc/bloc.dart';
import 'package:tracksu/src/packs/widgets/pack_screen.dart';
import 'package:tracksu/src/packs/widgets/packs_screen.dart';

/// Route `…/packs?type=`: packs of one type (P55).
final class BeatmapPacksMain extends StatelessWidget {
  const BeatmapPacksMain({required this.type, super.key});
  final BeatmapPackType type;

  @override
  Widget build(BuildContext context) => BlocProvider<BeatmapPacksBloc>(
    create: (_) => BeatmapPacksBloc(
      type: type,
      cache: DepsScope.of(context).pageCache,
      repository: BeatmapPacksRepository(
        restClient: DepsScope.of(context).publicRestClient,
      ),
    )..add(const BeatmapPacksStarted()),
    child: const BeatmapPacksScreen(),
  );
}

/// Route `…/pack/{tag}`: one pack with its beatmapsets (P55).
final class BeatmapPackMain extends StatelessWidget {
  const BeatmapPackMain({required this.tag, super.key});
  final String tag;

  @override
  Widget build(BuildContext context) => BlocProvider<BeatmapPackBloc>(
    create: (_) => BeatmapPackBloc(
      tag: tag,
      cache: DepsScope.of(context).pageCache,
      repository: BeatmapPacksRepository(
        restClient: DepsScope.of(context).publicRestClient,
      ),
    )..add(const BeatmapPackStarted()),
    child: const BeatmapPackScreen(),
  );
}
