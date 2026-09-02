import 'package:tracksu/src/beatmap/data/remote_source.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class LeaderboardRemoteSource {
  factory LeaderboardRemoteSource({required RestClient restClient}) =>
      LeaderboardRemoteSource._(restClient);
  const LeaderboardRemoteSource._(this._restClient);
  final RestClient _restClient;

  Future<Map<String, dynamic>> load(
    LeaderboardQuery query,
    RestClientOptions options,
  ) async {
    final RestResponse response = await _restClient.get(
      path: '/beatmaps/${query.beatmapId}/scores',
      queryParameters: <String, Object?>{
        'mode': query.ruleset.apiValue,
        'legacy_only': query.legacy ? 1 : 0,
        'type': 'global',
      },
      options: options,
    );
    if (response.statusCode != 200) {
      throw BeatmapRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
