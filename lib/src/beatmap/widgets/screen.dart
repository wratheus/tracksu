import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/beatmap_card.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/_shared/beatmaps/widgets/beatmap_facts.dart';
import 'package:tracksu/src/_shared/content/widgets/content_page_section.dart';
import 'package:tracksu/src/beatmap/bloc/bloc.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';
import 'package:tracksu/src/beatmap/leaderboard/main.dart';
import 'package:tracksu/src/beatmap/widgets/failure.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class BeatmapScreen extends StatelessWidget {
  const BeatmapScreen({required this.params, super.key});
  final BeatmapParams params;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(context.t.beatmapTitle),
      actions: <Widget>[
        BlocBuilder<BeatmapBloc, BeatmapState>(
          builder: (BuildContext context, BeatmapState state) =>
              state is BeatmapLoadedState
              ? ShareButton.icon(
                  target: state.selectedId == null
                      ? ShareTarget.beatmapset(
                          state.details.id,
                          state.details.title,
                        )
                      : ShareTarget.beatmap(
                          state.selectedId!,
                          state.details.title,
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    ),
    body: SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          BlocBuilder<BeatmapBloc, BeatmapState>(
            builder: (BuildContext context, BeatmapState state) {
              void refresh() =>
                  context.read<BeatmapBloc>().add(const BeatmapLoadRequested());
              return switch (state) {
                BeatmapLoadingState() => const SliverToBoxAdapter(
                  child: LinearProgressIndicator(),
                ),
                BeatmapErrorState(:final failure) => SliverToBoxAdapter(
                  child: BeatmapFailureView(failure: failure, onRetry: refresh),
                ),
                BeatmapLoadedState() => SliverMainAxisGroup(
                  slivers: <Widget>[
                    if (state.refreshing)
                      const SliverToBoxAdapter(
                        child: LinearProgressIndicator(),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(UiSpace.lg),
                        child: UiSection(
                          title: context.t.beatmapTitle,
                          action: UiButton.text(
                            label: context.t.beatmapRefresh,
                            onPressed: state.refreshing ? null : refresh,
                            icon: Icons.refresh,
                          ),
                          child: OsuBeatmapCard.featured(
                            title: state.details.title,
                            artist: state.details.artist,
                            cover: state.details.metadata?.coverUri == null
                                ? null
                                : NetworkImage(
                                    state.details.metadata!.coverUri.toString(),
                                  ),
                            facts: BeatmapFacts(
                              metadata: state.details.metadata,
                            ),
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
                    if (state.details.description case final description?)
                      ContentPageSection(
                        key: ValueKey<int>(state.details.id),
                        page: description,
                        title: context.t.beatmapDescription,
                      ),
                    if (state.selectedId != null)
                      SliverToBoxAdapter(
                        child: _DifficultyPicker(state: state),
                      ),
                    if (state.selectedId case final int id)
                      _LeaderboardForSelection(
                        key: ValueKey<int>(id),
                        params: params,
                        state: state,
                        id: id,
                      ),
                  ],
                ),
              };
            },
          ),
        ],
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
              final BeatmapDifficulty difficulty =
                  state.details.difficulties[index];
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

  @override
  Widget build(BuildContext context) {
    final BeatmapDifficulty difficulty = state.details.difficulties.firstWhere(
      (BeatmapDifficulty value) => value.id == state.selectedId,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
      child: UiSurface.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: UiSpace.md,
          children: <Widget>[
            UiText.bodySmall(
              OsuRulesetSelector.label(context, difficulty.ruleset),
              secondary: true,
            ),
            UiButton.secondary(
              label: difficulty.name,
              icon: Icons.unfold_more,
              onPressed: state.refreshing ? null : () => _choose(context),
            ),
            BeatmapFacts(
              stars: difficulty.stars,
              lengthSeconds: difficulty.lengthSeconds,
              bpm: difficulty.bpm,
            ),
          ],
        ),
      ),
    );
  }
}

final class _LeaderboardForSelection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final BeatmapDifficulty difficulty = state.details.difficulties.firstWhere(
      (BeatmapDifficulty d) => d.id == id,
    );
    final ProfileRuleset ruleset = switch (params) {
      BeatmapDifficultyParams(:final ruleset) when params.id == id =>
        ruleset ?? difficulty.ruleset,
      _ => difficulty.ruleset,
    };
    return LeaderboardMain(
      key: ValueKey<(int, ProfileRuleset)>((id, ruleset)),
      query: LeaderboardQuery(beatmapId: id, ruleset: ruleset),
    );
  }
}
