import 'package:tracksu/src/session/session_token_provider.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

enum SessionStatus { signedOut, authenticated }

final class SessionController implements SessionTokenProvider {
  factory SessionController({required TokenStore tokenStore}) {
    return SessionController._(tokenStore);
  }

  SessionController._(this._tokenStore);

  final TokenStore _tokenStore;
  StoredAuthTokens? _tokens;
  Future<void> _pendingWrite = Future<void>.value();

  SessionStatus get status => switch (_tokens) {
    null => SessionStatus.signedOut,
    _ => SessionStatus.authenticated,
  };

  Future<void> restore() async {
    _tokens = await _tokenStore.read();
  }

  Future<void> save(StoredAuthTokens tokens) {
    return _serializeWrite(() async {
      await _tokenStore.write(tokens);
      _tokens = tokens;
    });
  }

  Future<void> clear() {
    return _serializeWrite(() async {
      await _tokenStore.clear();
      _tokens = null;
    });
  }

  Future<void> _serializeWrite(Future<void> Function() operation) {
    final Future<void> result = _pendingWrite.then((_) => operation());
    // Preserve failures for the caller without poisoning subsequent writes.
    _pendingWrite = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  Future<String?> getRefreshToken() {
    return Future<String?>.value(_tokens?.refreshToken);
  }

  @override
  Future<String?> getAccessToken() {
    return Future<String?>.value(_tokens?.accessToken);
  }
}
