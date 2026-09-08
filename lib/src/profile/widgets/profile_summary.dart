import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      decimalDigits: 2,
    );
    final NumberFormat percent = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: 2,
    );
    String rank(int? value) => value == null || value <= 0
        ? context.t.profileUnranked
        : '#${number.format(value)}';

    return SliverPadding(
      padding: const EdgeInsets.all(UiSpace.lg),
      sliver: SliverList.list(
        children: <Widget>[
          OsuPlayerCard.profile(
            username: profile.username,
            countryCode: profile.countryCode,
            countryLabel: context.t.profileCountry(profile.countryCode),
            avatar: NetworkImage(profile.avatarUri.toString()),
            cover: profile.coverUri == null
                ? null
                : NetworkImage(profile.coverUri.toString()),
            statusLabel: profile.isOnline
                ? context.t.profileOnline
                : context.t.profileOffline,
            rankLabel: context.t.profileId(profile.id),
            metrics: statistics == null
                ? const <UiMetric>[]
                : <UiMetric>[
                    UiMetric(
                      label: context.t.profilePpLabel,
                      value: decimal.format(statistics.performancePoints),
                    ),
                    UiMetric(
                      label: context.t.profileGlobalRankLabel,
                      value: rank(statistics.globalRank),
                    ),
                    UiMetric(
                      label: context.t.profileCountryRankLabel,
                      value: rank(statistics.countryRank),
                    ),
                  ],
          ),
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
                      UiMetric(
                        label: context.t.profileAccuracyLabel,
                        value: percent.format(statistics.hitAccuracy / 100),
                      ),
                      UiMetric(
                        label: context.t.profilePlayCountLabel,
                        value: number.format(statistics.playCount),
                      ),
                      UiMetric(
                        label: context.t.profilePlayTimeLabel,
                        value: statistics.playTime == null
                            ? context.t.profileValueUnavailable
                            : context.t.profileDuration(
                                statistics.playTime! ~/ 3600,
                                statistics.playTime! % 3600 ~/ 60,
                              ),
                      ),
                      UiMetric(
                        label: context.t.profileComboLabel,
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
                      UiText.titleMedium(context.t.profileLevel(level.current)),
                      LinearProgressIndicator(
                        value: level.progress / 100,
                        semanticsLabel: context.t.profileLevel(level.current),
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
                        for (final (String grade, int count) in <(String, int)>[
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
                    spacing: UiSpace.lg,
                    children: <Widget>[
                      if (statistics.rankedScore case final int value)
                        UiMetric(
                          label: context.t.profileRankedScoreLabel,
                          value: number.format(value),
                        ),
                      if (statistics.totalScore case final int value)
                        UiMetric(
                          label: context.t.profileTotalScoreLabel,
                          value: number.format(value),
                        ),
                      if (statistics.totalHits case final int value)
                        UiMetric(
                          label: context.t.profileTotalHitsLabel,
                          value: number.format(value),
                        ),
                      if (statistics.replaysWatched case final int value)
                        UiMetric(
                          label: context.t.profileReplaysLabel,
                          value: number.format(value),
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
        ],
      ),
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
