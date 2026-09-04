import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/spotlights/domain/spotlight.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class SpotlightsRemoteSource {
  Future<Map<String, dynamic>> catalog({required RestClientOptions options});
  Future<Map<String, dynamic>> load(
    SpotlightQuery query, {
    required RestClientOptions options,
  });
}

final class OsuSpotlightsRemoteSource implements SpotlightsRemoteSource {
  const OsuSpotlightsRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;
  @override
  Future<Map<String, dynamic>> catalog({
    required RestClientOptions options,
  }) async {
    final RestResponse response = await _client.get(
      path: '/spotlights',
      options: options,
    );
    if (response.statusCode != 200) {
      throw RankingsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }

  @override
  Future<Map<String, dynamic>> load(
    SpotlightQuery query, {
    required RestClientOptions options,
  }) async {
    final RestResponse response = await _client.get(
      path: '/rankings/${query.ruleset.apiValue}/charts',
      queryParameters: <String, Object?>{
        'spotlight': query.id,
        'filter': 'all',
      },
      options: options,
    );
    if (response.statusCode != 200) {
      throw RankingsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
