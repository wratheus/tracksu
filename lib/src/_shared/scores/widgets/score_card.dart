import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class OsuScoreCard extends StatefulWidget {
  const OsuScoreCard({
    required this.score,
    this.onTap,
    this.playerLabel,
    super.key,
  });
  final OsuScore score;

  /// A leaderboard already establishes map context, so lead with the player.
  final String? playerLabel;

  /// Optional navigation to the map, offered after inspecting the result.
  final VoidCallback? onTap;

  @override
  State<OsuScoreCard> createState() => _OsuScoreCardState();
}

final class _OsuScoreCardState extends State<OsuScoreCard> {
  bool _detailsOpen = false;
  OsuScore get score => widget.score;
  VoidCallback? get onTap => widget.onTap;

  Future<void> _showDetails(BuildContext context) async {
    if (_detailsOpen) return;
    _detailsOpen = true;
    try {
      final String locale = Localizations.localeOf(context).toLanguageTag();
      final NumberFormat number = NumberFormat.decimalPattern(locale);
      final bool? openMap = await UiModal.sheet<bool>(
        context,
        title: context.t.scoreDetailsTitle,
        builder: (BuildContext context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: UiSpace.lg,
          children: <Widget>[
            UiText.titleLarge(
              widget.playerLabel ??
                  score.beatmapTitle ??
                  context.t.scoresBeatmap(score.beatmapId),
            ),
            if (score.artist case final String artist)
              UiText.bodyMedium(artist, secondary: true),
            if (score.difficulty case final String difficulty)
              UiText.bodyMedium(difficulty),
            Wrap(
              spacing: UiSpace.md,
              runSpacing: UiSpace.sm,
              children: <Widget>[
                OsuGradeBadge(
                  grade: score.rank,
                  label: context.t.scoresGrade(score.rank),
                ),
                if (!score.passed) UiBadge.negative(context.t.scoresFailedPlay),
              ],
            ),
            UiMetric.row(
              label: context.t.profilePpLabel,
              value: score.performancePoints == null
                  ? context.t.scoresNoPp
                  : NumberFormat.decimalPatternDigits(
                      locale: locale,
                      decimalDigits: 2,
                    ).format(score.performancePoints),
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
            OsuMods(mods: score.mods, emptyLabel: context.t.scoresNoMods),
            UiText.bodySmall(
              context.t.scoresPlayedAt(
                DateFormat.yMMMd(locale)
                    .add_Hms()
                    .format(score.endedAt.toLocal()),
              ),
              secondary: true,
            ),
            if (onTap != null)
              UiButton.primary(
                label: context.t.scoreOpenBeatmap,
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (ModalRoute.of(context)?.isCurrent == true) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
          ],
        ),
      );
      if (openMap == true && context.mounted) onTap?.call();
    } finally {
      _detailsOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(score.endedAt.toLocal());
    final String locale = Localizations.localeOf(context).toLanguageTag();
    return OsuPlayCard(
      title:
          widget.playerLabel ??
          score.beatmapTitle ??
          context.t.scoresBeatmap(score.beatmapId),
      artist: score.artist,
      difficulty: score.difficulty,
      grade: score.rank,
      gradeLabel: context.t.scoresGrade(score.rank),
      accuracyLabel: NumberFormat.decimalPercentPattern(
        locale: locale,
        decimalDigits: 2,
      ).format(score.accuracy),
      comboLabel:
          '${NumberFormat.decimalPattern(locale).format(score.maximumCombo)}×',
      performanceLabel: score.performancePoints == null
          ? context.t.scoresNoPp
          : '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 2).format(score.performancePoints)} pp',
      failureLabel: score.passed ? null : context.t.scoresFailedPlay,
      mods: score.mods,
      noModsLabel: context.t.scoresNoMods,
      dateLabel: date,
      onTap: () => _showDetails(context),
    );
  }
}
