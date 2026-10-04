import 'dart:io';

import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/beatmaps/data/beatmap_metadata_dto.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/daily/data/remote_source.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu/src/profile/data/profile_details_dto.dart';
import 'package:tracksu/src/profile/data/profile_details_mapper.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class DailyChallengeRepositoryImpl implements DailyChallengeRepository {
  const DailyChallengeRepositoryImpl({
    required DailyChallengeRemoteSource remoteSource,
  }) : _source = remoteSource;
  final DailyChallengeRemoteSource _source;

  @override
  Future<DailyChallenge?> today() =>
      _guard(() async => decodeRooms(await _source.activeRooms()));

  @override
  Future<List<DailyChallengeScore>> leaderboard(int roomId) =>
      _guard(() async => decodeLeaderboard(await _source.leaderboard(roomId)));

  Future<T> _guard<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on DailyChallengeRemoteException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const DailyChallengeFailure(DailyChallengeFailureKind.unavailable),
        stackTrace,
      );
    } on OAuthRemoteSourceException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const DailyChallengeFailure(DailyChallengeFailureKind.unavailable),
        stackTrace,
      );
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const DailyChallengeFailure(DailyChallengeFailureKind.invalidResponse),
        stackTrace,
      );
    } on Object catch (error, stackTrace) {
      if (error is RestClientException || error is IOException) {
        Error.throwWithStackTrace(
          const DailyChallengeFailure(DailyChallengeFailureKind.connection),
          stackTrace,
        );
      }
      rethrow;
    }
  }

  /// The rooms index is a JSON array for response versions before the
  /// cursor format; an object with `rooms` is accepted too.
  static DailyChallenge? decodeRooms(Object? raw) {
    final List<dynamic> rooms = switch (raw) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map => JsonMapReader(map).requiredList(
        'rooms',
      ),
      _ => throw const FormatException('Unexpected rooms payload.'),
    };
    for (final Object? item in rooms) {
      final JsonMapReader room = JsonMapReader(JsonMapReader.asMap(item));
      if (room.optionalString('category') != 'daily_challenge') continue;
      final Map<String, dynamic>? current = room.optionalMap(
        'current_playlist_item',
      );
      if (current == null) continue;
      final JsonMapReader entry = JsonMapReader(current);
      final JsonMapReader beatmap = JsonMapReader(
        entry.optionalMap('beatmap') ??
            (throw const FormatException('Missing daily beatmap.')),
      );
      final Map<String, dynamic>? set = beatmap.optionalMap('beatmapset');
      final double stars = beatmap.requiredDouble('difficulty_rating');
      if (!stars.isFinite || stars < 0) {
        throw const FormatException('Invalid star rating.');
      }
      final int participants = room.optionalInt('participant_count') ?? 0;
      return DailyChallenge(
        roomId: room.requiredInt('id', positive: true),
        beatmapId: entry.requiredInt('beatmap_id', positive: true),
        ruleset: _ruleset(entry.requiredInt('ruleset_id')),
        title: set == null
            ? beatmap.requiredString('version')
            : JsonMapReader(set).requiredString('title'),
        artist: set == null ? '' : JsonMapReader(set).requiredString('artist'),
        version: beatmap.requiredString('version'),
        stars: stars,
        requiredMods: <String>[
          for (final Object? mod
              in entry.optionalList('required_mods') ?? const <Object?>[])
            JsonMapReader(JsonMapReader.asMap(mod)).requiredString('acronym'),
        ],
        startsAt: _date(room.optionalString('starts_at')),
        endsAt: _date(room.optionalString('ends_at')),
        participantCount: participants < 0 ? null : participants,
        metadata: set == null ? null : BeatmapMetadataDto.fromJson(set).toDomain(),
      );
    }
    return null;
  }

  static List<DailyChallengeScore> decodeLeaderboard(Map<String, dynamic> raw) {
    final List<DailyChallengeScore> scores = <DailyChallengeScore>[];
    for (final Object? item in JsonMapReader(raw).requiredList('leaderboard')) {
      final JsonMapReader row = JsonMapReader(JsonMapReader.asMap(item));
      final Map<String, dynamic> user =
          row.optionalMap('user') ??
          (throw const FormatException('Missing leaderboard user.'));
      final JsonMapReader person = JsonMapReader(user);
      final String? avatar = person.optionalString('avatar_url');
      final Uri? avatarUri = avatar == null ? null : Uri.tryParse(avatar);
      final int total = row.requiredInt('total_score');
      final double accuracy = row.requiredDouble('accuracy');
      if (total < 0 || !accuracy.isFinite || accuracy < 0 || accuracy > 1) {
        throw const FormatException('Invalid leaderboard values.');
      }
      scores.add(
        DailyChallengeScore(
          position: scores.length + 1,
          userId: person.requiredInt('id', positive: true),
          username: person.requiredString('username'),
          country: person.requiredString('country_code'),
          totalScore: total,
          accuracy: accuracy,
          attempts: row.optionalInt('attempts') ?? 0,
          avatarUri:
              avatarUri != null &&
                  avatarUri.isScheme('https') &&
                  avatarUri.host.isNotEmpty
              ? avatarUri
              : null,
          team: (() {
            try {
              return ProfileDetailsDto.fromJson(<String, dynamic>{
                'team': user['team'],
              }).toDomain().team;
            } on FormatException {
              return null; // Optional affiliation must not hide a row.
            }
          })(),
        ),
      );
    }
    return scores;
  }

  static ProfileRuleset _ruleset(int id) => switch (id) {
    0 => ProfileRuleset.osu,
    1 => ProfileRuleset.taiko,
    2 => ProfileRuleset.fruits,
    3 => ProfileRuleset.mania,
    _ => throw const FormatException('Unknown ruleset.'),
  };

  static DateTime? _date(String? value) =>
      value == null ? null : DateTime.parse(value).toUtc();
}
