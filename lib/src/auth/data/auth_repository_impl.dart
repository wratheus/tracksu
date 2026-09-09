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
  int _sessionGeneration = 0;
  int? _exchangeGeneration;
  bool _isLoggingOut = false;

  @override
  Future<void> exchangeAuthorizationCode({required String code}) async {
    final int generation = ++_sessionGeneration;
    _exchangeGeneration = generation;
    try {
      final Map<String, dynamic> response = await _remoteSource
          .exchangeAuthorizationCode(code: code);
      final OAuthTokensDto tokens = OAuthTokensDto.fromJson(response);
      if (generation != _sessionGeneration) {
        throw StateError('The session changed during authorization.');
      }
      await _sessionController.save(
        StoredAuthTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresAt: DateTime.now().toUtc().add(
            Duration(seconds: tokens.expiresInSeconds),
          ),
        ),
        newAuthorization: true,
      );
    } finally {
      if (_exchangeGeneration == generation) {
        _exchangeGeneration = null;
      }
    }
  }

  @override
  Future<void> refreshAccessToken() {
    if (_exchangeGeneration != null || _isLoggingOut) {
      return Future<void>.error(
        StateError('Cannot refresh while the account is changing.'),
      );
    }
    return _refreshingAccessToken ??= _refreshAccessToken().whenComplete(() {
      _refreshingAccessToken = null;
    });
  }

  @override
  Future<void> logout() async {
    _sessionGeneration++;
    _isLoggingOut = true;
    try {
      await _sessionController.clear();
    } finally {
      _isLoggingOut = false;
    }
  }

  Future<void> _refreshAccessToken() async {
    final int generation = _sessionGeneration;
    final String? refreshToken = await _sessionController.getRefreshToken();
    if (refreshToken == null) {
      throw StateError('No refresh token is available for this session.');
    }

    final Map<String, dynamic> response = await _remoteSource
        .refreshAccessToken(refreshToken: refreshToken);
    final OAuthTokensDto tokens = OAuthTokensDto.fromJson(response);
    if (generation != _sessionGeneration) {
      throw StateError('The session changed during refresh.');
    }
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
