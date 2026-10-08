import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/changelog/bloc/bloc.dart';
import 'package:tracksu/src/changelog/data/remote_source.dart';
import 'package:tracksu/src/changelog/data/repository_impl.dart';
import 'package:tracksu/src/events/bloc/bloc.dart';
import 'package:tracksu/src/events/data/events_repository.dart';
import 'package:tracksu/src/forum/data/forum_repository.dart';
import 'package:tracksu/src/forum/index/bloc/bloc.dart';
import 'package:tracksu/src/news/bloc/bloc.dart';
import 'package:tracksu/src/news/data/remote_source.dart';
import 'package:tracksu/src/news/data/repository_impl.dart';
import 'package:tracksu/src/osu_hub/screen.dart';

/// Root of the third navbar tab: osu! News, Events, Forum and Changelog
/// (P50, P51, P54).
/// All three start when the tab opens, so swiping shows ready pages.
final class OsuHubMain extends StatelessWidget {
  const OsuHubMain({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<NewsBloc>(
        create: (_) => NewsBloc(
          cache: DepsScope.of(context).pageCache,
          params: null,
          repository: NewsRepositoryImpl(
            remoteSource: OsuNewsRemoteSource(
              restClient: DepsScope.of(context).publicRestClient,
            ),
          ),
        )..add(const NewsStarted()),
      ),
      BlocProvider<OsuEventsBloc>(
        create: (_) => OsuEventsBloc(
          cache: DepsScope.of(context).pageCache,
          repository: OsuEventsRepository(
            restClient: DepsScope.of(context).publicRestClient,
          ),
        )..add(const OsuEventsStarted()),
      ),
      BlocProvider<ForumIndexBloc>(
        create: (_) => ForumIndexBloc(
          cache: DepsScope.of(context).pageCache,
          repository: ForumRepository(
            restClient: DepsScope.of(context).publicRestClient,
          ),
        )..add(const ForumIndexStarted()),
      ),
      BlocProvider<ChangelogBloc>(
        create: (_) => ChangelogBloc(
          cache: DepsScope.of(context).pageCache,
          repository: ChangelogRepositoryImpl(
            remoteSource: OsuChangelogRemoteSource(
              restClient: DepsScope.of(context).publicRestClient,
            ),
          ),
        )..add(const ChangelogStarted()),
      ),
    ],
    child: const OsuHubScreen(),
  );
}
