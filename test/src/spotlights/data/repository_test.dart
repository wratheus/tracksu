import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/spotlights/data/remote_source.dart';
import 'package:tracksu/src/spotlights/data/repository_impl.dart';
import 'package:tracksu/src/spotlights/domain/spotlight.dart';
import 'package:tracksu_network/tracksu_network.dart';

// Minimal projection of the documented charts response, no network or tokens.
Map<String, dynamic> _response() => <String, dynamic>{
  'spotlight': <String, dynamic>{'id': 1, 'name': 'Test chart'},
  'ranking': <dynamic>[
    <String, dynamic>{
      'ranked_score': 123456,
      'user': <String, dynamic>{
        'id': 2,
        'username': 'Player',
        'country_code': 'AU',
      },
    },
  ],
  'beatmapsets': <dynamic>[
    <String, dynamic>{'id': 3, 'title': 'Map', 'artist': 'Artist'},
  ],
};

final class _Source implements SpotlightsRemoteSource {
  _Source(this.response);
  final Map<String, dynamic> response;

  @override
  Future<Map<String, dynamic>> load(
    SpotlightQuery query, {
    required RestClientOptions options,
  }) async => response;

  @override
  Future<Map<String, dynamic>> catalog({
    required RestClientOptions options,
  }) async => response;
}

Future<SpotlightDetails> _load(Map<String, dynamic> response) =>
    SpotlightsRepositoryImpl(remoteSource: _Source(response))
        .load(SpotlightQuery(id: 1, ruleset: ProfileRuleset.osu));

void main() {
  test(
    'catalog keeps staff-entered dates verbatim and reads the chart type',
    () async {
      // Real API data (osu-web chart 68 "Best of 2012", checked 2026-10-03):
      // osu-web does not validate start/end order and shows both as given.
      final SpotlightsRepositoryImpl repository = SpotlightsRepositoryImpl(
        remoteSource: _Source(<String, dynamic>{
          'spotlights': <dynamic>[
            <String, dynamic>{
              'id': 276,
              'name': 'Current chart',
              'type': 'monthly',
              'mode_specific': true,
              'start_date': '2020-01-01T00:00:00+00:00',
              'end_date': '2020-01-31T00:00:00+00:00',
            },
            <String, dynamic>{
              'id': 68,
              'name': 'Best of 2012',
              'type': 'bestof',
              'mode_specific': true,
              'start_date': '2013-02-01T00:00:00+00:00',
              'end_date': '2013-01-31T00:00:00+00:00',
            },
            <String, dynamic>{
              'id': 1,
              'name': 'Future kind',
              'type': 'something-new',
              'mode_specific': false,
              'start_date': null,
              'end_date': null,
            },
          ],
        }),
      );

      final List<Spotlight> catalog = await repository.catalog();

      expect(catalog.map((Spotlight item) => item.id), <int>[276, 68, 1]);
      expect(catalog[1].kind, SpotlightKind.bestOf);
      expect(catalog[1].startDate, DateTime.utc(2013, 2));
      expect(catalog[1].endDate, DateTime.utc(2013, 1, 31));
      expect(catalog[0].kind, SpotlightKind.monthly);
      expect(catalog[2].kind, SpotlightKind.other);
      expect(catalog[2].startDate, isNull);
    },
  );

  test('a malformed date is a broken contract, not a missing value', () async {
    final SpotlightsRepositoryImpl repository = SpotlightsRepositoryImpl(
      remoteSource: _Source(<String, dynamic>{
        'spotlights': <dynamic>[
          <String, dynamic>{
            'id': 2,
            'name': 'Broken',
            'type': 'monthly',
            'start_date': 'yesterday',
          },
        ],
      }),
    );
    await expectLater(
      repository.catalog(),
      throwsA(
        isA<RankingsFailure>().having(
          (RankingsFailure failure) => failure.kind,
          'kind',
          RankingsFailureKind.invalidResponse,
        ),
      ),
    );
  });

  test(
    'charts preserve score, player and map; explicit empty lists are valid',
    () async {
      final SpotlightDetails details = await _load(_response());
      expect(details.players.single.score, 123456);
      expect(details.players.single.id, 2);
      expect(details.maps.single.id, 3);

      final SpotlightDetails empty = await _load(<String, dynamic>{
        ..._response(),
        'ranking': <dynamic>[],
        'beatmapsets': <dynamic>[],
      });
      expect(empty.players, isEmpty);
      expect(empty.maps, isEmpty);
    },
  );

  test(
    'missing or malformed maps fail instead of becoming a partial success',
    () async {
      for (final Map<String, dynamic> response in <Map<String, dynamic>>[
        _response()..remove('beatmapsets'),
        <String, dynamic>{
          ..._response(),
          'beatmapsets': <dynamic>[null],
        },
        <String, dynamic>{
          ..._response(),
          'beatmapsets': <dynamic>[
            <String, dynamic>{'id': 3},
          ],
        },
      ]) {
        await expectLater(
          _load(response),
          throwsA(
            isA<RankingsFailure>().having(
              (RankingsFailure failure) => failure.kind,
              'kind',
              RankingsFailureKind.invalidResponse,
            ),
          ),
        );
      }
    },
  );

  test('duplicate players or maps do not silently alter the chart', () async {
    for (final String field in <String>['ranking', 'beatmapsets']) {
      final Map<String, dynamic> response = _response();
      final List<dynamic> items = response[field] as List<dynamic>;
      items.add(items.single);

      await expectLater(
        _load(response),
        throwsA(
          isA<RankingsFailure>().having(
            (RankingsFailure failure) => failure.kind,
            'kind',
            RankingsFailureKind.invalidResponse,
          ),
        ),
      );
    }
  });
}
