import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/daily/data/repository_impl.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// Shape of osu-web RoomTransformer for `GET /rooms?category=daily_challenge`
/// with `x-api-version: 20240529` and the current_playlist_item includes.
Map<String, dynamic> _room({
  String category = 'daily_challenge',
  Object? current = const <String, dynamic>{},
}) => <String, dynamic>{
  'id': 1234567,
  'category': category,
  'starts_at': '2026-10-04T00:00:00+00:00',
  'ends_at': '2026-10-05T00:00:00+00:00',
  'participant_count': 15423,
  'current_playlist_item': current == const <String, dynamic>{}
      ? <String, dynamic>{
          'id': 1,
          'beatmap_id': 42,
          'ruleset_id': 1,
          'required_mods': <Object?>[
            <String, dynamic>{'acronym': 'HR'},
            <String, dynamic>{'acronym': 'DT', 'settings': <String, dynamic>{}},
          ],
          'beatmap': <String, dynamic>{
            'id': 42,
            'version': 'Oni',
            'difficulty_rating': 5.37,
            'beatmapset': <String, dynamic>{
              'id': 7,
              'title': 'Song',
              'artist': 'Artist',
              'covers': <String, dynamic>{},
            },
          },
        }
      : current,
};

Map<String, dynamic> _row(int id, {int score = 1000, double acc = .97}) =>
    <String, dynamic>{
      'accuracy': acc,
      'attempts': 3,
      'completed': 2,
      'pp': 0,
      'room_id': 1234567,
      'total_score': score,
      'user_id': id,
      'user': <String, dynamic>{
        'id': id,
        'username': 'player$id',
        'country_code': 'JP',
        'avatar_url': 'https://a.ppy.sh/$id',
      },
    };

void main() {
  group('decodeRooms', () {
    test('reads the active daily challenge', () {
      final DailyChallenge? challenge =
          DailyChallengeRepositoryImpl.decodeRooms(<Object?>[_room()]);
      expect(challenge, isNotNull);
      expect(challenge!.roomId, 1234567);
      expect(challenge.beatmapId, 42);
      expect(challenge.ruleset, ProfileRuleset.taiko);
      expect(challenge.title, 'Song');
      expect(challenge.artist, 'Artist');
      expect(challenge.version, 'Oni');
      expect(challenge.stars, 5.37);
      expect(challenge.requiredMods, <String>['HR', 'DT']);
      expect(challenge.participantCount, 15423);
      expect(challenge.endsAt, DateTime.utc(2026, 10, 5));
    });

    test('accepts the object form with rooms', () {
      expect(
        DailyChallengeRepositoryImpl.decodeRooms(<String, dynamic>{
          'rooms': <Object?>[_room()],
        })?.roomId,
        1234567,
      );
    });

    test('no active challenge is null, not an error', () {
      expect(DailyChallengeRepositoryImpl.decodeRooms(<Object?>[]), isNull);
      expect(
        DailyChallengeRepositoryImpl.decodeRooms(<Object?>[
          _room(category: 'normal'),
          _room(current: null),
        ]),
        isNull,
      );
    });

    test('broken contract is a FormatException', () {
      expect(
        () => DailyChallengeRepositoryImpl.decodeRooms('rooms'),
        throwsFormatException,
      );
      expect(
        () => DailyChallengeRepositoryImpl.decodeRooms(<Object?>[
          _room(current: <String, dynamic>{'beatmap_id': 42, 'ruleset_id': 0}),
        ]),
        throwsFormatException,
      );
    });
  });

  test('history keeps order, deduplicates and skips non-daily rooms', () {
    final days = DailyChallengeRepositoryImpl.decodeHistory([
      {..._room(), 'id': 3},
      {..._room(), 'id': 2},
      {..._room(), 'id': 3},
      _room(category: 'normal'),
      _room(current: null),
    ]);
    expect(days.map((d) => d.roomId), [3, 2]);
  });

  group('decodeLeaderboard', () {
    test('keeps API order as positions', () {
      final List<DailyChallengeScore> scores =
          DailyChallengeRepositoryImpl.decodeLeaderboard(<String, dynamic>{
            'leaderboard': <Object?>[_row(5, score: 900), _row(9, score: 800)],
            'user_score': null,
          });
      expect(scores.map((DailyChallengeScore s) => s.position), <int>[1, 2]);
      expect(scores.first.userId, 5);
      expect(scores.first.username, 'player5');
      expect(scores.first.country, 'JP');
      expect(scores.first.accuracy, .97);
      expect(scores.first.avatarUri, Uri.parse('https://a.ppy.sh/5'));
      expect(scores.first.team, isNull);
    });

    test('invalid values are a FormatException', () {
      expect(
        () => DailyChallengeRepositoryImpl.decodeLeaderboard(<String, dynamic>{
          'leaderboard': <Object?>[_row(5, acc: 1.5)],
        }),
        throwsFormatException,
      );
    });
  });
}
