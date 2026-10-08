import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/daily/bloc/bloc.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Past daily challenges, newest first: date, map, difficulty, ruleset,
/// stars, required mods and participants. A day opens its own page with the
/// final leaderboard. Pull to refresh; older days load near the end.
final class DailyHistoryScreen extends StatelessWidget {
  const DailyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(context.t.dailyHistory),
      actions: <Widget>[
        AppBarActions(share: ShareTarget.dailyHistory(context.t.dailyHistory)),
      ],
      bottom: UiAppBarProgressSlot(
        child: BlocSelector<DailyHistoryBloc, DailyHistoryState, bool>(
          selector: (DailyHistoryState state) =>
              state.busy && state.items != null,
          builder: (BuildContext context, bool busy) => UiAppBarProgress(
            visible: busy,
            semanticsLabel: context.t.dailyHistory,
          ),
        ),
      ),
    ),
    body: UiScrollToTop(
      tooltip: context.t.scrollToTop,
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async => context.read<DailyHistoryBloc>().add(
            const DailyHistoryRequested(),
          ),
          child: CustomScrollView(
            primary: true,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              BlocBuilder<DailyHistoryBloc, DailyHistoryState>(
                builder: (BuildContext context, DailyHistoryState state) {
                  final List<DailyChallenge>? days = state.items;
                  if (days == null) {
                    return SliverToBoxAdapter(
                      child: state.failure == null
                          ? UiPageSkeleton.list(label: context.t.dailyHistory)
                          : UiContentState.error(
                              title: context.t.dailyFailed,
                              actionLabel: context.t.retry,
                              onAction: () => context
                                  .read<DailyHistoryBloc>()
                                  .add(const DailyHistoryRequested()),
                            ),
                    );
                  }
                  return SliverMainAxisGroup(
                    slivers: <Widget>[
                      if (days.isEmpty)
                        SliverToBoxAdapter(
                          child: UiContentState.empty(
                            title: context.t.dailyHistoryEmpty,
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.all(UiSpace.lg),
                        sliver: UiSliverCardList(
                          itemCount: days.length,
                          itemBuilder: (BuildContext context, int index) =>
                              _DayCard(
                                key: ValueKey<int>(days[index].roomId),
                                day: days[index],
                              ),
                        ),
                      ),
                      if (!state.done && !state.busy && state.failure == null)
                        UiSliverAutoLoad(
                          pageKey: state.limit,
                          label: context.t.dailyHistory,
                          onLoad: () => context.read<DailyHistoryBloc>().add(
                            const DailyHistoryMoreRequested(),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            UiSpace.lg,
                            0,
                            UiSpace.lg,
                            UiSpace.xl,
                          ),
                          child: switch (state) {
                            DailyHistoryState(busy: true) => UiLoading(
                              label: context.t.dailyHistory,
                            ),
                            DailyHistoryState(failure: _?) => UiNotice(
                              message: context.t.dailyFailed,
                              tone: UiNoticeTone.warning,
                              actionLabel: context.t.retry,
                              onAction: () => context
                                  .read<DailyHistoryBloc>()
                                  .add(const DailyHistoryRetryRequested()),
                            ),
                            _
                                when state.done &&
                                    state.limit >= DailyHistoryBloc.max =>
                              UiText.bodySmall(
                                context.t.dailyHistoryLimit,
                                secondary: true,
                              ),
                            _ => const SizedBox.shrink(),
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Compact day row: a date block (day number over month) on the left, the
/// map on the right; no cover so a month of days fits a couple of screens.
final class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, super.key});
  final DailyChallenge day;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String locale = context.t.localeName;
    final DateTime? date = day.startsAt?.toLocal();
    return UiSurface.card(
      padding: const EdgeInsets.all(UiSpace.md),
      onTap: () {
        final deps = DepsScope.of(context);
        deps.pageCache.write(
          dailyRoomCacheKey(day.roomId),
          day,
          revision: deps.pageCache.revision,
        );
        deps.appRouter.openPastDailyChallenge(context, day.roomId);
      },
      child: Row(
        spacing: UiSpace.md,
        children: <Widget>[
          SizedBox(
            width: 52,
            child: Column(
              children: <Widget>[
                UiText.headlineSmall(
                  date == null ? '—' : DateFormat.d(locale).format(date),
                  color: colors.primary,
                ),
                UiText.labelSmall(
                  date == null ? '' : DateFormat.MMM(locale).format(date),
                  secondary: true,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.xs,
              children: <Widget>[
                UiText.titleSmall(
                  day.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                UiText.bodySmall(
                  <String>[
                    if (day.artist.isNotEmpty) day.artist,
                    day.version,
                  ].join(' · '),
                  secondary: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Wrap(
                  spacing: UiSpace.sm,
                  runSpacing: UiSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    SizedBox.square(
                      dimension: 20,
                      child: FittedBox(
                        child: OsuRulesetIcon(ruleset: day.ruleset),
                      ),
                    ),
                    OsuStarBadge(
                      stars: day.stars,
                      label: NumberFormat.decimalPatternDigits(
                        locale: locale,
                        decimalDigits: 2,
                      ).format(day.stars),
                    ),
                    if (day.requiredMods.isNotEmpty)
                      OsuMods(
                        mods: day.requiredMods,
                        emptyLabel: context.t.scoresNoMods,
                      ),
                    if (day.participantCount case final int count)
                      UiText.labelSmall(
                        context.t.dailyParticipants(count),
                        secondary: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
