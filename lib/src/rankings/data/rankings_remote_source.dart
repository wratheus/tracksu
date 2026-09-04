import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class RankingsRemoteSource {
  Future<Map<String, dynamic>> load(
    RankingsQuery query, {
    RestClientOptions options = const RestClientOptions(),
  });
}

final class OsuRankingsRemoteSource implements RankingsRemoteSource {
  factory OsuRankingsRemoteSource({required RestClient restClient}) =>
      OsuRankingsRemoteSource._(restClient);
  const OsuRankingsRemoteSource._(this._restClient);
  final RestClient _restClient;
  @override
  Future<Map<String, dynamic>> load(
    RankingsQuery query, {
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final RestResponse response = await _restClient.get(
      path: '/rankings/${query.type.mode}/${query.type.sort}',
      queryParameters: <String, Object?>{
        'cursor[page]': query.page,
        'filter': 'all',
        if (query.country case final RankingCountry country)
          'country': country.value,
        if (query.variant.apiValue case final String variant)
          'variant': variant,
      },
      options: options,
    );
    if (response.statusCode != 200) {
      throw RankingsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}

final class RankingsRemoteException implements Exception {
  const RankingsRemoteException(this.statusCode);
  final int statusCode;
}
