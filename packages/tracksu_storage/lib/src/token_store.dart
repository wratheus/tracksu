import 'package:tracksu_storage/src/stored_auth_tokens.dart';

abstract interface class TokenStore {
  Future<StoredAuthTokens?> read();

  Future<void> write(StoredAuthTokens tokens);

  Future<void> clear();
}
