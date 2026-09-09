import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/rankings/spotlights/domain/spotlight.dart';
import 'package:tracksu/src/_shared/beatmaps/data/beatmap_metadata_dto.dart';
import 'package:tracksu/src/profile/data/profile_details_dto.dart';
import 'package:tracksu/src/profile/data/profile_details_mapper.dart';

final class SpotlightDto {
  const SpotlightDto._(this._value);
  factory SpotlightDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final String? start = reader.optionalString('start_date');
    final String? end = reader.optionalString('end_date');
    final DateTime? startsAt = start == null
        ? null
        : DateTime.parse(start).toUtc();
    final DateTime? endsAt = end == null ? null : DateTime.parse(end).toUtc();
    final int? participants = reader.optionalInt('participant_count');
    if ((participants != null && participants < 0) ||
        (startsAt != null && endsAt != null && endsAt.isBefore(startsAt))) {
      throw const FormatException('Invalid spotlight period/count.');
    }
    return SpotlightDto._(
      Spotlight(
        id: reader.requiredInt('id', positive: true),
        name: reader.requiredString('name'),
        startsAt: startsAt,
        endsAt: endsAt,
        participantCount: participants,
      ),
    );
  }
  final Spotlight _value;
  Spotlight toDomain() => _value;
}

final class SpotlightDetailsDto {
  const SpotlightDetailsDto._(this._value);
  factory SpotlightDetailsDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final Map<String, dynamic>? spotlight = reader.optionalMap('spotlight');
    if (spotlight == null) throw const FormatException('Missing spotlight.');
    final List<SpotlightPlayer> players = <SpotlightPlayer>[];
    for (final Object? item in reader.requiredList('ranking')) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid ranking row.');
      }
      final JsonMapReader row = JsonMapReader(item);
      final Map<String, dynamic>? user = row.optionalMap('user');
      if (user == null) throw const FormatException('Missing ranking user.');
      final JsonMapReader person = JsonMapReader(user);
      final String? avatar = person.optionalString('avatar_url');
      final Uri? avatarUri = avatar == null ? null : Uri.tryParse(avatar);
      final int score = row.requiredInt('ranked_score');
      if (score < 0) throw const FormatException('Negative ranked score.');
      players.add(
        SpotlightPlayer(
          id: person.requiredInt('id', positive: true),
          name: person.requiredString('username'),
          country: person.requiredString('country_code'),
          score: score,
          avatarUri:
              avatarUri != null &&
                  avatarUri.scheme == 'https' &&
                  avatarUri.host.isNotEmpty &&
                  avatarUri.userInfo.isEmpty
              ? avatarUri
              : null,
          team: ProfileDetailsDto.fromJson(<String, dynamic>{
            'team': user['team'],
          }).toDomain().team,
        ),
      );
    }
    final List<SpotlightMap> maps = <SpotlightMap>[];
    for (final Object? item in reader.requiredList('beatmapsets')) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid beatmapset.');
      }
      final JsonMapReader map = JsonMapReader(item);
      maps.add(
        SpotlightMap(
          id: map.requiredInt('id', positive: true),
          title: map.requiredString('title'),
          artist: map.requiredString('artist'),
          metadata: BeatmapMetadataDto.fromJson(item).toDomain(),
          difficultyCount: map.optionalList('beatmaps')?.length,
        ),
      );
    }
    if (players.map((SpotlightPlayer item) => item.id).toSet().length !=
            players.length ||
        maps.map((SpotlightMap item) => item.id).toSet().length !=
            maps.length) {
      throw const FormatException('Duplicate spotlight content IDs.');
    }
    return SpotlightDetailsDto._(
      SpotlightDetails(
        spotlight: SpotlightDto.fromJson(spotlight).toDomain(),
        players: players,
        maps: maps,
      ),
    );
  }
  final SpotlightDetails _value;
  SpotlightDetails toDomain() => _value;
}
