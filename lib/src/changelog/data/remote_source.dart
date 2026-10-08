import 'package:tracksu/src/changelog/domain/changelog.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class ChangelogRemoteSource {
  Future<Map<String, dynamic>> load(
    ChangelogQuery query, {
    RestClientOptions options = const RestClientOptions(),
  });
}

/// `GET /changelog?stream=&max_id=&message_formats[]=html`. osu-web returns
/// up to 21 builds per call plus every stream with its latest build.
final class OsuChangelogRemoteSource implements ChangelogRemoteSource {
  const OsuChangelogRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;

  @override
  Future<Map<String, dynamic>> load(
    ChangelogQuery query, {
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final RestResponse response = await _client.get(
      path: '/changelog',
      queryParameters: <String, Object?>{
        'stream': ?query.stream,
        'max_id': ?query.maxId,
        'message_formats[]': 'html',
      },
      options: options,
    );
    if (response.statusCode != 200) {
      throw ChangelogRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}

final class ChangelogRemoteException implements Exception {
  const ChangelogRemoteException(this.statusCode);
  final int statusCode;
}
