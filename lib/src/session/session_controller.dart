import 'package:tracksu/src/session/session_token_provider.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

final class SessionController implements SessionTokenProvider {
  factory SessionController({required TokenStore tokenStore}) {
    return SessionController._(tokenStore);
  }

  SessionController._(this._tokenStore);

  final TokenStore _tokenStore;
  StoredAuthTokens? _tokens;

  Future<void> restore() async {
    _tokens = await _tokenStore.read();
  }

  Future<void> save(StoredAuthTokens tokens) async {
    await _tokenStore.write(tokens);
    _tokens = tokens;
  }

  Future<void> clear() async {
    await _tokenStore.clear();
    _tokens = null;
  }

  @override
  Future<String?> getAccessToken() {
    return Future<String?>.value(_tokens?.accessToken);
  }
}
