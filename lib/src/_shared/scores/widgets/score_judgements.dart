import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/_shared/scores/domain/score_details.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Percentages describe recorded judgments, not combo or whole-map completion.
final class ScoreJudgements extends StatelessWidget {
  const ScoreJudgements({required this.score, super.key});
  final OsuScore score;
  @override
  Widget build(BuildContext context) {
    final Map<String, String> labels = switch (score.ruleset) {
      ProfileRuleset.osu => <String, String>{
        'great': '300',
        'ok': '100',
        'meh': '50',
        'miss': context.t.scoreMiss,
      },
      ProfileRuleset.taiko => <String, String>{
        'great': '300',
        'ok': '150',
        'miss': context.t.scoreMiss,
      },
      ProfileRuleset.mania => <String, String>{
        'perfect': 'MAX',
        'great': '300',
        'good': '200',
        'ok': '100',
        'meh': '50',
        'miss': context.t.scoreMiss,
      },
      ProfileRuleset.fruits => <String, String>{
        'great': context.t.scoreFruit,
        'large_tick_hit': context.t.scoreDroplet,
        'small_tick_hit': context.t.scoreTinyDroplet,
        'miss': context.t.scoreMiss,
        'small_tick_miss': context.t.scoreTinyMiss,
      },
    };
    final List<ScoreHitCount> hits = <ScoreHitCount>[
      for (final String kind in labels.keys)
        ...score.hitCounts.where(
          (ScoreHitCount hit) => hit.kind == kind && hit.achieved != null,
        ),
    ];
    final int total = hits.fold(
      0,
      (int sum, ScoreHitCount hit) => sum + hit.achieved!,
    );
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    final NumberFormat percent = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: 1,
    );
    return UiSurface.inset(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.md,
        children: <Widget>[
          UiChart.bars(
            title: context.t.scoreHitsTitle,
            emptyLabel: context.t.scoreDetailsUnavailable,
            points: <UiChartPoint>[
              for (int i = 0; i < hits.length; i++)
                UiChartPoint(
                  x: i.toDouble(),
                  value: hits[i].achieved!.toDouble(),
                  label: labels[hits[i].kind]!,
                  valueLabel: number.format(hits[i].achieved),
                ),
            ],
          ),
          UiMetricGroup(
            children: <UiMetric>[
              for (final ScoreHitCount hit in hits)
                UiMetric.compact(
                  label: labels[hit.kind]!,
                  value: '${number.format(hit.achieved)}×',
                  detail: total == 0
                      ? null
                      : percent.format(hit.achieved! / total),
                  tone: hit.kind.contains('miss')
                      ? UiMetricTone.neutral
                      : UiMetricTone.primary,
                ),
            ],
          ),
          UiText.bodySmall(
            context.t.scoreJudgementPercentNotice,
            secondary: true,
          ),
        ],
      ),
    );
  }
}
