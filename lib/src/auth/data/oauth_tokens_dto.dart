final class OAuthTokensDto {
  const OAuthTokensDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
  });

  factory OAuthTokensDto.fromJson(Map<String, dynamic> json) {
    return OAuthTokensDto(
      accessToken: _requiredString(json, 'access_token'),
      refreshToken: _requiredString(json, 'refresh_token'),
      expiresInSeconds: _requiredInt(json, 'expires_in'),
    );
  }

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  return switch (json[key]) {
    final int value when value > 0 => value,
    _ => throw FormatException('$key must be a positive integer.'),
  };
}

String _requiredString(Map<String, dynamic> json, String key) {
  return switch (json[key]) {
    final String value when value.isNotEmpty => value,
    _ => throw FormatException('$key must be a non-empty string.'),
  };
}
