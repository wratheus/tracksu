import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/wiki/bloc/wiki_search_bloc.dart';
import 'package:tracksu/src/wiki/data/wiki_repository.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/beatmap_search/bloc/bloc.dart';
import 'package:tracksu/src/beatmap_search/data/remote_source.dart';
import 'package:tracksu/src/beatmap_search/data/repository_impl.dart';
import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu/src/search/bloc/bloc.dart';
import 'package:tracksu/src/search/data/remote_source.dart';
import 'package:tracksu/src/search/data/repository_impl.dart';
import 'package:tracksu/src/search/domain/user_search.dart';
import 'package:tracksu/src/search/domain/search_params.dart';
import 'package:tracksu/src/search/widgets/screen.dart';

final class SearchMain extends StatelessWidget {
  const SearchMain({this.params = const SearchParams(), super.key});
  final SearchParams params;

  @override
  Widget build(BuildContext context) {
    final deps = DepsScope.of(context);
    return RepositoryProvider<UserSearchRepository>(
      create: (_) => UserSearchRepositoryImpl(
        source: UserSearchRemoteSource(client: deps.publicRestClient),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserSearchBloc>(
            create: (context) => UserSearchBloc(
              repository: context.read<UserSearchRepository>(),
            ),
          ),
          BlocProvider<WikiSearchBloc>(
            create: (_) => WikiSearchBloc(
              repository: WikiRepository(restClient: deps.publicRestClient),
              locale: () => deps.localeController.effectiveLanguageCode,
            ),
          ),
          BlocProvider<BeatmapSearchBloc>(
            create: (_) => BeatmapSearchBloc(
              minimumQueryLength: 2,
              initial: const BeatmapSearchQuery(ruleset: null),
              repository: BeatmapSearchRepositoryImpl(
                source: BeatmapSearchRemoteSource(
                  restClient: deps.publicRestClient,
                ),
              ),
            ),
          ),
        ],
        child: SearchScreen(initialText: params.text, initialTab: params.tab),
      ),
    );
  }
}
