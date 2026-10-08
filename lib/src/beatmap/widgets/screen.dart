import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/ui/osu_colors.dart';
import 'package:tracksu/src/_shared/beatmaps/widgets/beatmap_cover.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/beatmap_card.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/_shared/ui/page_activity.dart';
import 'package:tracksu/src/_shared/beatmaps/widgets/beatmap_facts.dart';
import 'package:tracksu/src/_shared/content/widgets/content_page_section.dart';
import 'package:tracksu/src/beatmap/bloc/bloc.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';
import 'package:tracksu/src/beatmap/leaderboard/main.dart';
import 'package:tracksu/src/beatmap/leaderboard/widgets/mod_filter.dart';
import 'package:tracksu/src/beatmap/widgets/difficulty_stats.dart';
import 'package:tracksu/src/beatmap/widgets/failure.dart';
import 'package:tracksu/src/comments/domain/comment.dart';
import 'package:tracksu/src/comments/main.dart';
import 'package:tracksu/src/comments/widgets/comments_section.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class BeatmapScreen extends StatelessWidget {
  BeatmapScreen({required this.params, super.key});
  final BeatmapParams params;

  /// Registered by the leaderboard section (PageRefreshTarget).
  final PageRefresh _leaderboardRefresh = PageRefresh();

  @override
  Widget build(BuildContext context) =>
      PageActivityHost(child: Builder(builder: _scaffold));

  Widget _scaffold(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(context.t.beatmapTitle),
      actions: <Widget>[
        BlocBuilder<BeatmapBloc, BeatmapState>(
          builder: (BuildContext context, BeatmapState state) => AppBarActions(
            share: switch (state) {
              BeatmapLoadedState(:final int? selectedId) when selectedId != null =>
                ShareTarget.beatmap(selectedId, state.details.title),
              BeatmapLoadedState() => ShareTarget.beatmapset(
                state.details.id,
                state.details.title,
              ),
              _ => null,
            },
            tools: <Widget>[
              UiIconButton.standard(
                tooltip: context.t.beatmapRefresh,
                icon: Icons.refresh,
                onPressed: state is BeatmapLoadedState && !state.refreshing
                    ? () => context.read<BeatmapBloc>().add(
                        const BeatmapLoadRequested(),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ],
      // Map and leaderboard refreshes share one line under the app bar.
      bottom: UiAppBarProgressSlot(
        child: BlocSelector<BeatmapBloc, BeatmapState, bool>(
          selector: (BeatmapState state) =>
              state is BeatmapLoadedState && state.refreshing,
          builder: (BuildContext context, bool busy) => ListenableBuilder(
            listenable: PageActivityHost.maybeOf(context)!,
            builder: (BuildContext context, _) => UiAppBarProgress(
              visible: busy || PageActivityHost.maybeOf(context)!.busy,
              semanticsLabel: context.t.beatmapRefresh,
            ),
          ),
        ),
      ),
    ),
    body: UiScrollToTop(
      tooltip: context.t.scrollToTop,
      child: SafeArea(
        child: PageRefreshScope(
          refresh: _leaderboardRefresh,
          child: RefreshIndicator(
            // Pull refreshes the map and the selected difficulty's scores.
            onRefresh: () async {
              final BeatmapBloc bloc = context.read<BeatmapBloc>();
              if (bloc.state case BeatmapLoadedState(refreshing: false)) {
                bloc.add(const BeatmapLoadRequested());
              }
              _leaderboardRefresh();
            },
            child: CustomScrollView(
              // Desktop does not inherit the route controller implicitly.
              primary: true,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                BlocBuilder<BeatmapBloc, BeatmapState>(
                  builder: (BuildContext context, BeatmapState state) {
                    void refresh() => context.read<BeatmapBloc>().add(
                      const BeatmapLoadRequested(),
                    );
                    return switch (state) {
                      BeatmapLoadingState() => SliverToBoxAdapter(
                        child: UiPageSkeleton.profile(
                          label: context.t.beatmapTitle,
                        ),
                      ),
                      BeatmapErrorState(:final failure) => SliverToBoxAdapter(
                        child: BeatmapFailureView(
                          failure: failure,
                          onRetry: refresh,
                        ),
                      ),
                      BeatmapLoadedState() => UiSliverReveal(
                        sliver: SliverMainAxisGroup(
                          slivers: <Widget>[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(UiSpace.lg),
                                child: OsuBeatmapCard.featured(
                                  title: state.details.title,
                                  artist: state.details.artist,
                                  banner: BeatmapCover(
                                    uri:
                                        state.details.metadata?.bannerUri ??
                                        state.details.metadata?.coverUri,
                                    preview: state.details.preview,
                                  ),
                                  facts: BeatmapFacts(
                                    metadata: state.details.metadata,
                                  ),
                                ),
                              ),
                            ),
                            if (state.failure case final failure?)
                              SliverToBoxAdapter(
                                child: BeatmapFailureView(
                                  failure: failure,
                                  onRetry: refresh,
                                ),
                              ),
                            if (state.details.difficulties.isEmpty)
                              SliverToBoxAdapter(
                                child: UiContentState.empty(
                                  title: context.t.beatmapNoDifficulties,
                                ),
                              ),
                            // Difficulties right under the map card, then the
                            // (collapsible) description, then the leaderboard.
                            if (state.selectedId != null)
                              SliverToBoxAdapter(
                                child: _DifficultyPicker(state: state),
                              ),
                            if (state.details.description
                                case final description?)
                              SliverPadding(
                                padding: const EdgeInsets.only(top: UiSpace.sm),
                                sliver: ContentPageSection(
                                  key: ValueKey<int>(state.details.id),
                                  page: description,
                                  title: context.t.beatmapDescription,
                                ),
                              ),
                            _ResultsAndComments(
                              setId: state.details.id,
                              leaderboard: switch (state.selectedId) {
                                final int id => _LeaderboardForSelection(
                                  key: ValueKey<int>(id),
                                  params: params,
                                  state: state,
                                  id: id,
                                ),
                                null => null,
                              },
                            ),
                          ],
                        ),
                      ),
                    };
                  },
                ),
                UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

final class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({required this.state});
  final BeatmapLoadedState state;

  Future<void> _choose(BuildContext context) async {
    final BeatmapBloc bloc = context.read<BeatmapBloc>();
    final int? id = await UiModal.scrollable<int>(
      context,
      title: context.t.beatmapDifficulties,
      builder: (BuildContext modalContext) => CustomScrollView(
        primary: true,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(UiSpace.lg),
              child: ShareButton.labelled(
                label: context.t.shareBeatmapAction,
                target: ShareTarget.beatmapset(
                  state.details.id,
                  state.details.title,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: state.details.difficulties.length,
            itemBuilder: (BuildContext context, int index) {
              final BeatmapDifficulty difficulty = _sorted[index];
              return Row(
                children: <Widget>[
                  Expanded(
                    child: UiTile.selection(
                      title: difficulty.name,
                      subtitle: context.t.beatmapDifficultyInfo(
                        difficulty.ruleset.apiValue,
                        difficulty.stars,
                        difficulty.lengthSeconds,
                      ),
                      selected: state.selectedId == difficulty.id,
                      onTap: () {
                        if (ModalRoute.of(modalContext)?.isCurrent == true) {
                          Navigator.of(modalContext).pop(difficulty.id);
                        }
                      },
                    ),
                  ),
                  ShareButton.icon(
                    label: context.t.shareBeatmapAction,
                    target: ShareTarget.beatmap(difficulty.id, difficulty.name),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    if (context.mounted && !bloc.isClosed && id != null) {
      bloc.add(BeatmapSelected(id));
    }
  }

  /// osu-web order: by ruleset, then by star rating.
  List<BeatmapDifficulty> get _sorted =>
      List<BeatmapDifficulty>.of(state.details.difficulties)..sort(
        (BeatmapDifficulty a, BeatmapDifficulty b) =>
            a.ruleset.index != b.ruleset.index
            ? a.ruleset.index.compareTo(b.ruleset.index)
            : a.stars.compareTo(b.stars),
      );

  @override
  Widget build(BuildContext context) {
    final BeatmapDifficulty difficulty = state.details.difficulties.firstWhere(
      (BeatmapDifficulty value) => value.id == state.selectedId,
    );
    final List<BeatmapDifficulty> sorted = _sorted;
    final NumberFormat stars = NumberFormat.decimalPatternDigits(
      locale: Localizations.localeOf(context).toLanguageTag(),
      decimalDigits: 2,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
      child: UiSurface.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: UiSpace.md,
          children: <Widget>[
            Row(
              spacing: UiSpace.sm,
              children: <Widget>[
                UiText.titleMedium(context.t.beatmapDifficulties),
                UiText.titleMedium(
                  NumberFormat.decimalPattern(
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(sorted.length),
                  secondary: true,
                ),
                const Spacer(),
                UiIconButton.standard(
                  tooltip: context.t.beatmapDifficulties,
                  icon: Icons.view_list_outlined,
                  onPressed: state.refreshing ? null : () => _choose(context),
                ),
              ],
            ),
            // One scrollable line of difficulty pips, as on osu.ppy.sh,
            // instead of a wrapped chip per difficulty.
            SizedBox(
              height: _DifficultyPip.extent,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const SizedBox(width: UiSpace.xs),
                itemBuilder: (BuildContext context, int index) {
                  final BeatmapDifficulty item = sorted[index];
                  return _DifficultyPip(
                    key: ValueKey<int>(item.id),
                    difficulty: item,
                    label: '${stars.format(item.stars)} ★ · ${item.name}',
                    selected: item.id == state.selectedId,
                    onTap: state.refreshing
                        ? null
                        : () => context.read<BeatmapBloc>().add(
                            BeatmapSelected(item.id),
                          ),
                  );
                },
              ),
            ),
            Row(
              spacing: UiSpace.sm,
              children: <Widget>[
                OsuStarBadge(
                  stars: difficulty.stars,
                  label: stars.format(difficulty.stars),
                ),
                Expanded(
                  child: UiText.titleMedium(difficulty.name, maxLines: 2),
                ),
              ],
            ),
            // Stars are already in the coloured badge above.
            BeatmapFacts(
              lengthSeconds: difficulty.lengthSeconds,
              bpm: difficulty.bpm,
            ),
            if (difficulty.stats case final BeatmapDifficultyStats stats)
              BeatmapDifficultyStatsView(
                stats: stats,
                ruleset: difficulty.ruleset,
              ),
          ],
        ),
      ),
    );
  }
}

/// Ruleset icon on its star colour; the selected one gets a ring.
final class _DifficultyPip extends StatelessWidget {
  const _DifficultyPip({
    required this.difficulty,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final BeatmapDifficulty difficulty;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Full touch target; the visible disc is smaller.
  static const double extent = 44;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color fill = OsuColors.forStars(difficulty.stars);
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: extent / 2,
          child: SizedBox.square(
            dimension: extent,
            child: Center(
              child: AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : UiMotion.reveal,
                width: selected ? 36 : 30,
                height: selected ? 36 : 30,
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.onSurface : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: IconTheme(
                  data: IconThemeData(
                    color: OsuColors.onStars(difficulty.stars),
                  ),
                  child: OsuRulesetIcon(ruleset: difficulty.ruleset),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _LeaderboardForSelection extends StatefulWidget {
  const _LeaderboardForSelection({
    required this.params,
    required this.state,
    required this.id,
    super.key,
  });
  final BeatmapParams params;
  final BeatmapLoadedState state;
  final int id;

  @override
  State<_LeaderboardForSelection> createState() =>
      _LeaderboardForSelectionState();
}

/// Leaderboard of the selected difficulty with its mod filter; the filter
/// resets with the difficulty (the widget is keyed by it).
final class _LeaderboardForSelectionState
    extends State<_LeaderboardForSelection> {
  List<String> _mods = const <String>[];

  @override
  Widget build(BuildContext context) {
    final BeatmapLoadedState state = widget.state;
    final int id = widget.id;
    final BeatmapDifficulty difficulty = state.details.difficulties.firstWhere(
      (BeatmapDifficulty d) => d.id == id,
    );
    final ProfileRuleset ruleset = switch (widget.params) {
      BeatmapDifficultyParams(:final ruleset) when widget.params.id == id =>
        ruleset ?? difficulty.ruleset,
      _ => difficulty.ruleset,
    };
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            UiSpace.lg,
            UiSpace.md,
            UiSpace.lg,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: LeaderboardModFilter(
              ruleset: ruleset,
              selected: _mods,
              onChanged: (List<String> mods) => setState(() => _mods = mods),
            ),
          ),
        ),
        LeaderboardMain(
          preview: state.details.preview,
          coverUri:
              state.details.metadata?.bannerUri ??
              state.details.metadata?.coverUri,
          key: ValueKey<(int, ProfileRuleset, String)>((
            id,
            ruleset,
            _mods.join(','),
          )),
          query: LeaderboardQuery(beatmapId: id, ruleset: ruleset, mods: _mods),
        ),
      ],
    );
  }
}

enum _LowerTab { results, comments }

/// Results and comments share the bottom of the page behind one switch;
/// comments load the first time their tab opens and survive switching.
final class _ResultsAndComments extends StatefulWidget {
  const _ResultsAndComments({required this.setId, this.leaderboard});
  final int setId;

  /// Null when the set has no difficulty to rank.
  final Widget? leaderboard;

  @override
  State<_ResultsAndComments> createState() => _ResultsAndCommentsState();
}

final class _ResultsAndCommentsState extends State<_ResultsAndComments> {
  _LowerTab _tab = _LowerTab.results;

  @override
  Widget build(BuildContext context) => CommentsScope(
    target: CommentTarget(CommentableType.beatmapset, widget.setId),
    child: SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            UiSpace.lg,
            UiSpace.xl,
            UiSpace.lg,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: UiSegmentedControl<_LowerTab>(
              selected: _tab,
              segments: <UiSegment<_LowerTab>>[
                UiSegment<_LowerTab>(
                  value: _LowerTab.results,
                  label: context.t.beatmapLeaderboard,
                  icon: const Icon(Icons.leaderboard_outlined),
                ),
                UiSegment<_LowerTab>(
                  value: _LowerTab.comments,
                  label: context.t.commentsTitle,
                  icon: const Icon(Icons.forum_outlined),
                ),
              ],
              onChanged: (_LowerTab tab) => setState(() => _tab = tab),
            ),
          ),
        ),
        switch (_tab) {
          _LowerTab.results => widget.leaderboard ?? const SliverToBoxAdapter(),
          _LowerTab.comments => const CommentsSection(showTitle: false),
        },
      ],
    ),
  );
}
