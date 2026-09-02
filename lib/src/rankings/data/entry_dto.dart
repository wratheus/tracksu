import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';

final class RankingEntryDto {
  const RankingEntryDto._(this.entry);
  final RankingEntry entry;
  factory RankingEntryDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final Map<String, dynamic>? user = reader.optionalMap('user');
    if (user == null) throw const FormatException('Missing ranking user.');
    final JsonMapReader person = JsonMapReader(user);
    final double pp = reader.requiredDouble('pp');
    final int score = reader.requiredInt('ranked_score');
    if (!pp.isFinite || pp < 0 || score < 0) {
      throw const FormatException('Invalid ranking values.');
    }
    return RankingEntryDto._(
      RankingEntry(
        id: person.requiredInt('id', positive: true),
        username: person.requiredString('username'),
        country: person.requiredString('country_code'),
        pp: pp,
        rankedScore: score,
      ),
    );
  }
  RankingEntry toDomain() => entry;
}
