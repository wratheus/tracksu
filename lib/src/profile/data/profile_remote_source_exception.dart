final class ProfileRemoteSourceException implements Exception {
  const ProfileRemoteSourceException({required this.statusCode});

  final int statusCode;
}
