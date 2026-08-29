import 'package:tracksu/src/profile/scores/domain/scores_query.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class ProfileScoresRemoteSource {
  Future<List<dynamic>> load(
    ProfileScoresQuery query, {
    RestClientOptions options = const RestClientOptions(),
  });
}

final class OsuProfileScoresRemoteSource implements ProfileScoresRemoteSource {
  factory OsuProfileScoresRemoteSource({required RestClient restClient}) =>
      OsuProfileScoresRemoteSource._(restClient);

  const OsuProfileScoresRemoteSource._(this._restClient);
  final RestClient _restClient;

  @override
  Future<List<dynamic>> load(
    ProfileScoresQuery query, {
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final String type = switch (query.type) {
      ProfileScoresType.best => 'best',
      ProfileScoresType.recent => 'recent',
    };
    final RestResponse response = await _restClient.get(
      path: '/users/${query.user.value}/scores/$type',
      queryParameters: <String, Object?>{
        'mode': query.ruleset.apiValue,
        'legacy_only': query.legacy ? 1 : 0,
        if (query.type == ProfileScoresType.recent)
          'include_fails': query.includeFails ? 1 : 0,
        'limit': query.limit,
        'offset': query.offset,
      },
      options: options,
    );
    if (response.statusCode != 200) {
      throw ProfileScoresRemoteException(response.statusCode);
    }
    return response.payload.asList();
  }
}

final class ProfileScoresRemoteException implements Exception {
  const ProfileScoresRemoteException(this.statusCode);
  final int statusCode;
}
