import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';

/// A list entry, not the full beatmap detail model.
final class ProfileBeatmap {
  const ProfileBeatmap({
    required this.id,
    required this.isBeatmapset,
    this.title,
    this.artist,
    this.difficulty,
    this.playCount,
    this.metadata,
    this.stars,
    this.lengthSeconds,
  });

  /// Beatmap ID for most-played; beatmapset ID for the other categories.
  final int id;
  final bool isBeatmapset;
  final String? title;
  final String? artist;
  final String? difficulty;
  final int? playCount;
  final BeatmapMetadata? metadata;
  final double? stars;
  final int? lengthSeconds;
}

final class ProfileBeatmapsPage {
  ProfileBeatmapsPage({
    required List<ProfileBeatmap> items,
    required this.nextOffset,
  }) : items = List<ProfileBeatmap>.unmodifiable(items);

  final List<ProfileBeatmap> items;
  final int? nextOffset;
}
