import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class KudosuRankingRemoteSource {
  const KudosuRankingRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;

  Future<Map<String, dynamic>> load(int page) async {
    final RestResponse response = await _client.get(
      path: '/rankings/kudosu',
      queryParameters: <String, Object?>{'page': page},
    );
    if (response.statusCode != 200) {
      throw RankingsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
