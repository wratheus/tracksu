import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';

final class ProfileBeatmapCard extends StatelessWidget {
  const ProfileBeatmapCard({required this.beatmap, super.key});
  final ProfileBeatmap beatmap;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: <Widget>[
          Text(
            beatmap.title ??
                (beatmap.isBeatmapset
                    ? context.t.beatmapsSetFallback(beatmap.id)
                    : context.t.beatmapsMapFallback(beatmap.id)),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (beatmap.artist case final String artist) Text(artist),
          if (beatmap.difficulty case final String difficulty) Text(difficulty),
          if (beatmap.playCount case final int count)
            Text(context.t.beatmapsPlayCount(count)),
        ],
      ),
    ),
  );
}
