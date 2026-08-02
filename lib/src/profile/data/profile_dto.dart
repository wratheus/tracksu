final class ProfileDto {
  const ProfileDto({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.countryCode,
    required this.isOnline,
    required this.isSupporter,
    required this.statistics,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: _requiredInt(json, 'id'),
      username: _requiredString(json, 'username'),
      avatarUrl: _requiredString(json, 'avatar_url'),
      countryCode: _requiredString(json, 'country_code'),
      isOnline: _requiredBool(json, 'is_online'),
      isSupporter: _requiredBool(json, 'is_supporter'),
      statistics: switch (json['statistics']) {
        null => null,
        final Map<String, dynamic> value => ProfileStatisticsDto.fromJson(
          value,
        ),
        _ => throw FormatException('statistics must be an object or null.'),
      },
    );
  }

  final int id;
  final String username;
  final String avatarUrl;
  final String countryCode;
  final bool isOnline;
  final bool isSupporter;
  final ProfileStatisticsDto? statistics;
}

final class ProfileStatisticsDto {
  const ProfileStatisticsDto({
    required this.performancePoints,
    required this.globalRank,
    required this.countryRank,
    required this.hitAccuracy,
    required this.playCount,
    required this.playTime,
    required this.maximumCombo,
  });

  factory ProfileStatisticsDto.fromJson(Map<String, dynamic> json) {
    return ProfileStatisticsDto(
      performancePoints: _requiredDouble(json, 'pp'),
      globalRank: _optionalInt(json, 'global_rank'),
      countryRank: _optionalInt(json, 'country_rank'),
      hitAccuracy: _requiredDouble(json, 'hit_accuracy'),
      playCount: _requiredInt(json, 'play_count'),
      playTime: _requiredInt(json, 'play_time'),
      maximumCombo: _requiredInt(json, 'maximum_combo'),
    );
  }

  final double performancePoints;
  final int? globalRank;
  final int? countryRank;
  final double hitAccuracy;
  final int playCount;
  final int playTime;
  final int maximumCombo;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  return switch (json[key]) {
    final int value => value,
    _ => throw FormatException('$key must be an integer.'),
  };
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  return switch (json[key]) {
    null => null,
    final int value => value,
    _ => throw FormatException('$key must be an integer or null.'),
  };
}

double _requiredDouble(Map<String, dynamic> json, String key) {
  return switch (json[key]) {
    final num value => value.toDouble(),
    _ => throw FormatException('$key must be a number.'),
  };
}

String _requiredString(Map<String, dynamic> json, String key) {
  return switch (json[key]) {
    final String value when value.isNotEmpty => value,
    _ => throw FormatException('$key must be a non-empty string.'),
  };
}

bool _requiredBool(Map<String, dynamic> json, String key) {
  return switch (json[key]) {
    final bool value => value,
    _ => throw FormatException('$key must be a boolean.'),
  };
}
