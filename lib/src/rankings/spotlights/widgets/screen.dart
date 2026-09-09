import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_core/l10n/localized_count.dart';
import 'package:tracksu/src/_shared/beatmaps/widgets/beatmap_facts.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/spotlights/bloc/bloc.dart';
import 'package:tracksu/src/rankings/spotlights/domain/spotlight.dart';
import 'package:tracksu/src/rankings/spotlights/widgets/catalog_picker.dart';
import 'package:tracksu/src/rankings/spotlights/widgets/navigation_card.dart';
import 'package:tracksu/src/rankings/spotlights/widgets/period.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class SpotlightsScreen extends StatelessWidget {
  const SpotlightsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(context.t.spotlightsTitle),
      actions: <Widget>[
        BlocBuilder<SpotlightsBloc, SpotlightsState>(
          builder: (BuildContext context, SpotlightsState state) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              UiIconButton.standard(
                tooltip: context.t.rankingsRefresh,
                icon: Icons.refresh,
                onPressed:
                    state is SpotlightsLoadingState ||
                        (state is SpotlightsLoadedState && state.loading)
                    ? null
                    : () => context.read<SpotlightsBloc>().add(
                        const SpotlightsRefreshRequested(),
                      ),
              ),
              ShareButton.icon(
                target: ShareTarget.spotlight(
                  state is SpotlightsLoadedState
                      ? state.ruleset
                      : ProfileRuleset.osu,
                  state is SpotlightsLoadedState ? state.selectedId : null,
                  state is SpotlightsLoadedState
                      ? state.details?.spotlight.name ??
                            context.t.spotlightsTitle
                      : context.t.spotlightsTitle,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
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

  Future<void> _choose(SpotlightsLoadedState state) async {
    if (_choosing) return;
    final SpotlightsBloc bloc = context.read<SpotlightsBloc>();
    setState(() => _choosing = true);
    try {
      final int? id = await UiModal.scrollable<int>(
        context,
        title: context.t.spotlightsChoose,
        builder: (_) => SpotlightCatalogPicker(
          catalog: state.catalog,
          selectedId: state.selectedId,
        ),
      );
      if (!mounted || bloc.isClosed || id == null) return;
      bloc.add(SpotlightSelected(id));
    } finally {
      if (mounted) setState(() => _choosing = false);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SpotlightsBloc, SpotlightsState>(
    builder: (BuildContext context, SpotlightsState state) => CustomScrollView(
      // Opening a picker does not replace the viewport or discard its offset.
      key: ValueKey<Object>(
        state is SpotlightsLoadedState
            ? (state.selectedId, state.ruleset)
            : 'spotlights-loading',
      ),
      slivers: <Widget>[
        if (state is SpotlightsInitialState || state is SpotlightsLoadingState)
          SliverToBoxAdapter(
            child: UiLoading(label: context.t.rankingsLoading),
          ),
        if (state case SpotlightsFailureState(:final failure))
          SliverToBoxAdapter(child: _Failure(failure)),
        if (state is SpotlightsLoadedState) ...<Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(UiSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: UiSpace.lg,
                children: <Widget>[
                  if (state.catalog.isEmpty)
                    UiContentState.empty(title: context.t.spotlightsEmpty)
                  else ...<Widget>[
                    if ((state.details?.spotlight ??
                            state.catalog
                                .where(
                                  (Spotlight item) =>
                                      item.id == state.selectedId,
                                )
                                .firstOrNull)
                        case final Spotlight selected)
                      _SpotlightSummary(spotlight: selected),
                    UiButton.secondary(
                      label: context.t.spotlightsChoose,
                      icon: Icons.filter_list,
                      onPressed: _choosing ? null : () => _choose(state),
                    ),
                    OsuRulesetSelector(
                      selected: state.ruleset,
                      onChanged: (ProfileRuleset ruleset) => context
                          .read<SpotlightsBloc>()
                          .add(SpotlightRulesetSelected(ruleset)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (state.loading)
            const SliverToBoxAdapter(child: LinearProgressIndicator()),
          if (state.failure case final RankingsFailureKind failure)
            SliverToBoxAdapter(
              child: _Failure(failure, keepingContent: state.details != null),
            ),
          if (state.details case final SpotlightDetails details) ...<Widget>[
            SliverToBoxAdapter(child: _Heading(context.t.spotlightsMaps)),
            if (details.maps.isEmpty)
              SliverToBoxAdapter(
                child: UiContentState.empty(title: context.t.spotlightsNoMaps),
              ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
              sliver: UiSliverCardList(
                itemCount: details.maps.length,
                itemBuilder: (_, int index) {
                  final SpotlightMap map = details.maps[index];
                  return SpotlightNavigationCard(
                    key: ValueKey<String>('map-${map.id}'),
                    onOpen: () =>
                        DepsScope.of(context).appRouter
                            .openBeatmap(context, BeatmapsetParams(map.id)),
                    builder: (VoidCallback? open) => OsuBeatmapCard.compact(
                      title: map.title,
                      artist: map.artist,
                      cover: map.metadata?.coverUri == null
                          ? null
                          : NetworkImage(map.metadata!.coverUri.toString()),
                      facts: BeatmapFacts(metadata: map.metadata),
                      badges: <Widget>[
                        if (map.difficultyCount case final int count)
                          UiBadge.neutral(
                            context.t.spotlightsDifficultyCount(count),
                            icon: Icons.layers_outlined,
                          ),
                      ],
                      onTap: open,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _Heading(context.t.spotlightsRankingLimit),
            ),
            if (details.players.isEmpty)
              SliverToBoxAdapter(
                child: UiContentState.empty(title: context.t.rankingsEmpty),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                UiSpace.lg,
                0,
                UiSpace.lg,
                UiSpace.lg,
              ),
              sliver: UiSliverCardList(
                itemCount: details.players.length,
                itemBuilder: (_, int index) {
                  final SpotlightPlayer player = details.players[index];
                  final LocalizedCount score = LocalizedCount(
                    player.score,
                    locale: Localizations.localeOf(context).toLanguageTag(),
                  );
                  return SpotlightNavigationCard(
                    key: ValueKey<String>('player-${player.id}'),
                    onOpen: () => DepsScope.of(context).appRouter.openProfile(
                      context,
                      ProfileParams(
                        user: ProfileUserId(player.id),
                        ruleset: state.ruleset,
                      ),
                    ),
                    builder: (VoidCallback? open) => Tooltip(
                      message: context.t.rankingsRankedScore(player.score),
                      child: OsuPlayerCard.compact(
                        username: player.name,
                        countryCode: player.country,
                        countryLabel: player.country,
                        avatar: player.avatarUri == null
                            ? null
                            : NetworkImage(player.avatarUri.toString()),
                        team: player.team,
                        rankLabel: context.t.rankingsPosition(index + 1),
                        performanceLabel:
                            '${context.t.profileRankedScoreLabel}: ${score.compact}',
                        onTap: open,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ],
    ),
  );
}

final class _SpotlightSummary extends StatelessWidget {
  const _SpotlightSummary({required this.spotlight});
  final Spotlight spotlight;
  @override
  Widget build(BuildContext context) => UiSurface.card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.md,
      children: <Widget>[
        UiText.titleLarge(spotlight.name),
        SpotlightPeriod(spotlight: spotlight),
        if (spotlight.participantCount case final int count)
          UiMetric.compact(
            label: context.t.spotlightsParticipants,
            value: NumberFormat.decimalPattern(
              Localizations.localeOf(context).toLanguageTag(),
            ).format(count),
            icon: Icons.groups_outlined,
            tone: UiMetricTone.primary,
          ),
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
