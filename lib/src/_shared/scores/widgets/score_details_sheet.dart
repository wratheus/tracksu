import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/scores/widgets/score_judgements.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/_shared/scores/domain/score_details.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

enum ScoreDetailsAction { beatmap, player }

/// Read-only snapshot; caller owns navigation after this sheet returns.
final class ScoreDetailsSheet extends StatelessWidget {
  const ScoreDetailsSheet({
    required this.score,
    required this.canOpenMap,
    this.canOpenPlayer = false,
    this.playerLabel,
    this.playerAvatar,
    super.key,
  });
  final OsuScore score;
  final bool canOpenMap;
  final bool canOpenPlayer;
  final String? playerLabel;
  final Uri? playerAvatar;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    final NumberFormat settingNumber = NumberFormat.decimalPattern(locale)
      ..maximumFractionDigits = 16;
    final NumberFormat decimal = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    );
    final List<({String mod, ScoreModSetting setting})> settings =
        <({String mod, ScoreModSetting setting})>[
          for (final ScoreMod mod in score.mods)
            for (final ScoreModSetting setting in mod.settings)
              (mod: mod.acronym, setting: setting),
        ];
    return CustomScrollView(
      primary: true,
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
                    if (playerLabel case final String name)
                      Row(
                        spacing: UiSpace.md,
                        children: <Widget>[
                          UiAvatar.medium(
                            name: name,
                            image: playerAvatar == null
                                ? null
                                : NetworkImage(playerAvatar.toString()),
                          ),
                          Expanded(child: UiText.titleMedium(name)),
                        ],
                      ),
                    UiText.titleLarge(
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
                    UiMetricGroup(
                      children: <UiMetric>[
                        UiMetric.compact(
                          label: context.t.profilePpLabel,
                          value: score.performancePoints == null
                              ? context.t.scoresNoPp
                              : decimal.format(score.performancePoints),
                          tone: UiMetricTone.primary,
                        ),
                        UiMetric.compact(
                          label: context.t.profileAccuracyLabel,
                          value: NumberFormat.decimalPercentPattern(
                            locale: locale,
                            decimalDigits: 2,
                          ).format(score.accuracy),
                        ),
                        UiMetric.compact(
                          label: context.t.profileComboLabel,
                          value: '${number.format(score.maximumCombo)}×',
                        ),
                        UiMetric.compact(
                          label: context.t.scoreStandardisedTotal,
                          value: number.format(score.totalScore),
                        ),
                      ],
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
                    Wrap(
                      spacing: UiSpace.sm,
                      runSpacing: UiSpace.sm,
                      children: <Widget>[
                        ShareButton.labelled(
                          target: ShareTarget.score(
                            score.id,
                            context.t.scoreDetailsTitle,
                          ),
                        ),
                        ShareButton.labelled(
                          label: context.t.shareBeatmapAction,
                          target: ShareTarget.beatmap(
                            score.beatmapId,
                            score.beatmapTitle ?? context.t.beatmapTitle,
                          ),
                        ),
                      ],
                    ),
                    if (canOpenPlayer)
                      UiButton.secondary(
                        label: context.t.profileOpen,
                        icon: Icons.person_outline,
                        onPressed: () {
                          if (ModalRoute.of(context)?.isCurrent == true) {
                            Navigator.of(context)
                                .pop(ScoreDetailsAction.player);
                          }
                        },
                      ),
                    if (canOpenMap)
                      UiButton.primary(
                        label: context.t.scoreOpenBeatmap,
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          if (ModalRoute.of(context)?.isCurrent == true) {
                            Navigator.of(context)
                                .pop(ScoreDetailsAction.beatmap);
                          }
                        },
                      ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: UiSpace.lg),
                  child: ScoreJudgements(score: score),
                ),
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
