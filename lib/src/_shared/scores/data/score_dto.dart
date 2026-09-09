import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/beatmaps/data/beatmap_metadata_dto.dart';
import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/_shared/scores/data/score_details_dto.dart';

final class OsuScoreDto {
  const OsuScoreDto({
    required this.id,
    required this.beatmapId,
    required this.userId,
    required this.rulesetId,
    required this.accuracy,
    required this.totalScore,
    required this.maximumCombo,
    required this.rank,
    required this.passed,
    required this.pp,
    required this.endedAt,
    required this.mods,
    this.statistics,
    this.maximumStatistics,
    this.beatmapTitle,
    this.artist,
    this.difficulty,
    this.metadata,
  });

  factory OsuScoreDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final Map<String, dynamic>? beatmap = reader.optionalMap('beatmap');
    final Map<String, dynamic>? beatmapset = reader.optionalMap('beatmapset');
    final int beatmapId = reader.requiredInt('beatmap_id', positive: true);
    if (beatmap != null &&
        JsonMapReader(beatmap).requiredInt('id', positive: true) != beatmapId) {
      throw const FormatException(
        'Nested beatmap does not match score beatmap.',
      );
    }
    final List<ScoreModDto> mods = <ScoreModDto>[];
    for (final Object? item in reader.requiredList('mods')) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Expected a mod object, not a legacy acronym.',
        );
      }
      mods.add(ScoreModDto.fromJson(item));
    }
    if (mods.length > 64) throw const FormatException('Too many score mods.');
    return OsuScoreDto(
      metadata: beatmapset == null
          ? null
          : BeatmapMetadataDto.fromJson(beatmapset),
      id: reader.requiredInt('id', positive: true),
      beatmapId: beatmapId,
      userId: reader.requiredInt('user_id', positive: true),
      rulesetId: reader.requiredInt('ruleset_id'),
      accuracy: reader.requiredDouble('accuracy'),
      totalScore: reader.requiredInt('total_score'),
      maximumCombo: reader.requiredInt('max_combo'),
      rank: reader.requiredString('rank'),
      passed: reader.requiredBool('passed'),
      pp: reader.optionalDouble('pp'),
      endedAt: reader.requiredString('ended_at'),
      mods: List<ScoreModDto>.unmodifiable(mods),
      statistics: switch (reader.optionalMap('statistics')) {
        null => null,
        final Map<String, dynamic> value => ScoreStatisticsDto.fromJson(value),
      },
      maximumStatistics: switch (reader.optionalMap('maximum_statistics')) {
        null => null,
        final Map<String, dynamic> value => ScoreStatisticsDto.fromJson(value),
      },
      beatmapTitle: beatmapset == null
          ? null
          : JsonMapReader(beatmapset).requiredString('title'),
      artist: beatmapset == null
          ? null
          : JsonMapReader(beatmapset).requiredString('artist'),
      difficulty: beatmap == null
          ? null
          : JsonMapReader(beatmap).requiredString('version'),
    );
  }

  final int id;
  final int beatmapId;
  final int userId;
  final int rulesetId;
  final double accuracy;
  final int totalScore;
  final int maximumCombo;
  final String rank;
  final bool passed;
  final double? pp;
  final String endedAt;
  final List<ScoreModDto> mods;
  final ScoreStatisticsDto? statistics;
  final ScoreStatisticsDto? maximumStatistics;
  final String? beatmapTitle;
  final String? artist;
  final String? difficulty;
  final BeatmapMetadataDto? metadata;

  OsuScore toDomain() {
    if (!accuracy.isFinite ||
        accuracy < 0 ||
        accuracy > 1 ||
        totalScore < 0 ||
        maximumCombo < 0) {
      throw const FormatException(
        'Score values are outside their valid range.',
      );
    }
    if (pp case final double value when !value.isFinite || value < 0) {
      throw const FormatException('Invalid performance points.');
    }
    final BeatmapMetadata? map = metadata?.toDomain();
    return OsuScore(
      coverUri: map?.bannerUri ?? map?.coverUri,
      id: id,
      beatmapId: beatmapId,
      userId: userId,
      ruleset: switch (rulesetId) {
        0 => ProfileRuleset.osu,
        1 => ProfileRuleset.taiko,
        2 => ProfileRuleset.fruits,
        3 => ProfileRuleset.mania,
        _ => throw const FormatException('Unknown score ruleset.'),
      },
      accuracy: accuracy,
      totalScore: totalScore,
      maximumCombo: maximumCombo,
      rank: rank,
      passed: passed,
      performancePoints: pp,
      endedAt: DateTime.parse(endedAt).toUtc(),
      mods: mods
          .map((ScoreModDto mod) => mod.toDomain())
          .toList(growable: false),
      hitCounts: ScoreStatisticsDto.toDomain(statistics, maximumStatistics),
      beatmapTitle: beatmapTitle,
      artist: artist,
      difficulty: difficulty,
    );
  }
}
