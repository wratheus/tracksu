import 'package:tracksu/src/profile/activity/domain/activity.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class ProfileActivityRemoteSource {
  Future<List<dynamic>> load(
    ProfileActivityQuery query, {
    RestClientOptions options = const RestClientOptions(),
  });
}

/// `GET /users/{user}/recent_activity` (scope public): Event[], limit/offset;
/// osu-web stops paging after 100 events.
final class OsuProfileActivityRemoteSource
    implements ProfileActivityRemoteSource {
  const OsuProfileActivityRemoteSource({required this._restClient});
  final RestClient _restClient;

  @override
  Future<List<dynamic>> load(
    ProfileActivityQuery query, {
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final RestResponse response = await _restClient.get(
      path: '/users/${query.user.value}/recent_activity',
      queryParameters: <String, Object?>{
        'limit': query.limit,
        'offset': query.offset,
      },
      options: options,
    );
    if (response.statusCode != 200) {
      throw ProfileActivityRemoteException(response.statusCode);
    }
    return response.payload.asList();
  }
}

final class ProfileActivityRemoteException implements Exception {
  const ProfileActivityRemoteException(this.statusCode);
  final int statusCode;
}
