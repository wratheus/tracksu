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
          request.uri.path == '/api/v2/search' ||
          request.uri.path == '/api/v2/spotlights' ||
          request.uri.path == '/api/v2/rankings/kudosu' ||
          RegExp(r'^/api/v2/news(/[1-9][0-9]*)?$').hasMatch(request.uri.path) ||
          RegExp(
            r'^/api/v2/rankings/(osu|taiko|fruits|mania)/(performance|score|charts|team|country)$',
          ).hasMatch(request.uri.path) ||
          RegExp(r'^/api/v2/beatmaps/[1-9][0-9]*(/scores)?$')
              .hasMatch(request.uri.path) ||
          RegExp(r'^/api/v2/beatmapsets/[1-9][0-9]*$')
              .hasMatch(request.uri.path) ||
          RegExp(r'^/api/v2/teams/[1-9][0-9]*(/(osu|taiko|fruits|mania))?$')
              .hasMatch(request.uri.path) ||
          // Daily challenge: rooms index and one room's leaderboard (P34).
          RegExp(r'^/api/v2/rooms(/[1-9][0-9]*/leaderboard)?$')
              .hasMatch(request.uri.path) ||
          // Comments of news posts and beatmapsets (P39).
          request.uri.path == '/api/v2/comments' ||
          // Beatmap listing search (P41).
          request.uri.path == '/api/v2/beatmapsets/search' ||
          // osu! changelog (P50); public without a token, sent like the rest.
          request.uri.path == '/api/v2/changelog' ||
          // Global osu! event feed (P51).
          request.uri.path == '/api/v2/events');

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
