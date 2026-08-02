import 'package:tracksu/src/profile/data/profile_dto.dart';
import 'package:tracksu/src/profile/domain/profile.dart';

extension ProfileDtoMapper on ProfileDto {
  Profile toDomain() {
    final Uri avatarUri = Uri.parse(avatarUrl);
    if (!avatarUri.isScheme('https') || !avatarUri.hasAuthority) {
      throw FormatException('avatar_url must be an absolute HTTPS URI.');
    }

    return Profile(
      id: id,
      username: username,
      avatarUri: avatarUri,
      countryCode: countryCode,
      isOnline: isOnline,
      isSupporter: isSupporter,
      statistics: statistics?.toDomain(),
    );
  }
}

extension ProfileStatisticsDtoMapper on ProfileStatisticsDto {
  ProfileStatistics toDomain() {
    return ProfileStatistics(
      performancePoints: performancePoints,
      globalRank: globalRank,
      countryRank: countryRank,
      hitAccuracy: hitAccuracy,
      playCount: playCount,
      playTime: playTime,
      maximumCombo: maximumCombo,
    );
  }
}
