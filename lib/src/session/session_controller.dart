import 'dart:async';

import 'package:tracksu/src/session/session_token_provider.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

enum SessionStatus { signedOut, authenticated }

final class SessionController implements SessionTokenProvider {
  factory SessionController({required TokenStore tokenStore}) {
    return SessionController._(tokenStore);
  }

  SessionController._(this._tokenStore);

  final TokenStore _tokenStore;
  final StreamController<SessionStatus> _statusChanges =
      StreamController<SessionStatus>.broadcast();
  StoredAuthTokens? _tokens;
  int _identityRevision = 0;
  int get identityRevision => _identityRevision;
  Future<void> _pendingWrite = Future<void>.value();

  SessionStatus get status => switch (_tokens) {
    null => SessionStatus.signedOut,
    _ => SessionStatus.authenticated,
  };

  /// UI observes status/account changes, never credentials. Refresh is silent.
  Stream<SessionStatus> get statusChanges => _statusChanges.stream;

  void _setTokens(StoredAuthTokens? tokens, {bool newAuthorization = false}) {
    final SessionStatus previous = status;
    _tokens = tokens;
    if ((status != previous || newAuthorization) && !_statusChanges.isClosed) {
      _identityRevision++;
      _statusChanges.add(status);
    }
  }

  void dispose() => unawaited(_statusChanges.close());

  Future<void> restore() async {
    _setTokens(await _tokenStore.read());
  }

  Future<void> save(StoredAuthTokens tokens, {bool newAuthorization = false}) {
    return _serializeWrite(() async {
      await _tokenStore.write(tokens);
      _setTokens(tokens, newAuthorization: newAuthorization);
    });
  }

  Future<void> clear() {
    return _serializeWrite(() async {
      await _tokenStore.clear();
      _setTokens(null);
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
