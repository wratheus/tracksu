abstract interface class AuthRepository {
  Future<void> exchangeAuthorizationCode({required String code});
}
