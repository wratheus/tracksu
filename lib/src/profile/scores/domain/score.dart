import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// Summary projection of API response version 20220705+, not the legacy Score.
final class ProfileScore {
  ProfileScore({
    required this.id,
    required this.beatmapId,
    required this.userId,
    required this.ruleset,
    required this.accuracy,
    required this.totalScore,
    required this.maximumCombo,
    required this.rank,
    required this.passed,
    required this.performancePoints,
    required this.endedAt,
    required List<String> mods,
  }) : mods = List<String>.unmodifiable(mods);

  final int id;
  final int beatmapId;
  final int userId;
  final ProfileRuleset ruleset;

  /// Fraction in [0, 1], unlike profile hitAccuracy, which is a percentage.
  final double accuracy;
  final int totalScore;
  final int maximumCombo;
  final String rank;
  final bool passed;
  final double? performancePoints;
  final DateTime endedAt;

  /// Display acronyms, not a complete mod-settings model.
  final List<String> mods;
}

final class ProfileScoresPage {
  ProfileScoresPage({
    required List<ProfileScore> items,
    required this.nextOffset,
  }) : items = List<ProfileScore>.unmodifiable(items);

  final List<ProfileScore> items;

  /// A full page suggests another read; the endpoint supplies no total/cursor.
  final int? nextOffset;
}
