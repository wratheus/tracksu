import 'package:tracksu/src/profile/data/profile_dto.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

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
      coverUri: _optionalCoverUri(coverUrl),
      rankHistory: rankHistory?.toDomain(),
    );
  }

  // Optional media must not make an otherwise valid profile unavailable.
  static Uri? _optionalCoverUri(String? value) {
    final Uri? uri = value == null ? null : Uri.tryParse(value);
    return uri != null &&
            uri.isScheme('https') &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty
        ? uri
        : null;
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
      rankedScore: rankedScore,
      totalScore: totalScore,
      totalHits: totalHits,
      replaysWatched: replaysWatched,
      level: level == null
          ? null
          : ProfileLevel(current: level!.current, progress: level!.progress),
      gradeCounts: gradeCounts == null
          ? null
          : ProfileGradeCounts(
              ss: gradeCounts!.ss,
              ssh: gradeCounts!.ssh,
              s: gradeCounts!.s,
              sh: gradeCounts!.sh,
              a: gradeCounts!.a,
            ),
    );
  }
}

extension ProfileRankHistoryDtoMapper on ProfileRankHistoryDto {
  ProfileRankHistory? toDomain() {
    final ProfileRuleset? ruleset = ProfileRuleset.values
        .where((ProfileRuleset value) => value.apiValue == mode)
        .firstOrNull;
    return ruleset == null
        ? null
        : ProfileRankHistory(ruleset: ruleset, ranks: ranks);
  }
}
