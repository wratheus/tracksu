import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/_shared/scores/domain/score_details.dart';
import 'package:tracksu/src/_shared/ui/osu_colors.dart';
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
    Color color(String kind) => switch (kind) {
      'miss' => OsuColors.miss,
      'small_tick_miss' => OsuColors.tickMiss,
      'perfect' => OsuColors.perfect,
      'great' => OsuColors.great,
      'good' => OsuColors.good,
      'ok' => OsuColors.ok,
      'large_tick_hit' || 'small_tick_hit' => OsuColors.tick,
      _ => OsuColors.meh,
    };
    // AccuracyCircle uses these lazer reference cutoffs. Never recalculate
    // the API grade from accuracy: misses, mods and legacy scoring also matter.
    final List<double> cutoffs = score.ruleset == ProfileRuleset.fruits
        ? <double>[0, 0.85, 0.9, 0.94, 0.98, 0.99, 1]
        : <double>[0, 0.7, 0.8, 0.9, 0.95, 0.99, 1];
    final List<String> grades = <String>['D', 'C', 'B', 'A', 'S', 'SS'];
    final List<Color> gradeColors = <Color>[
      OsuColors.rankD,
      OsuColors.rankC,
      OsuColors.rankB,
      OsuColors.rankA,
      OsuColors.rankS,
      OsuColors.rankSS,
    ];
    final String accuracy = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: 2,
    ).format(score.accuracy);
    return UiSurface.inset(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.md,
        children: <Widget>[
          UiText.titleMedium(context.t.scoreHitsTitle),
          Tooltip(
            message: context.t.scoreGaugeReference,
            child: UiGradeGauge(
              accuracy: score.accuracy,
              accuracyLabel: accuracy,
              grade: _gradeLabel(score.rank),
              gradeColor: OsuColors.forRank(score.rank),
              semanticLabel:
                  '${context.t.scoresGrade(score.rank)}, ${context.t.profileAccuracyLabel}: $accuracy. ${context.t.scoreGaugeReference}',
              bands: <UiGaugeBand>[
                for (int i = 0; i < grades.length; i++)
                  UiGaugeBand(
                    start: cutoffs[i],
                    end: cutoffs[i + 1],
                    label: grades[i],
                    color: OsuColors.text(context, gradeColors[i]),
                  ),
              ],
            ),
          ),
          for (final ScoreHitCount hit in hits)
            Row(
              spacing: UiSpace.md,
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(Icons.circle, size: 10, color: color(hit.kind)),
                ),
                Expanded(child: UiText.labelLarge(labels[hit.kind]!)),
                UiText.titleMedium(
                  '${number.format(hit.achieved)}×',
                  color: OsuColors.text(context, color(hit.kind)),
                ),
                if (total > 0)
                  UiText.bodySmall(
                    percent.format(hit.achieved! / total),
                    secondary: true,
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

/// API ranks XH/X/SH are silver variants; the letter shown is SS/SS/S.
String _gradeLabel(String rank) => switch (rank.toUpperCase()) {
  'XH' || 'X' => 'SS',
  'SH' => 'S',
  final String other => other,
};
