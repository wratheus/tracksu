import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/navigation/team_navigation.dart';
import 'package:tracksu/src/profile/widgets/profile_details_sections.dart';
import 'package:tracksu/src/profile/widgets/previous_names_button.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/profile/widgets/monthly_history.dart';
import 'package:tracksu/src/_shared/ui/compact_count_metric.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class ProfileSummary extends StatelessWidget {
  const ProfileSummary({
    required this.profile,
    required this.ruleset,
    this.about,
    super.key,
  });
  final Profile profile;
  final ProfileRuleset ruleset;

  /// "About me" sliver, placed between the grades and the statistics.
  final Widget? about;

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
    bool ranked(int? value) => value != null && value > 0;
    // "Not ranked" is an explanation, not a number: small, secondary text.
    String rank(int? value) =>
        ranked(value) ? '#${number.format(value)}' : context.t.profileNotRanked;

    final Widget header = TeamNavigation(
      teamId: profile.details?.team?.id,
      builder: (VoidCallback? openTeam) => OsuPlayerCard.profile(
        username: profile.username,
        supporter: profile.isSupporter,
        online: profile.isOnline,
        countryCode: profile.countryCode,
        countryLabel: context.t.profileCountry(profile.countryCode),
        avatar: AppMedia.image(context, profile.avatarUri),
        cover: profile.coverUri == null
            ? null
            : AppMedia.image(context, profile.coverUri),
        team: profile.details?.team,
        onTeamTap: openTeam,
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
                unavailable: !ranked(statistics.globalRank),
                tone: UiMetricTone.tertiary,
              ),
        metrics: statistics == null
            ? const <UiMetric>[]
            : <UiMetric>[
                UiMetric.compact(
                  label: 'PP',
                  value: decimal.format(statistics.performancePoints),
                  tone: UiMetricTone.primary,
                ),
                UiMetric.compact(
                  label: context.t.profileCountryRankLabel,
                  value: rank(statistics.countryRank),
                  unavailable: !ranked(statistics.countryRank),
                  tone: UiMetricTone.secondary,
                ),
              ],
      ),
    );
    final ProfileDetails? details = profile.details;
    final Widget gap = const SizedBox(height: UiSpace.lg);
    // Order follows osu.ppy.sh: identity, rank history, daily challenge,
    // grades, about, then statistics and achievements.
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            UiSpace.lg,
            UiSpace.lg,
            UiSpace.lg,
            UiSpace.sm,
          ),
          sliver: SliverToBoxAdapter(child: header),
        ),
        if (details != null &&
            (details.followerCount != null ||
                details.mappingFollowerCount != null))
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
            sliver: SliverToBoxAdapter(
              child: _Followers(details: details, number: number),
            ),
          ),
        if (details != null)
          ProfileDetailsSections(
            details: details,
            userId: profile.id,
            parts: const <ProfileDetailsPart>{ProfileDetailsPart.affiliations},
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
          sliver: SliverToBoxAdapter(
            child: _RankHistory(profile: profile, ruleset: ruleset),
          ),
        ),
        if (details != null)
          ProfileDetailsSections(
            details: details,
            userId: profile.id,
            parts: const <ProfileDetailsPart>{ProfileDetailsPart.daily},
          ),
        if (statistics?.gradeCounts case final ProfileGradeCounts grades)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              UiSpace.lg,
              UiSpace.lg,
              UiSpace.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: UiSurface.card(
                child: Semantics(
                  label: context.t.profileGradesTitle,
                  child: Row(
                    children: <Widget>[
                      for (final (String grade, int count) in <(String, int)>[
                        ('SSH', grades.ssh),
                        ('SS', grades.ss),
                        ('SH', grades.sh),
                        ('S', grades.s),
                        ('A', grades.a),
                      ])
                        Expanded(
                          child: Column(
                            spacing: UiSpace.xs,
                            children: <Widget>[
                              OsuGradeBadge(grade: grade, height: 22),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: UiText.labelLarge(number.format(count)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ?about,
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
          sliver: SliverList.list(
            children: <Widget>[
              if (statistics == null) ...<Widget>[
                gap,
                UiContentState.empty(title: context.t.profileNoStatistics),
              ] else ...<Widget>[
                gap,
                UiSurface.card(
                  child: UiSection(
                    title: context.t.profileStatisticsTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: UiSpace.md,
                      children: <Widget>[
                        UiMetricGroup(
                          children: <UiMetric>[
                            UiMetric.compact(
                              label: context.t.profileAccuracyLabel,
                              icon: Icons.gps_fixed,
                              value: percent.format(
                                statistics.hitAccuracy / 100,
                              ),
                            ),
                            UiMetric.compact(
                              label: context.t.profilePlayCountLabel,
                              icon: Icons.play_circle_outline,
                              value: number.format(statistics.playCount),
                            ),
                            UiMetric.compact(
                              label: context.t.profilePlayTimeLabel,
                              icon: Icons.schedule,
                              unavailable: statistics.playTime == null,
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
                        if (statistics.level case final ProfileLevel level)
                          _LevelLine(level: level, locale: locale),
                      ],
                    ),
                  ),
                ),
                if (statistics.rankedScore != null ||
                    statistics.totalScore != null ||
                    statistics.totalHits != null ||
                    statistics.replaysWatched != null) ...<Widget>[
                  gap,
                  UiSurface.card(
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
                ],
              ],
            ],
          ),
        ),
        if (details != null)
          ProfileDetailsSections(
            details: details,
            userId: profile.id,
            parts: const <ProfileDetailsPart>{ProfileDetailsPart.achievements},
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            UiSpace.lg,
            0,
            UiSpace.lg,
            UiSpace.lg,
          ),
          sliver: SliverList.list(
            children: <Widget>[
              if (profile.playHistory case final ProfileMonthlyHistory history
                  when history.months.isNotEmpty) ...<Widget>[
                gap,
                ProfileMonthlyChart(
                  history: history,
                  title: context.t.profilePlayHistoryTitle,
                  bars: true,
                ),
              ],
              if (profile.replayHistory case final ProfileMonthlyHistory history
                  when history.months.isNotEmpty) ...<Widget>[
                gap,
                ProfileMonthlyChart(
                  history: history,
                  title: context.t.profileReplayHistoryTitle,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Friends and mapping subscribers, like the two pills under the header on
/// osu.ppy.sh.
final class _Followers extends StatelessWidget {
  const _Followers({required this.details, required this.number});
  final ProfileDetails details;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: UiSpace.sm,
    runSpacing: UiSpace.sm,
    children: <Widget>[
      if (details.followerCount case final int count)
        _CountPill(
          icon: Icons.person_rounded,
          value: number.format(count),
          label: context.t.profileFollowers(count),
        ),
      if (details.mappingFollowerCount case final int count)
        _CountPill(
          icon: Icons.notifications_rounded,
          value: number.format(count),
          label: context.t.profileMappingFollowers(count),
        ),
    ],
  );
}

final class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(UiShape.control * 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpace.md,
            vertical: UiSpace.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: UiSpace.sm,
            children: <Widget>[Icon(icon, size: 18), UiText.labelLarge(value)],
          ),
        ),
      ),
    ),
  );
}

/// Level as a quiet line at the end of the statistics card.
final class _LevelLine extends StatelessWidget {
  const _LevelLine({required this.level, required this.locale});
  final ProfileLevel level;
  final String locale;

  @override
  Widget build(BuildContext context) => Row(
    spacing: UiSpace.sm,
    children: <Widget>[
      UiText.bodySmall(context.t.profileLevel(level.current), secondary: true),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: level.progress / 100,
            minHeight: 3,
            semanticsLabel: context.t.profileLevel(level.current),
            semanticsValue: NumberFormat.percentPattern(locale)
                .format(level.progress / 100),
          ),
        ),
      ),
      UiText.bodySmall('${level.progress}%', secondary: true),
    ],
  );
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
