import 'package:tracksu/src/_core/serialization/json_map_reader.dart';

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
    final JsonMapReader reader = JsonMapReader(json);
    return ProfileDto(
      id: reader.requiredInt('id', positive: true),
      username: reader.requiredString('username'),
      avatarUrl: reader.requiredString('avatar_url'),
      countryCode: reader.requiredString('country_code'),
      isOnline: reader.requiredBool('is_online'),
      isSupporter: reader.requiredBool('is_supporter'),
      statistics: switch (reader.optionalMap('statistics')) {
        null => null,
        final Map<String, dynamic> value => ProfileStatisticsDto.fromJson(
          value,
        ),
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
    final JsonMapReader reader = JsonMapReader(json);
    return ProfileStatisticsDto(
      performancePoints: reader.requiredDouble('pp'),
      globalRank: reader.optionalInt('global_rank'),
      countryRank: reader.optionalInt('country_rank'),
      hitAccuracy: reader.requiredDouble('hit_accuracy'),
      playCount: reader.requiredInt('play_count'),
      playTime: reader.requiredInt('play_time'),
      maximumCombo: reader.requiredInt('maximum_combo'),
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
