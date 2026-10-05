import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/beatmap_search/bloc/bloc.dart';
import 'package:tracksu/src/beatmap_search/data/remote_source.dart';
import 'package:tracksu/src/beatmap_search/data/repository_impl.dart';
import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu/src/beatmap_search/widgets/screen.dart';

/// Route: beatmap listing search, optionally started with [text].
final class BeatmapSearchMain extends StatelessWidget {
  const BeatmapSearchMain({this.text = '', super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final BeatmapSearchQuery initial = BeatmapSearchQuery(text: text);
    final deps = DepsScope.of(context);
    return BlocProvider<BeatmapSearchBloc>(
      create: (_) => BeatmapSearchBloc(
        initial: initial,
        repository: BeatmapSearchRepositoryImpl(
          source: BeatmapSearchRemoteSource(restClient: deps.publicRestClient),
        ),
      )..add(BeatmapSearchQueryChanged(initial)),
      child: BeatmapSearchScreen(initialText: text),
    );
  }
}
