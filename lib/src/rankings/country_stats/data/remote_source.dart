import 'package:tracksu/src/rankings/country_stats/domain/country_ranking.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// `GET /rankings/{mode}/country` — documented (RankingType `country`,
/// CountryStatistics). osu-web orders by `performance` only and has no
/// country/variant filters for it; 50 rows per page, `cursor.page`, `total`.
final class OsuCountryRankingsRemoteSource {
  const OsuCountryRankingsRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;

  Future<Map<String, dynamic>> load(
    CountryRankingsQuery query, {
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final RestResponse response = await _client.get(
      path: '/rankings/${query.ruleset.apiValue}/country',
      queryParameters: <String, Object?>{'cursor[page]': query.page},
      options: options,
    );
    if (response.statusCode != 200) {
      throw RankingsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
