import 'package:tracksu/src/auth/domain/auth_repository.dart';
import 'package:tracksu/src/session/session_token_provider.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class OsuAuthorizationInterceptor
    implements RestClientInterceptor, RestClientRetryInterceptor {
  factory OsuAuthorizationInterceptor({
    required AuthRepository authRepository,
    required SessionTokenProvider tokenProvider,
  }) {
    return OsuAuthorizationInterceptor._(authRepository, tokenProvider);
  }

  const OsuAuthorizationInterceptor._(
    this._authRepository,
    this._tokenProvider,
  );

  final AuthRepository _authRepository;
  final SessionTokenProvider _tokenProvider;

  @override
  Future<RestRequest> onRequest(RestRequest request) async {
    if (!_isOsuApiRequest(request) ||
        _hasHeader(request.headers, 'authorization')) {
      return request;
    }

    final String? accessToken = await _tokenProvider.getAccessToken();
    if (accessToken == null) {
      return request;
    }

    final Map<String, String> headers = Map<String, String>.from(
      request.headers,
    );
    headers['authorization'] = 'Bearer $accessToken';
    return request.copyWith(headers: headers);
  }

  @override
  Future<RestResponse> onResponse({
    required RestRequest request,
    required RestResponse response,
  }) {
    return Future<RestResponse>.value(response);
  }

  @override
  Future<RestRequest?> retryRequest({
    required RestRequest request,
    required RestResponse response,
  }) async {
    if (response.statusCode != 401 ||
        !_isOsuApiRequest(request) ||
        !_hasHeader(request.headers, 'authorization')) {
      return null;
    }

    try {
      await _authRepository.refreshAccessToken();
    } on Object {
      return null;
    }

    final Map<String, String> headers =
        Map<String, String>.from(request.headers)..removeWhere(
          (String name, String _) => name.toLowerCase() == 'authorization',
        );
    return request.copyWith(headers: headers);
  }

  bool _isOsuApiRequest(RestRequest request) {
    return request.uri.isScheme('https') && request.uri.host == 'osu.ppy.sh';
  }

  bool _hasHeader(Map<String, String> headers, String name) {
    return headers.keys.any(
      (String headerName) => headerName.toLowerCase() == name,
    );
  }
}
