abstract interface class OAuthRemoteSource {
  Future<Map<String, dynamic>> exchangeAuthorizationCode({
    required String code,
  });

  Future<Map<String, dynamic>> refreshAccessToken({
    required String refreshToken,
  });
}
