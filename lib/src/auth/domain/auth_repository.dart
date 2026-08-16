abstract interface class AuthRepository {
  Future<void> exchangeAuthorizationCode({required String code});

  Future<void> refreshAccessToken();

  Future<void> logout();
}
