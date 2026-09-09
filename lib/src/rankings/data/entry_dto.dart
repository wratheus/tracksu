import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';

final class RankingEntryDto {
  const RankingEntryDto._(this.entry);
  final RankingEntry entry;
  factory RankingEntryDto.fromJson(
    Map<String, dynamic> json, {
    required int position,
  }) {
    final JsonMapReader reader = JsonMapReader(json);
    final Map<String, dynamic>? user = reader.optionalMap('user');
    if (user == null) throw const FormatException('Missing ranking user.');
    final JsonMapReader person = JsonMapReader(user);
    final String? avatar = person.optionalString('avatar_url');
    final Uri? avatarUri = avatar == null ? null : Uri.tryParse(avatar);
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
        position: position,
        avatarUri:
            avatarUri != null &&
                avatarUri.isScheme('https') &&
                avatarUri.host.isNotEmpty &&
                avatarUri.userInfo.isEmpty
            ? avatarUri
            : null,
      ),
    );
  }
  RankingEntry toDomain() => entry;
}
