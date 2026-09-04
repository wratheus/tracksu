import 'package:tracksu/src/auth/domain/public_access_repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class OsuPublicAuthorizationInterceptor
    implements RestClientInterceptor, RestClientRetryInterceptor {
  factory OsuPublicAuthorizationInterceptor({
    required PublicAccessRepository repository,
  }) => OsuPublicAuthorizationInterceptor._(repository);

  const OsuPublicAuthorizationInterceptor._(this._repository);

  final PublicAccessRepository _repository;

  bool _accepts(RestRequest request) =>
      request.uri.isScheme('https') &&
      request.uri.host == 'osu.ppy.sh' &&
      request.method == RestMethod.get &&
      (request.uri.path.startsWith('/api/v2/users/') ||
          request.uri.path == '/api/v2/spotlights' ||
          RegExp(
            r'^/api/v2/rankings/(osu|taiko|fruits|mania)/(performance|score|charts)$',
          ).hasMatch(request.uri.path) ||
          RegExp(r'^/api/v2/beatmaps/[1-9][0-9]*(/scores)?$')
              .hasMatch(request.uri.path) ||
          RegExp(r'^/api/v2/beatmapsets/[1-9][0-9]*$')
              .hasMatch(request.uri.path));

  @override
  Future<RestRequest> onRequest(RestRequest request) async {
    if (!_accepts(request)) {
      throw StateError('Public API client cannot access this endpoint.');
    }
    final String token = await _repository.getAccessToken();
    return request.copyWith(
      headers: <String, String>{
        ...request.headers,
        'authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<RestResponse> onResponse({
    required RestRequest request,
    required RestResponse response,
  }) async => response;

  @override
  Future<RestRequest?> retryRequest({
    required RestRequest request,
    required RestResponse response,
  }) async {
    if (response.statusCode != 401 || !_accepts(request)) {
      return null;
    }
    final String? authorization = request.headers['authorization'];
    if (authorization == null || !authorization.startsWith('Bearer ')) {
      return null;
    }
    _repository.invalidate(authorization.substring(7));
    // The transport retries once; onRequest joins any renewal in progress.
    return request;
  }
}
