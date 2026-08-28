abstract interface class PublicAccessRepository {
  Future<String> getAccessToken();

  void invalidate(String rejectedToken);
}
