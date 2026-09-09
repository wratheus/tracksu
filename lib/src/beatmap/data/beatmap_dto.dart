import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/beatmaps/data/beatmap_metadata_dto.dart';
import 'package:tracksu/src/_shared/content/data/content_page_dto.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

final class BeatmapDetailsDto {
  const BeatmapDetailsDto._(this.details);
  final BeatmapDetails details;

  factory BeatmapDetailsDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final int id = reader.requiredInt('id', positive: true);
    final List<BeatmapDifficulty> difficulties = <BeatmapDifficulty>[];
    final Set<int> ids = <int>{};
    for (final Object? item in reader.requiredList('beatmaps')) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Expected beatmap.');
      }
      final JsonMapReader map = JsonMapReader(item);
      final int mapId = map.requiredInt('id', positive: true);
      final double stars = map.requiredDouble('difficulty_rating');
      final int length = map.requiredInt('total_length');
      final double? bpm = map.optionalDouble('bpm');
      if (!ids.add(mapId) ||
          map.requiredInt('beatmapset_id') != id ||
          !stars.isFinite ||
          stars < 0 ||
          length < 0) {
        throw const FormatException('Invalid beatmap identity or difficulty.');
      }
      difficulties.add(
        BeatmapDifficulty(
          id: mapId,
          name: map.requiredString('version'),
          ruleset: switch (map.requiredString('mode')) {
            'osu' => ProfileRuleset.osu,
            'taiko' => ProfileRuleset.taiko,
            'fruits' => ProfileRuleset.fruits,
            'mania' => ProfileRuleset.mania,
            _ => throw const FormatException('Unknown ruleset.'),
          },
          stars: stars,
          lengthSeconds: length,
          bpm: bpm != null && bpm.isFinite && bpm > 0 ? bpm : null,
        ),
      );
    }
    return BeatmapDetailsDto._(
      BeatmapDetails(
        id: id,
        title: reader.requiredString('title'),
        artist: reader.requiredString('artist'),
        creator: reader.requiredString('creator'),
        difficulties: difficulties,
        metadata: BeatmapMetadataDto.fromJson(json).toDomain(),
        description: switch (json['description']) {
          null => null,
          final Map<String, dynamic> value => ContentPageDto.beatmap(
            value,
          ).toDomain(Uri.https('osu.ppy.sh', '/beatmapsets/$id')),
          _ => const ContentPageDto.unavailable().toDomain(
            Uri.https('osu.ppy.sh', '/beatmapsets/$id'),
          ),
        },
      ),
    );
  }

  BeatmapDetails toDomain() => details;
}
