final class OAuthRemoteSourceException implements Exception {
  const OAuthRemoteSourceException({required this.statusCode});

  final int statusCode;
}
