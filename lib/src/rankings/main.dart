import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/data/rankings_repository_impl.dart';
import 'package:tracksu/src/rankings/data/countries_local_source.dart';
import 'package:tracksu/src/rankings/data/countries_repository_impl.dart';
import 'package:tracksu/src/rankings/domain/countries.dart';
import 'package:tracksu/src/rankings/widgets/rankings_section.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Owns this route's repository and Bloc.
final class RankingsMain extends StatelessWidget {
  const RankingsMain({super.key});

  @override
  Widget build(BuildContext context) =>
      RepositoryProvider<RankingCountriesRepository>(
        create: (_) => RankingCountriesRepositoryImpl(
          source: const AssetRankingCountriesLocalSource(),
        ),
        child: BlocProvider<RankingsBloc>(
          create: (_) => RankingsBloc(
            repository: RankingsRepositoryImpl(
              remoteSource: OsuRankingsRemoteSource(
                restClient: DepsScope.of(context).publicRestClient,
              ),
            ),
          )..add(const RankingsStarted()),
          child: Scaffold(
            appBar: AppBar(title: UiText.titleLarge(context.t.rankingsTitle)),
            body: const SafeArea(child: _RankingsBody()),
          ),
        ),
      );
}

final class _RankingsBody extends StatefulWidget {
  const _RankingsBody();
  @override
  State<_RankingsBody> createState() => _RankingsBodyState();
}

final class _RankingsBodyState extends State<_RankingsBody> {
  final ScrollController _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<RankingsBloc, RankingsState>(
        listenWhen: (RankingsState before, RankingsState after) =>
            (before.type, before.country?.value, before.variant) !=
            (after.type, after.country?.value, after.variant),
        listener: (_, _) {
          if (_scroll.hasClients) _scroll.jumpTo(0);
        },
        child: CustomScrollView(
          controller: _scroll,
          slivers: const <Widget>[RankingsSection()],
        ),
      );
}
