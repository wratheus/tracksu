import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';

/// Set-level information. Never confuse these counts with a player's plays.
final class BeatmapMetadata {
  const BeatmapMetadata({
    this.coverUri,
    this.bannerUri,
    this.creator,
    this.status,
    this.plays,
    this.favourites,
    this.preview,
  });
  final Uri? coverUri;
  final Uri? bannerUri;
  final String? creator;
  final String? status;
  final int? plays;
  final int? favourites;
  final AudioTrack? preview;
}
