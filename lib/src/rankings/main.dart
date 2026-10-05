import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/navigation/shell_reselect.dart';
import 'package:tracksu/src/_shared/preferences/settings_button.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/data/rankings_repository_impl.dart';
import 'package:tracksu/src/rankings/data/countries_local_source.dart';
import 'package:tracksu/src/rankings/data/countries_repository_impl.dart';
import 'package:tracksu/src/rankings/domain/countries.dart';
import 'package:tracksu/src/rankings/country_stats/bloc/bloc.dart';
import 'package:tracksu/src/rankings/country_stats/data/remote_source.dart';
import 'package:tracksu/src/rankings/country_stats/data/repository_impl.dart';
import 'package:tracksu/src/rankings/country_stats/domain/country_ranking.dart';
import 'package:tracksu/src/rankings/country_stats/widgets/country_section.dart';
import 'package:tracksu/src/rankings/teams/bloc/bloc.dart';
import 'package:tracksu/src/rankings/teams/data/remote_source.dart';
import 'package:tracksu/src/rankings/teams/data/repository_impl.dart';
import 'package:tracksu/src/rankings/teams/widgets/team_section.dart';
import 'package:tracksu/src/rankings/widgets/filters.dart';
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
        child: BlocProvider<CountryRankingsBloc>(
          create: (_) => CountryRankingsBloc(
            cache: DepsScope.of(context).pageCache,
            repository: CountryRankingsRepositoryImpl(
              remoteSource: OsuCountryRankingsRemoteSource(
                restClient: DepsScope.of(context).publicRestClient,
              ),
            ),
          ),
          child: BlocProvider<TeamRankingsBloc>(
              create: (_) => TeamRankingsBloc(
                cache: DepsScope.of(context).pageCache,
                repository: TeamRankingsRepositoryImpl(
                  remoteSource: OsuTeamRankingsRemoteSource(
                    restClient: DepsScope.of(context).publicRestClient,
                  ),
                ),
              ),
          child: BlocProvider<RankingsBloc>(
          create: (_) => RankingsBloc(
            cache: DepsScope.of(context).pageCache,
            repository: RankingsRepositoryImpl(
              remoteSource: OsuRankingsRemoteSource(
                restClient: DepsScope.of(context).publicRestClient,
              ),
            ),
          )..add(const RankingsStarted()),
          child: Scaffold(
            appBar: AppBar(
              title: UiText.titleLarge(context.t.rankingsTitle),
              actions: <Widget>[
                const SettingsButton(),
                BlocBuilder<RankingsBloc, RankingsState>(
                  builder: (BuildContext context, RankingsState state) =>
                      ShareButton.icon(
                        target: ShareTarget.rankings(
                          RankingsQuery(
                            type: state.type,
                            country: state.country,
                            variant: state.variant,
                          ),
                          context.t.rankingsTitle,
                        ),
                      ),
                ),
              ],
              bottom: UiAppBarProgressSlot(
                child: BlocSelector<RankingsBloc, RankingsState, bool>(
                  selector: (RankingsState state) =>
                      state is RankingsLoadedState &&
                      state.operation == RankingsOperation.refresh,
                  builder: (BuildContext context, bool players) =>
                      BlocSelector<TeamRankingsBloc, TeamRankingsState, bool>(
                        selector: (TeamRankingsState state) =>
                            state.items != null &&
                            state.operation == TeamRankingsOperation.refresh,
                        builder: (BuildContext context, bool teams) =>
                            BlocSelector<
                              CountryRankingsBloc,
                              CountryRankingsState,
                              bool
                            >(
                              selector: (CountryRankingsState state) =>
                                  state.items != null &&
                                  state.operation ==
                                      CountryRankingsOperation.refresh,
                              builder: (BuildContext context, bool countries) =>
                                  UiAppBarProgress(
                                    visible: players || teams || countries,
                                    semanticsLabel: context.t.rankingsLoading,
                                  ),
                            ),
                      ),
                ),
              ),
            ),
            body: const SafeArea(child: _RankingsBody()),
          ),
        ),
        ),
        ),
      );
}

