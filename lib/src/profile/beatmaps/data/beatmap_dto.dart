import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';

/// Projects either BeatmapPlaycount or BeatmapsetExtended, chosen by endpoint.
final class ProfileBeatmapDto {
  const ProfileBeatmapDto._({
    required this.id,
    required this.isBeatmapset,
    this.title,
    this.artist,
    this.difficulty,
    this.playCount,
  });

  factory ProfileBeatmapDto.fromJson(
    Map<String, dynamic> json, {
    required ProfileBeatmapsType type,
  }) {
    final JsonMapReader reader = JsonMapReader(json);
    if (type != ProfileBeatmapsType.mostPlayed) {
      return ProfileBeatmapDto._(
        id: reader.requiredInt('id', positive: true),
        isBeatmapset: true,
        title: reader.requiredString('title'),
        artist: reader.requiredString('artist'),
      );
    }

    final int id = reader.requiredInt('beatmap_id', positive: true);
    final int count = reader.requiredInt('count');
    if (count < 0) {
      throw const FormatException('Play count must be non-negative.');
    }
    final Map<String, dynamic>? beatmap = reader.optionalMap('beatmap');
    final Map<String, dynamic>? set = reader.optionalMap('beatmapset');
    final JsonMapReader? mapReader = beatmap == null
        ? null
        : JsonMapReader(beatmap);
    if (mapReader != null &&
        mapReader.requiredInt('id', positive: true) != id) {
      throw const FormatException('Beatmap ID does not match play count.');
    }
    final JsonMapReader? setReader = set == null ? null : JsonMapReader(set);
    if (setReader != null &&
        mapReader != null &&
        setReader.requiredInt('id', positive: true) !=
            mapReader.requiredInt('beatmapset_id', positive: true)) {
      throw const FormatException('Beatmapset ID does not match beatmap.');
    }
    return ProfileBeatmapDto._(
      id: id,
      isBeatmapset: false,
      title: setReader?.requiredString('title'),
      artist: setReader?.requiredString('artist'),
      difficulty: mapReader?.requiredString('version'),
      playCount: count,
    );
  }

  final int id;
  final bool isBeatmapset;
  final String? title;
  final String? artist;
  final String? difficulty;
  final int? playCount;

  ProfileBeatmap toDomain() => ProfileBeatmap(
    id: id,
    isBeatmapset: isBeatmapset,
    title: title,
    artist: artist,
    difficulty: difficulty,
    playCount: playCount,
  );
}
