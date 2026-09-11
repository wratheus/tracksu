import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';

final class LeaderboardQuery {
  const LeaderboardQuery({
    required this.beatmapId,
    required this.ruleset,
    this.legacy = false,
  });
  final int beatmapId;
  final ProfileRuleset ruleset;
  final bool legacy;
}

final class LeaderboardEntry {
  const LeaderboardEntry({
    required this.score,
    required this.username,
    this.avatarUri,
    this.countryCode,
    this.team,
  });
  final OsuScore score;
  final String? username;
  final Uri? avatarUri;
  final String? countryCode;
  final ProfileTeam? team;
}

abstract interface class LeaderboardRepository {
  Future<List<LeaderboardEntry>> load(LeaderboardQuery query);
  void cancelPending();
}
