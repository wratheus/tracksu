import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/_shared/beatmaps/widgets/beatmap_facts.dart';

final class ProfileBeatmapCard extends StatelessWidget {
  const ProfileBeatmapCard({required this.beatmap, this.onTap, super.key});
  final ProfileBeatmap beatmap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => OsuBeatmapCard.compact(
    title:
        beatmap.title ??
        (beatmap.isBeatmapset
            ? context.t.beatmapsSetFallback(beatmap.id)
            : context.t.beatmapsMapFallback(beatmap.id)),
    artist: beatmap.artist,
    difficulty: beatmap.difficulty,
    cover: beatmap.metadata?.coverUri == null
        ? null
        : NetworkImage(beatmap.metadata!.coverUri.toString()),
    facts: BeatmapFacts(
      metadata: beatmap.metadata,
      stars: beatmap.stars,
      lengthSeconds: beatmap.lengthSeconds,
    ),
    detail: beatmap.playCount == null
        ? null
        : context.t.beatmapsPlayCount(beatmap.playCount!),
    onTap: onTap,
  );
}
