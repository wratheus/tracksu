import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/category_picker.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap_search/bloc/bloc.dart';
import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/beatmaps/widgets/beatmap_card.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

extension BeatmapSearchStatusPresentation on BeatmapSearchStatus {
  IconData get icon => switch (this) {
    BeatmapSearchStatus.leaderboard => Icons.leaderboard_outlined,
    BeatmapSearchStatus.ranked => Icons.verified_outlined,
    BeatmapSearchStatus.qualified => Icons.how_to_reg_outlined,
    BeatmapSearchStatus.loved => Icons.favorite,
    BeatmapSearchStatus.pending => Icons.hourglass_empty,
    BeatmapSearchStatus.wip => Icons.construction_outlined,
    BeatmapSearchStatus.graveyard => Icons.archive_outlined,
    BeatmapSearchStatus.any => Icons.all_inclusive,
  };

  String label(BuildContext context) => switch (this) {
    BeatmapSearchStatus.leaderboard => context.t.beatmapSearchLeaderboard,
    BeatmapSearchStatus.ranked => context.t.beatmapsRanked,
    BeatmapSearchStatus.qualified => context.t.beatmapSearchQualified,
    BeatmapSearchStatus.loved => context.t.beatmapsLoved,
    BeatmapSearchStatus.pending => context.t.beatmapsPending,
    BeatmapSearchStatus.wip => context.t.beatmapSearchWip,
    BeatmapSearchStatus.graveyard => context.t.beatmapsGraveyard,
    BeatmapSearchStatus.any => context.t.beatmapSearchAny,
  };
}

String genreLabel(BuildContext context, BeatmapGenre genre) => switch (genre) {
  BeatmapGenre.any => context.t.beatmapSearchAnyGenre,
  BeatmapGenre.unspecified => context.t.genreUnspecified,
  BeatmapGenre.videoGame => context.t.genreVideoGame,
  BeatmapGenre.anime => context.t.genreAnime,
  BeatmapGenre.rock => context.t.genreRock,
  BeatmapGenre.pop => context.t.genrePop,
  BeatmapGenre.other => context.t.genreOther,
  BeatmapGenre.novelty => context.t.genreNovelty,
  BeatmapGenre.hipHop => context.t.genreHipHop,
  BeatmapGenre.electronic => context.t.genreElectronic,
  BeatmapGenre.metal => context.t.genreMetal,
  BeatmapGenre.classical => context.t.genreClassical,
  BeatmapGenre.folk => context.t.genreFolk,
  BeatmapGenre.jazz => context.t.genreJazz,
};

String languageLabel(BuildContext context, BeatmapLanguage language) =>
    switch (language) {
      BeatmapLanguage.any => context.t.beatmapSearchAnyLanguage,
      BeatmapLanguage.english => context.t.languageEnglish,
      BeatmapLanguage.japanese => context.t.languageJapanese,
      BeatmapLanguage.chinese => context.t.languageChinese,
      BeatmapLanguage.instrumental => context.t.languageInstrumental,
      BeatmapLanguage.korean => context.t.languageKorean,
      BeatmapLanguage.french => context.t.languageFrench,
      BeatmapLanguage.german => context.t.languageGerman,
      BeatmapLanguage.swedish => context.t.languageSwedish,
      BeatmapLanguage.spanish => context.t.languageSpanish,
      BeatmapLanguage.italian => context.t.languageItalian,
      BeatmapLanguage.russian => context.t.languageRussian,
      BeatmapLanguage.polish => context.t.languagePolish,
      BeatmapLanguage.other => context.t.languageOther,
      BeatmapLanguage.unspecified => context.t.languageUnspecified,
    };

/// Map filters and results embedded under the unified search AppBar.
final class BeatmapSearchResults extends StatelessWidget {
  const BeatmapSearchResults({super.key});

