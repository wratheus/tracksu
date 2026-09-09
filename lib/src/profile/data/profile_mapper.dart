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
      about: page?.toDomain(Uri.https('osu.ppy.sh', '/users/$id')),
      replayHistory: replayHistory?.toDomain(),
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

extension ProfileReplayHistoryDtoMapper on ProfileReplayHistoryDto {
  ProfileReplayHistory? toDomain() {
    final List<ProfileReplayMonth> result = <ProfileReplayMonth>[];
    final Set<DateTime> seen = <DateTime>{};
    for (final (:String date, :int count) in months) {
      final DateTime? parsed = DateTime.tryParse(date);
      // DateTime.parse normalises invalid dates; reject those explicitly.
      if (!RegExp(r'^\d{4}-\d{2}-01$').hasMatch(date) ||
          parsed == null ||
          count < 0 ||
          '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-01' !=
              date) {
        return null;
      }
      final DateTime month = DateTime.utc(parsed.year, parsed.month);
      if (!seen.add(month)) return null;
      result.add(ProfileReplayMonth(month: month, views: count));
    }
    result.sort(
      (ProfileReplayMonth a, ProfileReplayMonth b) =>
          a.month.compareTo(b.month),
    );
    return ProfileReplayHistory(result);
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
