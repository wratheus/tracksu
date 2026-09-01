import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/scores/domain/score.dart';

final class ProfileScoreCard extends StatelessWidget {
  const ProfileScoreCard({required this.score, super.key});
  final ProfileScore score;

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(score.endedAt.toLocal());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: <Widget>[
            Text(
              score.beatmapTitle ?? context.t.scoresBeatmap(score.beatmapId),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (score.artist case final String artist) Text(artist),
            if (score.difficulty case final String difficulty) Text(difficulty),
            Wrap(
              spacing: 15,
              runSpacing: 5,
              children: <Widget>[
                Text(context.t.scoresGrade(score.rank)),
                Text(context.t.profileAccuracy(score.accuracy * 100)),
                Text(context.t.scoresCombo(score.maximumCombo)),
                Text(
                  score.performancePoints == null
                      ? context.t.scoresNoPp
                      : context.t.profilePerformance(score.performancePoints!),
                ),
              ],
            ),
            Text(context.t.scoresTotal(score.totalScore)),
            Text(
              score.mods.isEmpty
                  ? context.t.scoresNoMods
                  : context.t.scoresMods(score.mods.join(', ')),
            ),
            if (!score.passed) Text(context.t.scoresFailedPlay),
            Text(context.t.scoresPlayedAt(date)),
          ],
        ),
      ),
    );
  }
}
