import 'package:tracksu/src/auth/data/oauth_client_credentials.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/auth/domain/oauth_callback.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class OsuOAuthRemoteSource implements OAuthRemoteSource {
  factory OsuOAuthRemoteSource({
    required OAuthClientCredentials clientCredentials,
    required RestClient restClient,
  }) {
    return OsuOAuthRemoteSource._(clientCredentials, restClient);
  }

  OsuOAuthRemoteSource._(this._clientCredentials, this._restClient);

  final OAuthClientCredentials _clientCredentials;
  final RestClient _restClient;

  @override
  Future<Map<String, dynamic>> requestPublicToken() async {
    final RestResponse response = await _restClient.post(
      path: '/oauth/token',
      body: <String, Object?>{
        'client_id': _clientCredentials.clientId,
        'client_secret': _clientCredentials.clientSecret,
        'grant_type': 'client_credentials',
        'scope': 'public',
      },
      contentType: RestContentType.form,
    );
    if (response.statusCode != 200) {
      throw OAuthRemoteSourceException(statusCode: response.statusCode);
    }
    return response.payload.asMap();
  }

  @override
  Future<Map<String, dynamic>> exchangeAuthorizationCode({
    required String code,
  }) async {
    final RestResponse response = await _restClient.post(
      path: '/oauth/token',
      body: <String, Object?>{
        'client_id': _clientCredentials.clientId,
        'client_secret': _clientCredentials.clientSecret,
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': OAuthCallbackParser.callbackUri,
      },
      contentType: RestContentType.form,
    );
    if (response.statusCode != 200) {
      throw OAuthRemoteSourceException(statusCode: response.statusCode);
    }

    return response.payload.asMap();
  }

  @override
  Future<Map<String, dynamic>> refreshAccessToken({
    required String refreshToken,
  }) async {
    final RestResponse response = await _restClient.post(
      path: '/oauth/token',
      body: <String, Object?>{
        'client_id': _clientCredentials.clientId,
        'client_secret': _clientCredentials.clientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'scope': 'public identify',
      },
      contentType: RestContentType.form,
    );
    if (response.statusCode != 200) {
      throw OAuthRemoteSourceException(statusCode: response.statusCode);
    }

    return response.payload.asMap();
  }
}
