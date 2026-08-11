import 'package:tracksu_storage/src/pending_oauth_transaction.dart';

abstract interface class OAuthTransactionStore {
  Future<PendingOAuthTransaction?> read();

  Future<void> write(PendingOAuthTransaction transaction);

  Future<void> clear();
}