final class _RankingsBody extends StatefulWidget {
  const _RankingsBody();
  @override
  State<_RankingsBody> createState() => _RankingsBodyState();
}

enum _RankingsTab { players, teams, countries }

final class _RankingsBodyState extends State<_RankingsBody> {
  final ScrollController _scroll = ScrollController();
  _RankingsTab _tab = _RankingsTab.players;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Teams follow the shared ruleset/sort filters; the bloc ignores a query
  /// it already has, so this is safe on every type change.
  void _syncTeams(RankingsType type) => context.read<TeamRankingsBloc>().add(
    TeamRankingsQueryChanged(
      ruleset: type.ruleset,
      performance: type.sort == 'performance',
    ),
  );

  void _syncCountries(RankingsType type) => context
      .read<CountryRankingsBloc>()
      .add(CountryRankingsRulesetChanged(type.ruleset));

  void _sync(RankingsType type) {
    switch (_tab) {
      case _RankingsTab.players:
        break;
      case _RankingsTab.teams:
        _syncTeams(type);
      case _RankingsTab.countries:
        _syncCountries(type);
    }
  }

  void _select(_RankingsTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    _sync(context.read<RankingsBloc>().state.type);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  /// A country row opens the player table of that country.
  void _openCountry(CountryRankingEntry entry) {
    setState(() => _tab = _RankingsTab.players);
    context.read<RankingsBloc>().add(RankingsCountrySelected(entry.country));
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final Widget tabs = UiSegmentedControl<_RankingsTab>(
      selected: _tab,
      segments: <UiSegment<_RankingsTab>>[
        UiSegment<_RankingsTab>(
          value: _RankingsTab.players,
          label: context.t.rankingsPlayers,
          icon: const Icon(Icons.person_outline_rounded),
        ),
        UiSegment<_RankingsTab>(
          value: _RankingsTab.teams,
          label: context.t.rankingsTeams,
          icon: const Icon(Icons.groups_outlined),
        ),
        UiSegment<_RankingsTab>(
          value: _RankingsTab.countries,
          label: context.t.rankingsCountries,
          icon: const Icon(Icons.public),
        ),
      ],
      onChanged: _select,
    );
    return BlocListener<RankingsBloc, RankingsState>(
      listenWhen: (RankingsState before, RankingsState after) =>
          (before.type, before.country?.value, before.variant) !=
          (after.type, after.country?.value, after.variant),
      listener: (_, RankingsState state) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
        _sync(state.type);
      },
      child: UiScrollToTop(
        tooltip: context.t.scrollToTop,
        controller: _scroll,
        scrollRequests: ShellReselectScope.maybeOf(context, ShellTab.rankings),
        // Pull down to refresh; the spinner retracts at once and progress
        // continues on the app-bar line instead of a button and a loader.
        child: RefreshIndicator(
          onRefresh: () async {
            switch (_tab) {
              case _RankingsTab.teams:
                context.read<TeamRankingsBloc>().add(
                  const TeamRankingsRefreshRequested(),
                );
                return;
              case _RankingsTab.countries:
                context.read<CountryRankingsBloc>().add(
                  const CountryRankingsRefreshRequested(),
                );
                return;
              case _RankingsTab.players:
                break;
            }
            final RankingsBloc bloc = context.read<RankingsBloc>();
            if (bloc.state is RankingsLoadedState) {
              bloc.add(const RankingsRefreshRequested());
            }
          },
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              if (_tab == _RankingsTab.players)
                RankingsSection(leading: tabs)
              else ...<Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(UiSpace.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: UiSpace.md,
                      children: <Widget>[
                        tabs,
                        RankingsFilters(
                          scope: _tab == _RankingsTab.teams
                              ? RankingsFilterScope.teams
                              : RankingsFilterScope.countries,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_tab == _RankingsTab.teams)
                  const TeamRankingsSection()
                else
                  CountryRankingsSection(onOpenCountry: _openCountry),
              ],
              UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
            ],
          ),
        ),
      ),
    );
  }
}
