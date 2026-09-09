import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/scores/domain/score_details.dart';

final class ScoreStatisticsDto {
  ScoreStatisticsDto._(Map<String, int> counts)
    : counts = Map<String, int>.unmodifiable(counts);
  factory ScoreStatisticsDto.fromJson(Map<String, dynamic> json) {
    if (json.length > 128) {
      throw const FormatException('Too many hit-result types.');
    }
    final JsonMapReader reader = JsonMapReader(json);
    final Map<String, int> counts = <String, int>{};
    for (final String key in json.keys) {
      final int count = reader.requiredInt(key);
      if (key.isEmpty || key.length > 128 || count < 0) {
        throw const FormatException('Invalid hit result.');
      }
      counts[key] = count;
    }
    return ScoreStatisticsDto._(counts);
  }
  final Map<String, int> counts;

  static List<ScoreHitCount> toDomain(
    ScoreStatisticsDto? actual,
    ScoreStatisticsDto? maximum,
  ) {
    final Set<String> keys = <String>{
      ...?actual?.counts.keys,
      ...?maximum?.counts.keys,
    };
    return keys
        .map(
          (String key) => ScoreHitCount(
            kind: key,
            achieved: actual?.counts[key],
            maximum: maximum?.counts[key],
          ),
        )
        .toList(growable: false);
  }
}

final class ScoreModDto {
  ScoreModDto._(this.acronym, Map<String, Object?> settings)
    : settings = Map<String, Object?>.unmodifiable(settings);
  factory ScoreModDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final Map<String, dynamic>? settings = reader.optionalMap('settings');
    if ((settings?.length ?? 0) > 64) {
      throw const FormatException('Too many mod settings.');
    }
    final Map<String, Object?> bounded = <String, Object?>{};
    for (final MapEntry<String, dynamic> entry
        in (settings ?? <String, dynamic>{}).entries) {
      if (entry.key.isEmpty || entry.key.length > 128) {
        throw const FormatException('Invalid setting name.');
      }
      // Do not retain nested/unbounded wire data in the domain or modal.
      bounded[entry.key] = switch (entry.value) {
        final bool value => value,
        final num value when value.isFinite => value,
        final String value when value.length <= 2048 => value,
        _ => null,
      };
    }
    return ScoreModDto._(reader.requiredString('acronym'), bounded);
  }
  final String acronym;
  final Map<String, Object?> settings;
  ScoreMod toDomain() => ScoreMod(
    acronym: acronym,
    settings: settings.entries
        .map(
          (MapEntry<String, Object?> entry) => ScoreModSetting(
            name: entry.key,
            value: switch (entry.value) {
              final bool value => ScoreModBool(value),
              final num value => ScoreModNumber(value),
              final String value => ScoreModText(value),
              _ => const ScoreModUnsupported(),
            },
          ),
        )
        .toList(growable: false),
  );
}
