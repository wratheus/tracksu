import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/teams/data/remote_source.dart';
import 'package:tracksu/src/rankings/teams/data/repository_impl.dart';
import 'package:tracksu/src/rankings/teams/domain/team_ranking.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// Shape of osu-web TeamStatisticsTransformer with `team` and
/// `member_count` includes (RankingController, type=team).
Map<String, dynamic> _row(int id, {Object? team = const <String, dynamic>{}}) =>
    <String, dynamic>{
      'team_id': id,
      'ruleset_id': 0,
      'play_count': 1000,
      'ranked_score': 123456789,
      'performance': 98765.4,
      'member_count': 42,
      'team': team == const <String, dynamic>{}
          ? <String, dynamic>{
              'id': id,
              'name': 'Team $id',
              'short_name': 'T$id',
              'flag_url': 'https://assets.ppy.sh/teams/flag/$id/x.png',
            }
          : team,
    };

final class _Source implements TeamRankingsRemoteSource {
  _Source(this.response);
  final Map<String, dynamic> response;
  TeamRankingsQuery? last;

  @override
  Future<Map<String, dynamic>> load(
    TeamRankingsQuery query, {
    RestClientOptions options = const RestClientOptions(),
  }) async {
    last = query;
    return response;
  }
}

Future<TeamRankingsPage> _load(Map<String, dynamic> response, {int page = 1}) =>
    TeamRankingsRepositoryImpl(remoteSource: _Source(response)).load(
      TeamRankingsQuery(ruleset: ProfileRuleset.osu, page: page),
    );

void main() {
  test('rows keep team, values, members and table position', () async {
    final TeamRankingsPage page = await _load(<String, dynamic>{
      'cursor': <String, dynamic>{'page': 3},
      'ranking': <dynamic>[_row(7), _row(9)],
      'total': 500,
    }, page: 2);

    expect(page.nextPage, 3);
    expect(page.items.map((TeamRankingEntry e) => e.team.id), <int>[7, 9]);
    expect(page.items.first.position, 51);
    expect(page.items.first.memberCount, 42);
    expect(page.items.first.team.shortName, 'T7');
    expect(page.items.first.performance, 98765.4);
  });

  test('a row without its team or with a mismatched id is rejected', () async {
    for (final Map<String, dynamic> row in <Map<String, dynamic>>[
      _row(7, team: null),
      <String, dynamic>{..._row(7), 'team_id': 8},
    ]) {
      await expectLater(
        _load(<String, dynamic>{
          'cursor': null,
          'ranking': <dynamic>[row],
          'total': 1,
        }),
        throwsA(
          isA<RankingsFailure>().having(
            (RankingsFailure f) => f.kind,
            'kind',
            RankingsFailureKind.invalidResponse,
          ),
        ),
      );
    }
  });
}
