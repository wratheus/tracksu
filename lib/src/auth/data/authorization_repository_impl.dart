import 'dart:convert';
import 'dart:math';

import 'package:tracksu/src/auth/domain/authorization.dart';
import 'package:tracksu/src/auth/domain/oauth_callback.dart';
import 'package:tracksu_storage/tracksu_storage.dart';
import 'package:url_launcher/url_launcher.dart';

final class AuthorizationRepositoryImpl implements AuthorizationRepository {
  factory AuthorizationRepositoryImpl({
    required OAuthTransactionStore store,
    required String clientId,
  }) => AuthorizationRepositoryImpl._(store, clientId);
  const AuthorizationRepositoryImpl._(this._store, this._clientId);
  final OAuthTransactionStore _store;
  final String _clientId;

  @override
  Future<AuthorizationAttempt> prepare() async {
    final Random random = Random.secure();
    final String state = base64UrlEncode(
      List<int>.generate(32, (_) => random.nextInt(256), growable: false),
    ).replaceAll('=', '');
    await _store.write(
      PendingOAuthTransaction(state: state, startedAt: DateTime.now().toUtc()),
    );
    return AuthorizationAttempt(
      state: state,
      uri: Uri.https('osu.ppy.sh', '/oauth/authorize', <String, String>{
        'client_id': _clientId,
        'redirect_uri': OAuthCallbackParser.callbackUri,
        'response_type': 'code',
        'scope': 'public identify',
        'state': state,
      }),
    );
  }

  @override
  Future<String?> restoreState() async {
    final PendingOAuthTransaction? transaction = await _store.read();
    if (transaction == null) return null;
    final Duration age = DateTime.now().toUtc().difference(
      transaction.startedAt,
    );
    if (age.isNegative || age > const Duration(minutes: 10)) return null;
    return transaction.state;
  }

  @override
  Future<bool> openBrowser(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
  @override
  Future<void> clear() => _store.clear();
}
