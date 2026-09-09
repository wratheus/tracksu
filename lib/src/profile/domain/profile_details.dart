import 'package:meta/meta.dart';

/// Optional profile sections. Null means omitted, not an empty collection.
@immutable
final class ProfileDetails {
  ProfileDetails({
    List<String>? previousNames,
    List<ProfileGroup>? groups,
    List<ProfileMedal>? medals,
    List<ProfileRankedPlay>? rankedPlay,
    this.team,
    this.dailyChallenge,
  }) : previousNames = previousNames == null
           ? null
           : List.unmodifiable(previousNames),
       groups = groups == null ? null : List.unmodifiable(groups),
       medals = medals == null ? null : List.unmodifiable(medals),
       rankedPlay = rankedPlay == null ? null : List.unmodifiable(rankedPlay);

  final List<String>? previousNames;
  final List<ProfileGroup>? groups;
  final ProfileTeam? team;
  final List<ProfileMedal>? medals;
  final List<ProfileRankedPlay>? rankedPlay;
  final ProfileDailyChallenge? dailyChallenge;
}

@immutable
final class ProfileGroup {
  const ProfileGroup({
    required this.id,
    required this.name,
    required this.shortName,
    required this.hasListing,
    this.colour,
  });
  final int id;
  final String name;
  final String shortName;
  final bool hasListing;

  /// Optional six-digit RGB, without a leading hash. No Flutter types in domain.
  final int? colour;
}

@immutable
final class ProfileTeam {
  const ProfileTeam({
    required this.id,
    required this.name,
    required this.shortName,
    this.flagUri,
  });
  final int id;
  final String name;
  final String shortName;
  final Uri? flagUri;
}

@immutable
final class ProfileMedal {
  const ProfileMedal({required this.id, required this.achievedAt});
  final int id;
  final DateTime achievedAt;
}

@immutable
final class ProfileRankedPlay {
  const ProfileRankedPlay({
    required this.poolId,
    required this.plays,
    required this.firstPlaces,
    required this.rating,
    required this.provisional,
    required this.totalPoints,
    this.rank,
    this.poolName,
  });
  final int poolId;
  final String? poolName;
  final int plays;
  final int firstPlaces;
  final double rating;
  final bool provisional;
  final int? rank;
  final int totalPoints;
}

@immutable
final class ProfileDailyChallenge {
  const ProfileDailyChallenge({
    required this.plays,
    required this.dailyCurrent,
    required this.dailyBest,
    required this.weeklyCurrent,
    required this.weeklyBest,
    required this.top10,
    required this.top50,
    this.lastUpdate,
    this.lastWeeklyStreak,
  });
  final int plays;
  final int dailyCurrent;
  final int dailyBest;
  final int weeklyCurrent;
  final int weeklyBest;
  final int top10;
  final int top50;
  final DateTime? lastUpdate;
  final DateTime? lastWeeklyStreak;
}
