import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tracksu_storage/src/stored_auth_tokens.dart';
import 'package:tracksu_storage/src/token_store.dart';

final class FlutterSecureTokenStore implements TokenStore {
  factory FlutterSecureTokenStore({required FlutterSecureStorage storage}) {
    return FlutterSecureTokenStore._(storage);
  }

  FlutterSecureTokenStore._(this._storage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredAuthTokens?> read() async {
    final String? accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final String? refreshToken = await _storage.read(key: _refreshTokenKey);
    return StoredAuthTokens(
      accessToken: accessToken,
      refreshToken: (refreshToken?.isEmpty ?? true) ? null : refreshToken,
    );
  }

  @override
  Future<void> write(StoredAuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    final String? refreshToken = tokens.refreshToken;
    if (refreshToken == null) {
      await _storage.delete(key: _refreshTokenKey);
      return;
    }

    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
