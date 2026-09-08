import 'dart:convert';

import 'package:tracksu/src/_shared/content/data/content_normalizer.dart';
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

extension ProfilePageDtoMapper on ProfilePageDto {
  ProfileAbout? toDomain(Uri uri) {
    final String? rendered = html?.trim();
    final String? plain = raw?.trim();
    if ((rendered == null || rendered.isEmpty) &&
        (plain == null || plain.isEmpty)) {
      return null;
    }
    try {
      // Raw BBCode is readable source fallback, never reinterpreted as HTML.
      // Bound before escaping to avoid doubling a pathological response in memory.
      if ((rendered?.length ?? 0) > 2000000 || (plain?.length ?? 0) > 2000000) {
        throw const FormatException('Profile page is too large.');
      }
      final String content = rendered != null && rendered.isNotEmpty
          ? rendered
          : '<p>${const HtmlEscape().convert(plain!).replaceAll('\n', '<br>')}</p>';
      return ProfileAbout(
        uri: uri,
        document: ContentNormalizer.html(content, uri),
      );
    } on FormatException {
      // Optional presentation content must not hide valid profile statistics.
      return ProfileAbout(uri: uri, document: null);
    }
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
