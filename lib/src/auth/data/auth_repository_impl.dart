import 'package:tracksu/src/auth/data/oauth_remote_source.dart';
import 'package:tracksu/src/auth/data/oauth_tokens_dto.dart';
import 'package:tracksu/src/auth/domain/auth_repository.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

final class AuthRepositoryImpl implements AuthRepository {
  factory AuthRepositoryImpl({
    required OAuthRemoteSource remoteSource,
    required SessionController sessionController,
  }) {
    return AuthRepositoryImpl._(remoteSource, sessionController);
  }

  AuthRepositoryImpl._(this._remoteSource, this._sessionController);

  final OAuthRemoteSource _remoteSource;
  final SessionController _sessionController;
  Future<void>? _refreshingAccessToken;

  @override
  Future<void> exchangeAuthorizationCode({required String code}) async {
    final OAuthTokensDto tokens = await _remoteSource.exchangeAuthorizationCode(
      code: code,
    );
    await _sessionController.save(
      StoredAuthTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: DateTime.now().toUtc().add(
          Duration(seconds: tokens.expiresInSeconds),
        ),
      ),
    );
  }

  @override
  Future<void> refreshAccessToken() {
    return _refreshingAccessToken ??= _refreshAccessToken().whenComplete(() {
      _refreshingAccessToken = null;
    });
  }

  Future<void> _refreshAccessToken() async {
    final String? refreshToken = await _sessionController.getRefreshToken();
    if (refreshToken == null) {
      throw StateError('No refresh token is available for this session.');
    }

    final OAuthTokensDto tokens = await _remoteSource.refreshAccessToken(
      refreshToken: refreshToken,
    );
    await _sessionController.save(
      StoredAuthTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: DateTime.now().toUtc().add(
          Duration(seconds: tokens.expiresInSeconds),
        ),
      ),
    );
  }
}
