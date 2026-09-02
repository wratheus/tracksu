/// A list entry, not the full beatmap detail model.
final class ProfileBeatmap {
  const ProfileBeatmap({
    required this.id,
    required this.isBeatmapset,
    this.title,
    this.artist,
    this.difficulty,
    this.playCount,
  });

  /// Beatmap ID for most-played; beatmapset ID for the other categories.
  final int id;
  final bool isBeatmapset;
  final String? title;
  final String? artist;
  final String? difficulty;
  final int? playCount;
}

final class ProfileBeatmapsPage {
  ProfileBeatmapsPage({
    required List<ProfileBeatmap> items,
    required this.nextOffset,
  }) : items = List<ProfileBeatmap>.unmodifiable(items);

  final List<ProfileBeatmap> items;
  final int? nextOffset;
}
