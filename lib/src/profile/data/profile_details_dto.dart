import 'package:tracksu/src/_core/serialization/json_map_reader.dart';

typedef ProfileGroupDto = ({
  int id,
  String name,
  String shortName,
  bool hasListing,
  String? colour,
});
typedef ProfileTeamDto = ({
  int id,
  String name,
  String shortName,
  String? flagUrl,
});
typedef ProfileMedalDto = ({int id, String achievedAt});
typedef ProfileRankedPlayDto = ({
  int poolId,
  String? poolName,
  int plays,
  int firstPlaces,
  double rating,
  bool provisional,
  int? rank,
  int totalPoints,
});
typedef ProfileDailyChallengeDto = ({
  int plays,
  int dailyCurrent,
  int dailyBest,
  int weeklyCurrent,
  int weeklyBest,
  int top10,
  int top50,
  String? lastUpdate,
  String? lastWeeklyStreak,
});

final class ProfileDetailsDto {
  const ProfileDetailsDto({
    required this.previousNames,
    required this.groups,
    required this.team,
    required this.medals,
    required this.rankedPlay,
    required this.dailyChallenge,
  });

  factory ProfileDetailsDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final Map<String, dynamic>? team = reader.optionalMap('team');
    final Map<String, dynamic>? daily = reader.optionalMap(
      'daily_challenge_user_stats',
    );
    return ProfileDetailsDto(
      previousNames: reader
          .optionalList('previous_usernames')
          ?.map(
            (dynamic name) => switch (name) {
              final String value when value.trim().isNotEmpty => value,
              _ => throw const FormatException('Invalid previous username.'),
            },
          )
          .toList(growable: false),
      groups: reader
          .optionalList('groups')
          ?.map((dynamic item) {
            final JsonMapReader group = JsonMapReader(
              JsonMapReader.asMap(item),
            );
            return (
              id: group.requiredInt('id', positive: true),
              name: group.requiredString('name'),
              shortName: group.requiredString('short_name'),
              hasListing: group.requiredBool('has_listing'),
              colour: group.optionalString('colour'),
            );
          })
          .toList(growable: false),
      team: team == null ? null : _team(JsonMapReader(team)),
      medals: reader
          .optionalList('user_achievements')
          ?.map((dynamic item) {
            final JsonMapReader medal = JsonMapReader(
              JsonMapReader.asMap(item),
            );
            return (
              id: medal.requiredInt('achievement_id', positive: true),
              achievedAt: medal.requiredString('achieved_at'),
            );
          })
          .toList(growable: false),
      rankedPlay: reader
          .optionalList('matchmaking_stats')
          ?.map((dynamic item) {
            final JsonMapReader stats = JsonMapReader(
              JsonMapReader.asMap(item),
            );
            final Map<String, dynamic>? pool = stats.optionalMap('pool');
            return (
              poolId: stats.requiredInt('pool_id', positive: true),
              poolName: pool == null
                  ? null
                  : JsonMapReader(pool).optionalString('name'),
              plays: stats.requiredInt('plays'),
              firstPlaces: stats.requiredInt('first_placements'),
              rating: stats.requiredDouble('rating'),
              provisional: stats.requiredBool('is_rating_provisional'),
              rank: stats.optionalInt('rank'),
              totalPoints: stats.requiredInt('total_points'),
            );
          })
          .toList(growable: false),
      dailyChallenge: daily == null ? null : _daily(JsonMapReader(daily)),
    );
  }

  static ProfileTeamDto _team(JsonMapReader reader) => (
    id: reader.requiredInt('id', positive: true),
    name: reader.requiredString('name'),
    shortName: reader.requiredString('short_name'),
    flagUrl: reader.optionalString('flag_url'),
  );
  static ProfileDailyChallengeDto _daily(JsonMapReader reader) => (
    plays: reader.requiredInt('playcount'),
    dailyCurrent: reader.requiredInt('daily_streak_current'),
    dailyBest: reader.requiredInt('daily_streak_best'),
    weeklyCurrent: reader.requiredInt('weekly_streak_current'),
    weeklyBest: reader.requiredInt('weekly_streak_best'),
    top10: reader.requiredInt('top_10p_placements'),
    top50: reader.requiredInt('top_50p_placements'),
    lastUpdate: reader.optionalString('last_update'),
    lastWeeklyStreak: reader.optionalString('last_weekly_streak'),
  );

  final List<String>? previousNames;
  final List<ProfileGroupDto>? groups;
  final ProfileTeamDto? team;
  final List<ProfileMedalDto>? medals;
  final List<ProfileRankedPlayDto>? rankedPlay;
  final ProfileDailyChallengeDto? dailyChallenge;
}
