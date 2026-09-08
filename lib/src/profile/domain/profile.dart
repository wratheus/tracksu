import 'package:meta/meta.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

@immutable
final class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.avatarUri,
    required this.countryCode,
    required this.isOnline,
    required this.isSupporter,
    required this.statistics,
    this.coverUri,
    this.rankHistory,
    this.about,
  });

  final int id;
  final String username;
  final Uri avatarUri;
  final String countryCode;
  final bool isOnline;
  final bool isSupporter;
  final ProfileStatistics? statistics;
  final Uri? coverUri;
  final ProfileRankHistory? rankHistory;
  final ProfileAbout? about;
}

@immutable
final class ProfileAbout {
  const ProfileAbout({required this.uri, required this.document});
  final Uri uri;

  /// null means the optional content exceeded the safe reader's limits.
  final ContentDocument? document;
}

@immutable
final class ProfileStatistics {
  const ProfileStatistics({
    required this.performancePoints,
    required this.globalRank,
    required this.countryRank,
    required this.hitAccuracy,
    required this.playCount,
    required this.playTime,
    required this.maximumCombo,
    this.rankedScore,
    this.totalScore,
    this.totalHits,
    this.replaysWatched,
    this.level,
    this.gradeCounts,
  });

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
  final ProfileLevel? level;
  final ProfileGradeCounts? gradeCounts;
}

@immutable
final class ProfileLevel {
  const ProfileLevel({required this.current, required this.progress});
  final int current;
  final int progress;
}

@immutable
final class ProfileGradeCounts {
  const ProfileGradeCounts({
    required this.ss,
    required this.ssh,
    required this.s,
    required this.sh,
    required this.a,
  });
  final int ss;
  final int ssh;
  final int s;
  final int sh;
  final int a;
}

@immutable
final class ProfileRankHistory {
  ProfileRankHistory({required this.ruleset, required List<int?> ranks})
    : ranks = List<int?>.unmodifiable(ranks);
  final ProfileRuleset ruleset;

  /// API observation order, not inferred timestamps. null means unranked/gap.
  final List<int?> ranks;
}
