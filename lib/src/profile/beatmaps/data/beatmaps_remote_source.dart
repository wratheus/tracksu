import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class ProfileBeatmapsRemoteSource {
  Future<List<dynamic>> load(
    ProfileBeatmapsQuery query, {
    RestClientOptions options = const RestClientOptions(),
  });
}

final class OsuProfileBeatmapsRemoteSource
    implements ProfileBeatmapsRemoteSource {
  factory OsuProfileBeatmapsRemoteSource({required RestClient restClient}) =>
      OsuProfileBeatmapsRemoteSource._(restClient);

  const OsuProfileBeatmapsRemoteSource._(this._restClient);

  final RestClient _restClient;

  @override
  Future<List<dynamic>> load(
    ProfileBeatmapsQuery query, {
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final String type = switch (query.type) {
      ProfileBeatmapsType.mostPlayed => 'most_played',
      ProfileBeatmapsType.favourite => 'favourite',
      ProfileBeatmapsType.ranked => 'ranked',
      ProfileBeatmapsType.pending => 'pending',
      ProfileBeatmapsType.graveyard => 'graveyard',
      ProfileBeatmapsType.loved => 'loved',
      ProfileBeatmapsType.guest => 'guest',
      ProfileBeatmapsType.nominated => 'nominated',
    };
    final RestResponse response = await _restClient.get(
      path: '/users/${query.user.value}/beatmapsets/$type',
      queryParameters: <String, Object?>{
        'limit': query.limit,
        'offset': query.offset,
      },
      options: options,
    );
    if (response.statusCode != 200) {
      throw ProfileBeatmapsRemoteException(response.statusCode);
    }
    return response.payload.asList();
  }
}

final class ProfileBeatmapsRemoteException implements Exception {
  const ProfileBeatmapsRemoteException(this.statusCode);
  final int statusCode;
}
