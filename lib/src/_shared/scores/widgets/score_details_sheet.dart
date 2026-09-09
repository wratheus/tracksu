import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/_shared/scores/domain/score_details.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Read-only snapshot; caller owns map navigation after this sheet returns.
final class ScoreDetailsSheet extends StatelessWidget {
  const ScoreDetailsSheet({
    required this.score,
    required this.canOpenMap,
    this.playerLabel,
    super.key,
  });
  final OsuScore score;
  final bool canOpenMap;
  final String? playerLabel;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    final NumberFormat settingNumber = NumberFormat.decimalPattern(locale)
      ..maximumFractionDigits = 16;
    final NumberFormat decimal = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    final List<({String mod, ScoreModSetting setting})> settings =
        <({String mod, ScoreModSetting setting})>[
          for (final ScoreMod mod in score.mods)
            for (final ScoreModSetting setting in mod.settings)
              (mod: mod.acronym, setting: setting),
        ];
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            UiSpace.lg,
            0,
            UiSpace.lg,
            UiSpace.xl,
          ),
          sliver: SliverMainAxisGroup(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: UiSpace.md,
                  children: <Widget>[
                    UiText.titleLarge(
                      playerLabel ??
                          score.beatmapTitle ??
                          context.t.scoresBeatmap(score.beatmapId),
                    ),
                    if (score.artist case final String artist)
                      UiText.bodyMedium(artist, secondary: true),
                    if (score.difficulty case final String difficulty)
                      UiText.bodyMedium(difficulty),
                    UiText.bodySmall(
                      OsuRulesetSelector.label(context, score.ruleset),
                      secondary: true,
                    ),
                    Wrap(
                      spacing: UiSpace.md,
                      runSpacing: UiSpace.sm,
                      children: <Widget>[
                        OsuGradeBadge(
                          grade: score.rank,
                          label: context.t.scoresGrade(score.rank),
                        ),
                        if (!score.passed)
                          UiBadge.negative(context.t.scoresFailedPlay),
                      ],
                    ),
                    UiMetric.row(
                      label: context.t.profilePpLabel,
                      value: score.performancePoints == null
                          ? context.t.scoresNoPp
                          : decimal.format(score.performancePoints),
                      tone: UiMetricTone.primary,
                    ),
                    UiMetric.row(
                      label: context.t.profileAccuracyLabel,
                      value: NumberFormat.decimalPercentPattern(
                        locale: locale,
                        decimalDigits: 2,
                      ).format(score.accuracy),
                    ),
                    UiMetric.row(
                      label: context.t.profileComboLabel,
                      value: '${number.format(score.maximumCombo)}×',
                    ),
                    UiMetric.row(
                      label: context.t.scoreStandardisedTotal,
                      value: number.format(score.totalScore),
                    ),
                    OsuMods(
                      mods: score.mods
                          .map((ScoreMod mod) => mod.acronym)
                          .toList(growable: false),
                      emptyLabel: context.t.scoresNoMods,
                    ),
                    UiText.bodySmall(
                      context.t.scoresPlayedAt(
                        DateFormat.yMMMd(locale)
                            .add_Hms()
                            .format(score.endedAt.toLocal()),
                      ),
                      secondary: true,
                    ),
                    if (canOpenMap)
                      UiButton.primary(
                        label: context.t.scoreOpenBeatmap,
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          if (ModalRoute.of(context)?.isCurrent == true) {
                            Navigator.of(context).pop(true);
                          }
                        },
                      ),
                    UiText.titleMedium(context.t.scoreHitsTitle),
                    UiText.bodySmall(
                      context.t.scoreHitsExplanation,
                      secondary: true,
                    ),
                    if (score.hitCounts.isEmpty)
                      UiText.bodySmall(
                        context.t.scoreDetailsUnavailable,
                        secondary: true,
                      ),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: score.hitCounts.length,
                itemBuilder: (BuildContext context, int index) {
                  final ScoreHitCount hit = score.hitCounts[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: UiSpace.sm),
                    child: UiSurface.inset(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: UiSpace.xs,
                        children: <Widget>[
                          UiText.labelLarge(hit.kind),
                          UiMetric.row(
                            label: context.t.scoreHitsAchieved,
                            value: hit.achieved == null
                                ? context.t.profileValueUnavailable
                                : number.format(hit.achieved),
                          ),
                          if (hit.maximum case final int maximum)
                            UiMetric.row(
                              label: context.t.scoreHitsMaximum,
                              value: number.format(maximum),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: UiSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: UiSpace.sm,
                    children: <Widget>[
                      UiText.titleMedium(context.t.scoreModSettingsTitle),
                      UiText.bodySmall(
                        context.t.scoreModSettingsExplanation,
                        secondary: true,
                      ),
                      if (settings.isEmpty)
                        UiText.bodySmall(
                          context.t.scoreNoModSettings,
                          secondary: true,
                        ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: settings.length,
                itemBuilder: (BuildContext context, int index) {
                  final (:String mod, :ScoreModSetting setting) =
                      settings[index];
                  final String value = switch (setting.value) {
                    ScoreModBool(:final value) =>
                      value
                          ? context.t.scoreSettingEnabled
                          : context.t.scoreSettingDisabled,
                    ScoreModNumber(:final value) => settingNumber.format(value),
                    ScoreModText(:final value) => value,
                    ScoreModUnsupported() => context.t.scoreDetailsUnavailable,
                  };
                  return Padding(
                    padding: const EdgeInsets.only(top: UiSpace.sm),
                    child: UiSurface.inset(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: UiSpace.xs,
                        children: <Widget>[
                          UiText.labelLarge('$mod · ${setting.name}'),
                          UiText.bodyMedium(value),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
