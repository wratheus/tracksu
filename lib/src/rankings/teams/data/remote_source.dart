import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/teams/domain/team_ranking.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class TeamRankingsRemoteSource {
  Future<Map<String, dynamic>> load(
    TeamRankingsQuery query, {
    RestClientOptions options = const RestClientOptions(),
  });
}

/// `GET /rankings/{mode}/team` — accepted by osu-web `RankingController`
/// (`TeamStatistics`, 50 per page, at most 10 000 results) but not described
/// in the public API docs: treat the shape as an undocumented contract and
/// fail loudly if it changes. Always ordered by performance: the sort is a
/// path segment only on the website route (`rankings/{mode}/team/score`);
/// the API route is `rankings/{mode}/{type}` and ignores `?sort=`.
final class OsuTeamRankingsRemoteSource implements TeamRankingsRemoteSource {
  const OsuTeamRankingsRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;

  @override
  Future<Map<String, dynamic>> load(
    TeamRankingsQuery query, {
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final RestResponse response = await _client.get(
      path: '/rankings/${query.ruleset.apiValue}/team',
      queryParameters: <String, Object?>{
        'cursor[page]': query.page,
      },
      options: options,
    );
    if (response.statusCode != 200) {
      throw RankingsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
