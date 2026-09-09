import 'package:tracksu/src/_shared/content/data/content_page_dto.dart';
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
    required this.coverUrl,
    required this.rankHistory,
    required this.page,
    this.replayHistory,
    this.playHistory,
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
      page: switch (json['page']) {
        null => null,
        final Map<String, dynamic> value => ContentPageDto.profile(value),
        _ => const ContentPageDto.unavailable(),
      },
      replayHistory: ProfileMonthlyHistoryDto.tryFromJson(
        json['replays_watched_counts'],
      ),
      playHistory: ProfileMonthlyHistoryDto.tryFromJson(
        json['monthly_playcounts'],
      ),
      coverUrl: switch (reader.optionalMap('cover')) {
        null => null,
        final Map<String, dynamic> value => JsonMapReader(
          value,
        ).optionalString('url'),
      },
      rankHistory: switch (reader.optionalMap('rank_history')) {
        null => null,
        final Map<String, dynamic> value => ProfileRankHistoryDto.fromJson(
          value,
        ),
      },
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
  final String? coverUrl;
  final ProfileRankHistoryDto? rankHistory;
  final ContentPageDto? page;
  final ProfileMonthlyHistoryDto? replayHistory;
  final ProfileMonthlyHistoryDto? playHistory;
}

/// Optional graph data must not prevent opening otherwise valid profiles.
final class ProfileMonthlyHistoryDto {
  ProfileMonthlyHistoryDto._(List<({String date, int count})> months)
    : months = List<({String date, int count})>.unmodifiable(months);
  final List<({String date, int count})> months;

  static ProfileMonthlyHistoryDto? tryFromJson(Object? json) {
    if (json == null) return null;
    if (json is! List<dynamic> || json.length > 1200) return null;
    try {
      return ProfileMonthlyHistoryDto._(
        json
            .map((dynamic item) {
              if (item is! Map<String, dynamic>) {
                throw const FormatException('Invalid monthly observation.');
              }
              final JsonMapReader reader = JsonMapReader(item);
              return (
                date: reader.requiredString('start_date'),
                count: reader.requiredInt('count'),
              );
            })
            .toList(growable: false),
      );
    } on FormatException {
      return null;
    }
  }
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
    required this.rankedScore,
    required this.totalScore,
    required this.totalHits,
    required this.replaysWatched,
    required this.level,
    required this.gradeCounts,
  });

  factory ProfileStatisticsDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    return ProfileStatisticsDto(
      performancePoints: reader.requiredDouble('pp'),
      globalRank: reader.optionalInt('global_rank'),
      countryRank: reader.optionalInt('country_rank'),
      hitAccuracy: reader.requiredDouble('hit_accuracy'),
      playCount: reader.requiredInt('play_count'),
      playTime: reader.optionalInt('play_time'),
      maximumCombo: reader.requiredInt('maximum_combo'),
      rankedScore: reader.optionalInt('ranked_score'),
      totalScore: reader.optionalInt('total_score'),
      totalHits: reader.optionalInt('total_hits'),
      replaysWatched: reader.optionalInt('replays_watched_by_others'),
      level: switch (reader.optionalMap('level')) {
        null => null,
        final Map<String, dynamic> value => ProfileLevelDto.fromJson(value),
      },
      gradeCounts: switch (reader.optionalMap('grade_counts')) {
        null => null,
        final Map<String, dynamic> value => ProfileGradeCountsDto.fromJson(
          value,
        ),
      },
    );
  }

  final double performancePoints;
  final int? globalRank;
  final int? countryRank;
  final double hitAccuracy;
  final int playCount;
  final int? playTime;
  final int maximumCombo;
  final int? rankedScore;
  final int? totalScore;
  final int? totalHits;
  final int? replaysWatched;
  final ProfileLevelDto? level;
  final ProfileGradeCountsDto? gradeCounts;
}

final class ProfileLevelDto {
  const ProfileLevelDto({required this.current, required this.progress});
  factory ProfileLevelDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final int current = reader.requiredInt('current');
    final int progress = reader.requiredInt('progress');
    if (current < 0 || progress < 0 || progress > 100) {
      throw const FormatException('Invalid profile level.');
    }
    return ProfileLevelDto(current: current, progress: progress);
  }
  final int current;
  final int progress;
}

final class ProfileGradeCountsDto {
  const ProfileGradeCountsDto({
    required this.ss,
    required this.ssh,
    required this.s,
    required this.sh,
    required this.a,
  });
  factory ProfileGradeCountsDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final ProfileGradeCountsDto counts = ProfileGradeCountsDto(
      ss: reader.requiredInt('ss'),
      ssh: reader.requiredInt('ssh'),
      s: reader.requiredInt('s'),
      sh: reader.requiredInt('sh'),
      a: reader.requiredInt('a'),
    );
    if (<int>[
      counts.ss,
      counts.ssh,
      counts.s,
      counts.sh,
      counts.a,
    ].any((int value) => value < 0)) {
      throw const FormatException('Grade counts must not be negative.');
    }
    return counts;
  }
  final int ss;
  final int ssh;
  final int s;
  final int sh;
  final int a;
}

final class ProfileRankHistoryDto {
  ProfileRankHistoryDto({required this.mode, required List<int?> ranks})
    : ranks = List<int?>.unmodifiable(ranks);
  factory ProfileRankHistoryDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    return ProfileRankHistoryDto(
      mode: reader.requiredString('mode'),
      ranks: reader
          .requiredList('data')
          .map(
            (dynamic value) => switch (value) {
              null => null,
              final int rank when rank > 0 => rank,
              0 => null,
              _ => throw const FormatException(
                'Invalid rank history observation.',
              ),
            },
          )
          .toList(growable: false),
    );
  }
  final String mode;
  final List<int?> ranks;
}
