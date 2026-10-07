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
import 'package:tracksu/src/rankings/kudosu/bloc/bloc.dart';
import 'package:tracksu/src/rankings/kudosu/data/repository_impl.dart';
import 'package:tracksu/src/rankings/kudosu/data/remote_source.dart';
import 'package:tracksu/src/rankings/kudosu/widgets/kudosu_section.dart';
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
  Widget build(
    BuildContext context,
  ) => RepositoryProvider<RankingCountriesRepository>(
    create: (_) => RankingCountriesRepositoryImpl(
      source: const AssetRankingCountriesLocalSource(),
    ),
    child: BlocProvider<KudosuRankingBloc>(
      // The first request starts when the Kudosu page is first shown.
      create: (_) => KudosuRankingBloc(
        repository: KudosuRankingRepositoryImpl(
          remoteSource: KudosuRankingRemoteSource(
            restClient: DepsScope.of(context).publicRestClient,
          ),
        ),
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
                                builder:
                                    (BuildContext context, bool countries) =>
                                        BlocSelector<
                                          KudosuRankingBloc,
                                          KudosuRankingState,
                                          bool
                                        >(
                                          selector: (state) =>
                                              state.items != null &&
                                              state.operation ==
                                                  KudosuRankingOperation
                                                      .refresh,
                                          builder: (context, kudosu) =>
                                              UiAppBarProgress(
                                                visible:
                                                    players ||
                                                    teams ||
                                                    countries ||
                                                    kudosu,
                                                semanticsLabel:
                                                    context.t.rankingsLoading,
                                              ),
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
    ),
  );
}

final class _RankingsBody extends StatefulWidget {
  const _RankingsBody();
  @override
  State<_RankingsBody> createState() => _RankingsBodyState();
}

enum _RankingsTab { players, teams, countries, kudosu }

/// Players / Teams / Countries as swipeable pages under one fixed header:
/// the linked page switcher and the ruleset + PP/score filters all three
/// pages share. Each page keeps its own scroll, pull-to-refresh and
/// return-to-top; country and 4K/7K stay on the Players page.
final class _RankingsBodyState extends State<_RankingsBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: _RankingsTab.values.length,
    vsync: this,
  )..addListener(_tabChanged);
  final List<ScrollController> _scrolls = <ScrollController>[
    for (final _RankingsTab _ in _RankingsTab.values) ScrollController(),
  ];
  int _index = 0;

  _RankingsTab get _tab => _RankingsTab.values[_index];

  @override
  void dispose() {
    _tabs.dispose();
    for (final ScrollController scroll in _scrolls) {
      scroll.dispose();
    }
    super.dispose();
  }

  void _tabChanged() {
    if (_tabs.index == _index) return;
    setState(() => _index = _tabs.index);
    _sync(context.read<RankingsBloc>().state.type);
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
      case _RankingsTab.kudosu:
        break;
    }
  }

  void _toTop(int page) {
    final ScrollController scroll = _scrolls[page];
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  /// A country row opens the player table of that country.
  void _openCountry(CountryRankingEntry entry) {
    context.read<RankingsBloc>().add(RankingsCountrySelected(entry.country));
    _toTop(_RankingsTab.players.index);
    _tabs.animateTo(_RankingsTab.players.index);
  }

  void _refresh(_RankingsTab tab) {
    switch (tab) {
      case _RankingsTab.teams:
        context.read<TeamRankingsBloc>().add(
          const TeamRankingsRefreshRequested(),
        );
      case _RankingsTab.countries:
        context.read<CountryRankingsBloc>().add(
          const CountryRankingsRefreshRequested(),
        );
      case _RankingsTab.kudosu:
        context.read<KudosuRankingBloc>().add(const KudosuRankingRequested());
      case _RankingsTab.players:
        final RankingsBloc bloc = context.read<RankingsBloc>();
        if (bloc.state is RankingsLoadedState) {
          bloc.add(const RankingsRefreshRequested());
        }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<RankingsBloc, RankingsState>(
    listenWhen: (RankingsState before, RankingsState after) =>
        (before.type, before.country?.value, before.variant) !=
        (after.type, after.country?.value, after.variant),
    listener: (_, RankingsState state) {
      _toTop(_index);
      _sync(state.type);
    },
    child: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UiSpace.lg,
            UiSpace.sm,
            UiSpace.lg,
            UiSpace.xs,
          ),
          child: UiSegmentedControl<int>(
            selected: _index,
            // Switches as soon as a page is swiped past halfway.
            position: _tabs.animation,
            segments: <UiSegment<int>>[
              UiSegment<int>(
                value: _RankingsTab.players.index,
                label: context.t.rankingsPlayers,
                icon: const Icon(Icons.person_outline_rounded),
              ),
              UiSegment<int>(
                value: _RankingsTab.teams.index,
                label: context.t.rankingsTeams,
                icon: const Icon(Icons.groups_outlined),
              ),
              UiSegment<int>(
                value: _RankingsTab.countries.index,
                label: context.t.rankingsCountries,
                icon: const Icon(Icons.public),
              ),
              UiSegment<int>(
                value: _RankingsTab.kudosu.index,
                label: context.t.rankingsKudosu,
                icon: const Icon(Icons.volunteer_activism_outlined),
              ),
            ],
            onChanged: _tabs.animateTo,
          ),
        ),
        // Kudosu has no ruleset or PP/score: the shared block folds away.
        AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _tab == _RankingsTab.kudosu
              ? const SizedBox(width: double.infinity)
              : const Padding(
                  padding: EdgeInsets.fromLTRB(
                    UiSpace.lg,
                    UiSpace.sm,
                    UiSpace.lg,
                    UiSpace.xs,
                  ),
                  child: RankingsFilters(scope: RankingsFilterScope.shared),
                ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: <Widget>[
              for (final _RankingsTab tab in _RankingsTab.values)
                _RankingsPage(
                  key: ValueKey<_RankingsTab>(tab),
                  controller: _scrolls[tab.index],
                  // Re-tapping the Rankings tab scrolls the visible page.
                  scrollRequests: tab == _tab
                      ? ShellReselectScope.maybeOf(context, ShellTab.rankings)
                      : null,
                  onRefresh: () => _refresh(tab),
                  slivers: switch (tab) {
                    _RankingsTab.players => const <Widget>[RankingsSection()],
                    _RankingsTab.teams => const <Widget>[
                      _PageTop(),
                      TeamRankingsSection(),
                    ],
                    _RankingsTab.kudosu => const <Widget>[
                      KudosuRankingSection(),
                    ],
                    _RankingsTab.countries => <Widget>[
                      const _PageTop(),
                      BlocSelector<RankingsBloc, RankingsState, bool>(
                        selector: (RankingsState state) =>
                            state.type.sort == 'performance',
                        builder: (BuildContext context, bool performance) =>
                            CountryRankingsSection(
                              performance: performance,
                              onOpenCountry: _openCountry,
                            ),
                      ),
                    ],
                  },
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Breathing room between the fixed header and the first card.
final class _PageTop extends StatelessWidget {
  const _PageTop();

  @override
  Widget build(BuildContext context) =>
      const SliverToBoxAdapter(child: SizedBox(height: UiSpace.md));
}

/// One swipeable page: own scroll position (kept alive), pull-to-refresh
/// and return-to-top button.
final class _RankingsPage extends StatefulWidget {
  const _RankingsPage({
    required this.controller,
    required this.onRefresh,
    required this.slivers,
    this.scrollRequests,
    super.key,
  });
  final ScrollController controller;
  final VoidCallback onRefresh;
  final List<Widget> slivers;
  final Listenable? scrollRequests;

  @override
  State<_RankingsPage> createState() => _RankingsPageState();
}

final class _RankingsPageState extends State<_RankingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return UiScrollToTop(
      tooltip: context.t.scrollToTop,
      controller: widget.controller,
      scrollRequests: widget.scrollRequests,
      // Pull down to refresh; the spinner retracts at once and progress
      // continues on the app-bar line instead of a button and a loader.
      child: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: CustomScrollView(
          controller: widget.controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            ...widget.slivers,
            UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
          ],
        ),
      ),
    );
  }
}
