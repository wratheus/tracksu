import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';

final class OsuScoreCard extends StatelessWidget {
  const OsuScoreCard({required this.score, this.onTap, super.key});
  final OsuScore score;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(score.endedAt.toLocal());
    return OsuPlayCard(
      title: score.beatmapTitle ?? context.t.scoresBeatmap(score.beatmapId),
      artist: score.artist,
      difficulty: score.difficulty,
      grade: score.rank,
      gradeLabel: context.t.scoresGrade(score.rank),
      accuracyLabel: context.t.profileAccuracy(score.accuracy * 100),
      comboLabel: context.t.scoresCombo(score.maximumCombo),
      performanceLabel: score.performancePoints == null
          ? context.t.scoresNoPp
          : context.t.profilePerformance(score.performancePoints!),
      totalLabel: context.t.scoresTotal(score.totalScore),
      failureLabel: score.passed ? null : context.t.scoresFailedPlay,
      mods: score.mods,
      noModsLabel: context.t.scoresNoMods,
      dateLabel: context.t.scoresPlayedAt(date),
      onTap: onTap,
    );
  }
}
