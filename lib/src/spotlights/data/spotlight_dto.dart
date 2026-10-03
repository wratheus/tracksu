import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/spotlights/domain/spotlight.dart';
import 'package:tracksu/src/_shared/beatmaps/data/beatmap_metadata_dto.dart';
import 'package:tracksu/src/profile/data/profile_details_dto.dart';
import 'package:tracksu/src/profile/data/profile_details_mapper.dart';

final class SpotlightDto {
  const SpotlightDto._(this._value);
  factory SpotlightDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final int? participants = reader.optionalInt('participant_count');
    if (participants != null && participants < 0) {
      throw const FormatException('Invalid spotlight participant count.');
    }
    // Dates are independent descriptive fields (see Spotlight.startDate);
    // their relative order is not validated, as osu-web does not either.
    return SpotlightDto._(
      Spotlight(
        id: reader.requiredInt('id', positive: true),
        name: reader.requiredString('name'),
        kind: SpotlightKind.fromApi(reader.optionalString('type')),
        startDate: _date(reader.optionalString('start_date')),
        endDate: _date(reader.optionalString('end_date')),
        participantCount: participants,
      ),
    );
  }

  /// `json_time` ISO-8601 with offset; a malformed value is a broken contract.
  static DateTime? _date(String? value) =>
      value == null ? null : DateTime.parse(value).toUtc();

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
          team: (() {
            try {
              return ProfileDetailsDto.fromJson(<String, dynamic>{
                'team': user['team'],
              }).toDomain().team;
            } on FormatException {
              // Optional affiliation must not hide a valid ranking row.
              return null;
            }
          })(),
        ),
      );
    }
    final List<SpotlightMap> maps = <SpotlightMap>[];
    for (final Object? item in reader.requiredList('beatmapsets')) {
      final JsonMapReader map = JsonMapReader(JsonMapReader.asMap(item));
      maps.add(
        SpotlightMap(
          id: map.requiredInt('id', positive: true),
          title: map.requiredString('title'),
          artist: map.requiredString('artist'),
          metadata: BeatmapMetadataDto.fromJson(JsonMapReader.asMap(item))
              .toDomain(),
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
