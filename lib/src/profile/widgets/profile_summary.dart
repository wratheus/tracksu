import 'package:flutter/material.dart';
import 'package:tracksu/src/profile/widgets/profile_details_sections.dart';
import 'package:tracksu/src/profile/widgets/previous_names_button.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/profile/widgets/monthly_history.dart';
import 'package:tracksu/src/_shared/ui/compact_count_metric.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class ProfileSummary extends StatelessWidget {
  const ProfileSummary({
    required this.profile,
    required this.ruleset,
    super.key,
  });
  final Profile profile;
  final ProfileRuleset ruleset;

  @override
  Widget build(BuildContext context) {
    final ProfileStatistics? statistics = profile.statistics;
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    final NumberFormat decimal = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    );
    final NumberFormat percent = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: 2,
    );
    String rank(int? value) => value == null || value <= 0
        ? context.t.profileUnranked
        : '#${number.format(value)}';

    final Widget header = OsuPlayerCard.profile(
      username: profile.username,
      countryCode: profile.countryCode,
      countryLabel: context.t.profileCountry(profile.countryCode),
      avatar: NetworkImage(profile.avatarUri.toString()),
      cover: profile.coverUri == null
          ? null
          : NetworkImage(profile.coverUri.toString()),
      team: profile.details?.team,
      nameAction: profile.details?.previousNames?.isNotEmpty == true
          ? PreviousNamesButton(names: profile.details!.previousNames!)
          : null,
      statusLabel: profile.isOnline
          ? context.t.profileOnline
          : context.t.profileOffline,
      rankLabel: context.t.profileId(profile.id),
      featuredMetric: statistics == null
          ? null
          : UiMetric(
              label: context.t.profileGlobalRankLabel,
              value: rank(statistics.globalRank),
              tone: UiMetricTone.tertiary,
            ),
      metrics: statistics == null
          ? const <UiMetric>[]
          : <UiMetric>[
              UiMetric.compact(
                label: context.t.profilePpLabel,
                value: decimal.format(statistics.performancePoints),
                tone: UiMetricTone.primary,
              ),
              UiMetric.compact(
                label: context.t.profileCountryRankLabel,
                value: rank(statistics.countryRank),
                tone: UiMetricTone.secondary,
              ),
            ],
    );
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(UiSpace.lg),
          sliver: SliverToBoxAdapter(child: header),
        ),
        if (profile.details case final details?)
          ProfileDetailsSections(details: details, userId: profile.id),
        SliverPadding(
          padding: const EdgeInsets.all(UiSpace.lg),
          sliver: SliverList.list(
            children: <Widget>[
              if (statistics == null)
                UiContentState.empty(title: context.t.profileNoStatistics)
              else ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: UiSpace.lg),
                  child: UiSurface.card(
                    child: UiSection(
                      title: context.t.profileStatisticsTitle,
                      child: UiMetricGroup(
                        children: <UiMetric>[
                          UiMetric.compact(
                            label: context.t.profileAccuracyLabel,
                            icon: Icons.gps_fixed,
                            value: percent.format(statistics.hitAccuracy / 100),
                          ),
                          UiMetric.compact(
                            label: context.t.profilePlayCountLabel,
                            icon: Icons.play_circle_outline,
                            value: number.format(statistics.playCount),
                          ),
                          UiMetric.compact(
                            label: context.t.profilePlayTimeLabel,
                            icon: Icons.schedule,
                            value: statistics.playTime == null
                                ? context.t.profileValueUnavailable
                                : context.t.profileDuration(
                                    statistics.playTime! ~/ 3600,
                                    statistics.playTime! % 3600 ~/ 60,
                                  ),
                          ),
                          UiMetric.compact(
                            label: context.t.profileComboLabel,
                            icon: Icons.bolt,
                            value: number.format(statistics.maximumCombo),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (statistics.level case final ProfileLevel level)
                  Padding(
                    padding: const EdgeInsets.only(top: UiSpace.lg),
                    child: UiSurface.card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: UiSpace.md,
                        children: <Widget>[
                          UiText.titleMedium(
                            context.t.profileLevel(level.current),
                          ),
                          LinearProgressIndicator(
                            value: level.progress / 100,
                            semanticsLabel: context.t.profileLevel(
                              level.current,
                            ),
                            semanticsValue: NumberFormat.percentPattern(locale)
                                .format(level.progress / 100),
                          ),
                          UiText.bodySmall(
                            context.t.profileLevelProgress(level.progress),
                            secondary: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (statistics.gradeCounts case final ProfileGradeCounts grades)
                  Padding(
                    padding: const EdgeInsets.only(top: UiSpace.lg),
                    child: UiSurface.card(
                      child: UiSection(
                        title: context.t.profileGradesTitle,
                        child: Wrap(
                          spacing: UiSpace.lg,
                          runSpacing: UiSpace.md,
                          children: <Widget>[
                            for (final (String grade, int count)
                                in <(String, int)>[
                                  ('SSH', grades.ssh),
                                  ('SS', grades.ss),
                                  ('SH', grades.sh),
                                  ('S', grades.s),
                                  ('A', grades.a),
                                ])
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: UiSpace.sm,
                                children: <Widget>[
                                  OsuGradeBadge(grade: grade, label: grade),
                                  UiText.titleMedium(number.format(count)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (statistics.rankedScore != null ||
                    statistics.totalScore != null ||
                    statistics.totalHits != null ||
                    statistics.replaysWatched != null)
                  Padding(
                    padding: const EdgeInsets.only(top: UiSpace.lg),
                    child: UiSurface.card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: UiSpace.md,
                        children: <Widget>[
                          if (statistics.rankedScore case final int value)
                            CompactCountMetric(
                              label: context.t.profileRankedScoreLabel,
                              icon: Icons.emoji_events_outlined,
                              value: value,
                            ),
                          if (statistics.totalScore case final int value)
                            CompactCountMetric(
                              label: context.t.profileTotalScoreLabel,
                              icon: Icons.leaderboard_outlined,
                              value: value,
                            ),
                          if (statistics.totalHits case final int value)
                            CompactCountMetric(
                              label: context.t.profileTotalHitsLabel,
                              icon: Icons.touch_app_outlined,
                              value: value,
                            ),
                          if (statistics.replaysWatched case final int value)
                            CompactCountMetric(
                              label: context.t.profileReplaysLabel,
                              icon: Icons.visibility_outlined,
                              value: value,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: UiSpace.lg),
                child: _RankHistory(profile: profile, ruleset: ruleset),
              ),
              if (profile.playHistory case final ProfileMonthlyHistory history
                  when history.months.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: UiSpace.lg),
                  child: ProfileMonthlyChart(
                    history: history,
                    title: context.t.profilePlayHistoryTitle,
                    bars: true,
                  ),
                ),
              if (profile.replayHistory case final ProfileMonthlyHistory history
                  when history.months.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: UiSpace.lg),
                  child: ProfileMonthlyChart(
                    history: history,
                    title: context.t.profileReplayHistoryTitle,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _RankHistory extends StatelessWidget {
  const _RankHistory({required this.profile, required this.ruleset});
  final Profile profile;
  final ProfileRuleset ruleset;

  @override
  Widget build(BuildContext context) {
    final ProfileRankHistory? history = profile.rankHistory;
    final List<int?> ranks = history?.ruleset == ruleset
        ? history!.ranks
        : const <int?>[];
    final NumberFormat number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final List<UiChartPoint> points = <UiChartPoint>[
      for (int index = 0; index < ranks.length; index++)
        if (ranks[index] case final int rank)
          UiChartPoint(
            x: index.toDouble(),
            value: rank.toDouble(),
            label: context.t.profileHistorySample(index + 1),
            valueLabel: '#${number.format(rank)}',
            breakBefore: index > 0 && ranks[index - 1] == null,
          ),
    ];
    return UiSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.sm,
        children: <Widget>[
          UiChart.line(
            key: ValueKey<(int, ProfileRuleset)>((profile.id, ruleset)),
            title: context.t.profileHistoryTitle,
            emptyLabel: context.t.profileHistoryEmpty,
            points: points,
            lowerIsBetter: true,
            tone: UiChartTone.tertiary,
          ),
          if (points.isNotEmpty)
            UiText.bodySmall(
              context.t.profileHistoryExplanation,
              secondary: true,
            ),
        ],
      ),
    );
  }
}
