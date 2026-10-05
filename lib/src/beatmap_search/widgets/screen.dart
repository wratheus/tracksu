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

/// Beatmap listing: text, ruleset and status; results load page by page as
/// the end nears. Typing searches after a short pause; pull to refresh.
final class BeatmapSearchScreen extends StatefulWidget {
  const BeatmapSearchScreen({this.initialText = '', super.key});
  final String initialText;

  @override
  State<BeatmapSearchScreen> createState() => _BeatmapSearchScreenState();
}

final class _BeatmapSearchScreenState extends State<BeatmapSearchScreen> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initialText,
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _update(BeatmapSearchQuery Function(BeatmapSearchQuery) change) {
    final BeatmapSearchBloc bloc = context.read<BeatmapSearchBloc>();
    bloc.add(BeatmapSearchQueryChanged(change(bloc.state.query)));
  }

  void _typed(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _update((BeatmapSearchQuery q) => q.copyWith(text: value.trim())),
    );
  }

  void _submitted(String value) {
    _debounce?.cancel();
    _update((BeatmapSearchQuery q) => q.copyWith(text: value.trim()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(context.t.beatmapSearchTitle),
      bottom: UiAppBarProgressSlot(
        child: BlocSelector<BeatmapSearchBloc, BeatmapSearchState, bool>(
          selector: (BeatmapSearchState state) =>
              state.items != null &&
              state.operation == BeatmapSearchOperation.refresh,
          builder: (BuildContext context, bool busy) => UiAppBarProgress(
            visible: busy,
            semanticsLabel: context.t.beatmapsLoading,
          ),
        ),
      ),
    ),
    body: UiScrollToTop(
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
                  child: BlocSelector<
                    BeatmapSearchBloc,
                    BeatmapSearchState,
                    BeatmapSearchQuery
                  >(
                    selector: (BeatmapSearchState state) => state.query,
                    builder: (BuildContext context, BeatmapSearchQuery query) =>
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: UiSpace.md,
                          children: <Widget>[
                            UiSearchField(
                              controller: _text,
                              label: context.t.beatmapSearchHint,
                              clearLabel: context.t.searchClear,
                              onChanged: _typed,
                              onSubmitted: _submitted,
                            ),
                            OsuRulesetSelector(
                              selected: query.ruleset,
                              onChanged: (ProfileRuleset ruleset) => _update(
                                (BeatmapSearchQuery q) =>
                                    q.copyWith(ruleset: ruleset),
                              ),
                            ),
                            OsuCategoryPicker<BeatmapSearchStatus>(
                              title: context.t.beatmapSearchStatus,
                              selected: query.status,
                              icon: (BeatmapSearchStatus s) => s.icon,
                              label: (BuildContext context, BeatmapSearchStatus s) =>
                                  s.label(context),
                              onSelected: (BeatmapSearchStatus status) =>
                                  _update(
                                    (BeatmapSearchQuery q) =>
                                        q.copyWith(status: status),
                                  ),
                              groups: const <OsuCategoryGroup<BeatmapSearchStatus>>[
                                OsuCategoryGroup<BeatmapSearchStatus>(
                                  options: BeatmapSearchStatus.values,
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
    title: context.t.beatmapSearchFailed,
    actionLabel: context.t.retry,
    onAction: () => context.read<BeatmapSearchBloc>().add(
      more
          ? const BeatmapSearchMoreRequested()
          : const BeatmapSearchRefreshRequested(),
    ),
  );
}
