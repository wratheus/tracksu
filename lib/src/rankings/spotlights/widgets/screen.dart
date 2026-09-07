import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/spotlights/bloc/bloc.dart';
import 'package:tracksu/src/rankings/spotlights/domain/spotlight.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class SpotlightsScreen extends StatelessWidget {
  const SpotlightsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: UiText.titleLarge(context.t.spotlightsTitle)),
    body: const SafeArea(child: _SpotlightsBody()),
  );
}

final class _SpotlightsBody extends StatefulWidget {
  const _SpotlightsBody();
  @override
  State<_SpotlightsBody> createState() => _SpotlightsBodyState();
}

final class _SpotlightsBodyState extends State<_SpotlightsBody> {
  bool _choosing = false;
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SpotlightsBloc, SpotlightsState>(
    builder: (BuildContext context, SpotlightsState state) => CustomScrollView(
      // A new selection starts at the top; refresh and pushed routes keep offset.
      key: ValueKey<Object>(
        _choosing
            ? 'spotlights-catalog'
            : state is SpotlightsLoadedState
            ? (state.selectedId, state.ruleset)
            : 'spotlights-loading',
      ),
      slivers: <Widget>[
        if (state is SpotlightsInitialState || state is SpotlightsLoadingState)
          const SliverToBoxAdapter(child: _Progress()),
        if (state case SpotlightsFailureState(:final failure))
          SliverToBoxAdapter(child: _Failure(failure)),
        if (state is SpotlightsLoadedState) ...<Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: <Widget>[
                  if (state.catalog.isNotEmpty)
                    UiButton.text(
                      onPressed: () => setState(() => _choosing = !_choosing),
                      label: _choosing
                          ? context.t.spotlightsShowRanking
                          : context.t.spotlightsChoose,
                    ),
                  if (!_choosing) ...<Widget>[
                    for (final Spotlight item in state.catalog)
                      if (item.id == state.selectedId)
                        UiText.titleLarge(item.name),
                    if (state.selectedId != null)
                      Wrap(
                        spacing: 10,
                        children: <Widget>[
                          for (final ProfileRuleset ruleset
                              in ProfileRuleset.values)
                            ChoiceChip(
                              label: Text(ruleset.apiValue),
                              selected: state.ruleset == ruleset,
                              onSelected: (_) => context
                                  .read<SpotlightsBloc>()
                                  .add(SpotlightRulesetSelected(ruleset)),
                            ),
                        ],
                      ),
                    UiButton.text(
                      onPressed: state.loading
                          ? null
                          : () => context.read<SpotlightsBloc>().add(
                              const SpotlightsRefreshRequested(),
                            ),
                      icon: Icons.refresh,
                      label: context.t.rankingsRefresh,
                    ),
                  ],
                  if (state.catalog.isEmpty) Text(context.t.spotlightsEmpty),
                ],
              ),
            ),
          ),
          if (_choosing)
            SliverList.builder(
              itemCount: state.catalog.length,
              itemBuilder: (_, int index) {
                final Spotlight item = state.catalog[index];
                return UiTile.selection(
                  key: ValueKey<int>(item.id),
                  title: item.name,
                  selected: item.id == state.selectedId,
                  onTap: () {
                    context.read<SpotlightsBloc>().add(
                      SpotlightSelected(item.id),
                    );
                    setState(() => _choosing = false);
                  },
                );
              },
            )
          else ...<Widget>[
            if (state.loading) const SliverToBoxAdapter(child: _Progress()),
            if (state.failure case final RankingsFailureKind failure)
              SliverToBoxAdapter(
                child: _Failure(failure, keepingContent: state.details != null),
              ),
            if (state.details case final SpotlightDetails details) ...<Widget>[
              SliverToBoxAdapter(child: _Heading(context.t.spotlightsMaps)),
              if (details.maps.isEmpty)
                SliverToBoxAdapter(child: _Heading(context.t.spotlightsNoMaps)),
              SliverList.builder(
                itemCount: details.maps.length,
                itemBuilder: (_, int index) {
                  final SpotlightMap map = details.maps[index];
                  return _NavigationTile(
                    key: ValueKey<String>('map-${map.id}'),
                    title: map.title,
                    subtitle: map.artist,
                    onOpen: () =>
                        DepsScope.of(context).appRouter
                            .openBeatmap(context, BeatmapsetParams(map.id)),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: _Heading(context.t.spotlightsRankingLimit),
              ),
              if (details.players.isEmpty)
                SliverToBoxAdapter(child: _Heading(context.t.rankingsEmpty)),
              SliverList.builder(
                itemCount: details.players.length,
                itemBuilder: (_, int index) {
                  final SpotlightPlayer player = details.players[index];
                  return _NavigationTile(
                    key: ValueKey<String>('player-${player.id}'),
                    title: player.name,
                    subtitle:
                        '${player.country} · ${context.t.rankingsRankedScore(player.score)}',
                    onOpen: () => DepsScope.of(context).appRouter.openProfile(
                      context,
                      ProfileParams(
                        user: ProfileUserId(player.id),
                        ruleset: state.ruleset,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ],
    ),
  );
}

final class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(UiSpace.lg),
    child: UiText.titleMedium(text),
  );
}

final class _Progress extends StatelessWidget {
  const _Progress();
  @override
  Widget build(BuildContext context) =>
      UiContentState.loading(title: context.t.rankingsLoading);
}

final class _Failure extends StatelessWidget {
  const _Failure(this.failure, {this.keepingContent = false});
  final RankingsFailureKind failure;
  final bool keepingContent;
  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      RankingsFailureKind.notFound => context.t.spotlightsNotFound,
      RankingsFailureKind.cancelled => context.t.rankingsCancelled,
      RankingsFailureKind.accessDenied => context.t.rankingsAccessDenied,
      RankingsFailureKind.rateLimited => context.t.profileRateLimited,
      RankingsFailureKind.connection => context.t.profileConnectionFailed,
      RankingsFailureKind.invalidResponse => context.t.rankingsInvalidResponse,
      RankingsFailureKind.unavailable => context.t.rankingsUnavailable,
    },
    message: keepingContent ? context.t.rankingsKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () =>
        context.read<SpotlightsBloc>().add(const SpotlightsRefreshRequested()),
  );
}

final class _NavigationTile extends StatefulWidget {
  const _NavigationTile({
    required this.title,
    required this.subtitle,
    required this.onOpen,
    super.key,
  });
  final String title;
  final String subtitle;
  final Future<void> Function() onOpen;
  @override
  State<_NavigationTile> createState() => _NavigationTileState();
}

final class _NavigationTileState extends State<_NavigationTile> {
  bool _opening = false;
  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await widget.onOpen();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => UiTile.navigation(
    title: widget.title,
    subtitle: widget.subtitle,
    onTap: _opening ? null : _open,
  );
}
