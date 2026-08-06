abstract interface class SessionTokenProvider {
  Future<String?> getAccessToken();
}