  void _update(
    BuildContext context,
    BeatmapSearchQuery Function(BeatmapSearchQuery) change,
  ) {
    final BeatmapSearchBloc bloc = context.read<BeatmapSearchBloc>();
    bloc.add(BeatmapSearchQueryChanged(change(bloc.state.query)));
  }

  @override
  Widget build(BuildContext context) => UiScrollToTop(
    tooltip: context.t.scrollToTop,
    child: SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () async => context.read<BeatmapSearchBloc>().add(
          const BeatmapSearchRefreshRequested(),
        ),
        child: CustomScrollView(
          primary: true,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.all(UiSpace.lg),
              sliver: SliverToBoxAdapter(
                child:
                    BlocSelector<
                      BeatmapSearchBloc,
                      BeatmapSearchState,
                      BeatmapSearchQuery
                    >(
                      selector: (BeatmapSearchState state) => state.query,
                      builder:
                          (
                            BuildContext context,
                            BeatmapSearchQuery query,
                          ) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: UiSpace.md,
                            children: <Widget>[
                              // Same control as the ruleset selector, plus "All".
                              UiSegmentedControl<int>(
                                selected: query.ruleset?.index ?? -1,
                                segments: <UiSegment<int>>[
                                  UiSegment<int>(
                                    value: -1,
                                    label: context.t.beatmapSearchAnyMode,
                                    icon: const Icon(Icons.all_inclusive),
                                  ),
                                  for (final ProfileRuleset ruleset
                                      in ProfileRuleset.values)
                                    UiSegment<int>(
                                      value: ruleset.index,
                                      label: OsuRulesetSelector.label(
                                        context,
                                        ruleset,
                                      ),
                                      icon: OsuRulesetIcon(ruleset: ruleset),
                                    ),
                                ],
                                onChanged: (int index) => _update(
                                  context,
                                  (BeatmapSearchQuery q) => index < 0
                                      ? q.copyWith(anyRuleset: true)
                                      : q.copyWith(
                                          ruleset: ProfileRuleset.values[index],
                                        ),
                                ),
                              ),
                              OsuCategoryPicker<BeatmapSearchStatus>(
                                title: context.t.beatmapSearchStatus,
                                selected: query.status,
                                icon: (BeatmapSearchStatus s) => s.icon,
                                label: (
                                  BuildContext context,
                                  BeatmapSearchStatus s,
                                ) => s.label(context),
                                onSelected: (BeatmapSearchStatus status) =>
                                    _update(
                                      context,
                                      (BeatmapSearchQuery q) =>
                                          q.copyWith(status: status),
                                    ),
                                groups:
                                    const <
                                      OsuCategoryGroup<BeatmapSearchStatus>
                                    >[
                                      OsuCategoryGroup<BeatmapSearchStatus>(
                                        options: BeatmapSearchStatus.values,
                                      ),
                                    ],
                              ),
                              Row(
                                spacing: UiSpace.sm,
                                children: <Widget>[
                                  Expanded(
                                    child: OsuCategoryPicker<BeatmapGenre>(
                                      title: context.t.beatmapSearchGenre,
                                      selected: query.genre,
                                      icon: (_) => Icons.music_note_outlined,
                                      label:
                                          (
                                            BuildContext context,
                                            BeatmapGenre g,
                                          ) => g == BeatmapGenre.any
                                          ? context.t.beatmapSearchAnyGenre
                                          : genreLabel(context, g),
                                      onSelected: (BeatmapGenre genre) =>
                                          _update(
                                            context,
                                            (BeatmapSearchQuery q) =>
                                                q.copyWith(genre: genre),
                                          ),
                                      groups:
                                          const <
                                            OsuCategoryGroup<BeatmapGenre>
                                          >[
                                            OsuCategoryGroup<BeatmapGenre>(
                                              options: BeatmapGenre.values,
                                            ),
                                          ],
                                    ),
                                  ),
                                  Expanded(
                                    child: OsuCategoryPicker<BeatmapLanguage>(
                                      title: context.t.beatmapSearchLanguage,
                                      selected: query.language,
                                      icon: (_) => Icons.translate_rounded,
                                      label:
                                          (
                                            BuildContext context,
                                            BeatmapLanguage l,
                                          ) => l == BeatmapLanguage.any
                                          ? context.t.beatmapSearchAnyLanguage
                                          : languageLabel(context, l),
                                      onSelected: (BeatmapLanguage language) =>
                                          _update(
                                            context,
                                            (BeatmapSearchQuery q) =>
                                                q.copyWith(language: language),
                                          ),
                                      groups:
                                          const <
                                            OsuCategoryGroup<BeatmapLanguage>
                                          >[
                                            OsuCategoryGroup<BeatmapLanguage>(
                                              options: BeatmapLanguage.values,
                                            ),
                                          ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    ),
              ),
            ),
            const _Results(),
            UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
          ],
        ),
      ),
    ),
  );
}

final class _Results extends StatelessWidget {
  const _Results();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BeatmapSearchBloc, BeatmapSearchState>(
        builder: (BuildContext context, BeatmapSearchState state) {
          final List<ProfileBeatmap>? items = state.items;
          if (!state.started) {
            return SliverToBoxAdapter(
              child: state.query.text.length < 2
                  ? UiContentState.empty(title: context.t.unifiedSearchPrompt)
                  : UiPageSkeleton.list(label: context.t.beatmapsLoading),
            );
          }
          if (items == null) {
            return SliverToBoxAdapter(
              child: state.failure == null
                  ? UiPageSkeleton.list(label: context.t.beatmapsLoading)
                  : _Error(more: false),
            );
          }
          return SliverMainAxisGroup(
            slivers: <Widget>[
              if (state.failure != null &&
                  state.failedOperation == BeatmapSearchOperation.refresh)
                const SliverToBoxAdapter(child: _Error(more: false)),
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: UiContentState.empty(
                    title: context.t.beatmapSearchEmpty,
                  ),
                )
              else if (state.total case final int total)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    UiSpace.lg,
                    0,
                    UiSpace.lg,
                    UiSpace.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: UiText.bodySmall(
                      context.t.beatmapSearchFound(total),
                      secondary: true,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                sliver: UiSliverCardList(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) =>
                      ProfileBeatmapCard(
                        key: ValueKey<int>(items[index].id),
                        beatmap: items[index],
                        onTap: () => unawaited(
                          DepsScope.of(context).appRouter.openBeatmap(
                            context,
                            BeatmapsetParams(items[index].id),
                          ),
                        ),
                      ),
                ),
              ),
              if (state.cursor != null &&
                  state.operation == null &&
                  state.failure == null)
                UiSliverAutoLoad(
                  pageKey: (state.query, state.cursor),
                  label: context.t.beatmapsLoading,
                  onLoad: () => context.read<BeatmapSearchBloc>().add(
                    const BeatmapSearchMoreRequested(),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.xl),
                  child: switch (state) {
                    BeatmapSearchState(
                      operation: BeatmapSearchOperation.loadMore,
                    ) =>
                      Padding(
                        padding: const EdgeInsets.all(UiSpace.lg),
                        child: UiLoading(label: context.t.beatmapsLoading),
                      ),
                    BeatmapSearchState(
                      failure: _?,
                      failedOperation: BeatmapSearchOperation.loadMore,
                    ) =>
                      const _Error(more: true),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ),
            ],
          );
        },
      );
}

final class _Error extends StatelessWidget {
  const _Error({required this.more});
  final bool more;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title:
        context.select((BeatmapSearchBloc bloc) => bloc.state.failure) ==
            BeatmapSearchFailureKind.rateLimited
        ? context.t.profileRateLimited
        : context.t.beatmapSearchFailed,
    actionLabel: context.t.retry,
    onAction: () => context.read<BeatmapSearchBloc>().add(
      more
          ? const BeatmapSearchMoreRequested()
          : const BeatmapSearchRefreshRequested(),
    ),
  );
}
