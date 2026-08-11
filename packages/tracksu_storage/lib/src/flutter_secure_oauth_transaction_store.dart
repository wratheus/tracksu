import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tracksu_storage/src/oauth_transaction_store.dart';
import 'package:tracksu_storage/src/pending_oauth_transaction.dart';

final class FlutterSecureOAuthTransactionStore
    implements OAuthTransactionStore {
  factory FlutterSecureOAuthTransactionStore({
    required FlutterSecureStorage storage,
  }) {
    return FlutterSecureOAuthTransactionStore._(storage);
  }

  FlutterSecureOAuthTransactionStore._(this._storage);

  static const _startedAtKey = 'oauth_pending_started_at';
  static const _stateKey = 'oauth_pending_state';

  final FlutterSecureStorage _storage;

  @override
  Future<PendingOAuthTransaction?> read() async {
    final String? state = await _storage.read(key: _stateKey);
    final String? startedAtValue = await _storage.read(key: _startedAtKey);
    final DateTime? startedAt = startedAtValue == null
        ? null
        : DateTime.tryParse(startedAtValue)?.toUtc();

    if (state == null || state.isEmpty || startedAt == null) {
      return null;
    }

    return PendingOAuthTransaction(state: state, startedAt: startedAt);
  }

  @override
  Future<void> write(PendingOAuthTransaction transaction) async {
    await _storage.write(key: _stateKey, value: transaction.state);
    await _storage.write(
      key: _startedAtKey,
      value: transaction.startedAt.toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _stateKey);
    await _storage.delete(key: _startedAtKey);
  }
}
