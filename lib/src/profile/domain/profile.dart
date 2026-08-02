import 'package:meta/meta.dart';

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
  });

  final int id;
  final String username;
  final Uri avatarUri;
  final String countryCode;
  final bool isOnline;
  final bool isSupporter;
  final ProfileStatistics? statistics;
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
  });

  final double performancePoints;
  final int? globalRank;
  final int? countryRank;
  final double hitAccuracy;
  final int playCount;
  final int playTime;
  final int maximumCombo;
}
