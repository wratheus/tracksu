import 'package:tracksu/src/_core/serialization/json_map_reader.dart';

final class OAuthTokensDto {
  const OAuthTokensDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
  });

  factory OAuthTokensDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    return OAuthTokensDto(
      accessToken: reader.requiredString('access_token'),
      refreshToken: reader.requiredString('refresh_token'),
      expiresInSeconds: reader.requiredInt('expires_in', positive: true),
    );
  }

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
}
