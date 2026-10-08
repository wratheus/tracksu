import 'package:tracksu_network/tracksu_network.dart';

final class UserSearchRemoteException implements Exception {
  const UserSearchRemoteException(this.status);
  final int status;
}

final class UserSearchRemoteSource {
  const UserSearchRemoteSource({required this._client});
  final RestClient _client;

  Future<Map<String, dynamic>> search(
    String query,
    int page,
    RestCancellationToken token,
  ) => _get('/search', token, {'mode': 'user', 'query': query, 'page': page});

  Future<Map<String, dynamic>> lookup(
    String identifier,
    RestCancellationToken token,
  ) => _get('/users/${Uri.encodeComponent(identifier)}', token, {});

  Future<Map<String, dynamic>> _get(
    String path,
    RestCancellationToken token,
    Map<String, Object?> query,
  ) async {
    final RestResponse response = await _client.get(
      path: path,
      queryParameters: query,
      options: RestClientOptions(cancellationToken: token),
    );
    if (response.statusCode != 200) {
      throw UserSearchRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
