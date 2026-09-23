import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';
import 'package:tracksu/src/_shared/audio/widgets/audio_track_player.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// One reusable cover/player composition for cards, details and score sheets.
final class BeatmapCover extends StatelessWidget {
  const BeatmapCover({this.uri, this.preview, this.aspectRatio = 3, super.key});
  final Uri? uri;
  final AudioTrack? preview;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.bottomCenter,
    children: <Widget>[
      UiCover(image: AppMedia.image(context, uri), aspectRatio: aspectRatio),
      if (preview case final AudioTrack track)
        Padding(
          padding: const EdgeInsets.all(UiSpace.sm),
          child: AudioTrackPlayer.overlay(
            key: ValueKey<Uri>(track.uri),
            track: track,
            controller: DepsScope.of(context).audioPlaybackController,
          ),
        ),
    ],
  );
}
