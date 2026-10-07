import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// The selected difficulty's attributes as osu.ppy.sh shows them: one bar
/// per attribute on a 0–10 scale (only those the ruleset uses), then max
/// combo, object count, plays and pass rate.
final class BeatmapDifficultyStatsView extends StatelessWidget {
  const BeatmapDifficultyStatsView({
    required this.stats,
    required this.ruleset,
    super.key,
  });
  final BeatmapDifficultyStats stats;
  final ProfileRuleset ruleset;

  @override
  Widget build(BuildContext context) {
    final String locale = context.t.localeName;
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    final NumberFormat attribute = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    );
    // osu-web: mania shows keys instead of CS and no AR; taiko neither.
    final List<(String, double, String)> bars = <(String, double, String)>[
      if (ruleset == ProfileRuleset.mania)
        (context.t.beatmapKeys, stats.cs, number.format(stats.cs.round()))
      else if (ruleset != ProfileRuleset.taiko)
        (context.t.beatmapCircleSize, stats.cs, attribute.format(stats.cs)),
      (context.t.beatmapHpDrain, stats.hp, attribute.format(stats.hp)),
      (context.t.beatmapAccuracy, stats.od, attribute.format(stats.od)),
      if (ruleset == ProfileRuleset.osu || ruleset == ProfileRuleset.fruits)
        (context.t.beatmapApproachRate, stats.ar, attribute.format(stats.ar)),
    ];
    final int? objects = switch ((
      stats.circles,
      stats.sliders,
      stats.spinners,
    )) {
      (final int a, final int b, final int c) => a + b + c,
      _ => null,
    };
    final int? plays = stats.playCount;
    final int? passes = stats.passCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.sm,
      children: <Widget>[
        for (final (String label, double value, String text) in bars)
          _AttributeBar(
            label: label,
            fraction: (value / 10).clamp(0, 1).toDouble(),
            value: text,
          ),
        UiMetricGroup(
          children: <UiMetric>[
            if (stats.maxCombo case final int combo)
              UiMetric.compact(
                label: context.t.beatmapMaxCombo,
                value: '${number.format(combo)}×',
              ),
            if (objects != null)
              UiMetric.compact(
                label: context.t.beatmapObjects,
                value: number.format(objects),
              ),
            if (plays != null)
              UiMetric.compact(
                label: context.t.beatmapPlays,
                value: number.format(plays),
              ),
            if (plays != null && passes != null && passes <= plays && plays > 0)
              UiMetric.compact(
                label: context.t.beatmapPassRate,
                value: NumberFormat.decimalPercentPattern(
                  locale: locale,
                  decimalDigits: 1,
                ).format(passes / plays),
              ),
          ],
        ),
      ],
    );
  }
}

final class _AttributeBar extends StatelessWidget {
  const _AttributeBar({
    required this.label,
    required this.fraction,
    required this.value,
  });
  final String label;
  final double fraction;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Row(
        spacing: UiSpace.md,
        children: <Widget>[
          SizedBox(
            width: 112,
            child: UiText.bodySmall(label, secondary: true, maxLines: 2),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: colors.surfaceContainerHighest,
                color: colors.primary,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: UiText.labelLarge(value, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
