import 'package:meta/meta.dart';
import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// The current osu! daily challenge: a playlist room (category
/// `daily_challenge`) with one beatmap, a ruleset and required mods.
@immutable
final class DailyChallenge {
  DailyChallenge({
    required this.roomId,
    required this.beatmapId,
    required this.ruleset,
    required this.title,
    required this.artist,
    required this.version,
    required this.stars,
    required List<String> requiredMods,
    this.startsAt,
    this.endsAt,
    this.participantCount,
    this.metadata,
  }) : requiredMods = List<String>.unmodifiable(requiredMods);
  final int roomId;
  final int beatmapId;
  final ProfileRuleset ruleset;
  final String title;
  final String artist;

  /// Difficulty name.
  final String version;
  final double stars;
  final List<String> requiredMods;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? participantCount;
  final BeatmapMetadata? metadata;
}

/// One player's aggregate in the daily challenge room, in leaderboard order.
@immutable
final class DailyChallengeScore {
  const DailyChallengeScore({
    required this.position,
    required this.userId,
    required this.username,
    required this.country,
    required this.totalScore,
    required this.accuracy,
    required this.attempts,
    this.avatarUri,
    this.team,
  });
  final int position;
  final int userId;
  final String username;
  final String country;
  final int totalScore;

  /// 0..1.
  final double accuracy;
  final int attempts;
  final Uri? avatarUri;
  final ProfileTeam? team;
}

enum DailyChallengeFailureKind { connection, unavailable, invalidResponse }

final class DailyChallengeFailure implements Exception {
  const DailyChallengeFailure(this.kind, {this.cause});
  final DailyChallengeFailureKind kind;

  /// What went wrong underneath (status code, decode error), for logs only.
  final Object? cause;

  @override
  String toString() => 'DailyChallengeFailure(${kind.name}, $cause)';
}

abstract interface class DailyChallengeRepository {
  /// Null when osu! has no active daily challenge right now.
  Future<DailyChallenge?> today();

  /// Past days, newest first; at most [limit] (≤ 250).
  Future<List<DailyChallenge>> history({required int limit});
  Future<List<DailyChallengeScore>> leaderboard(int roomId);
}

/// Session-cache key of one day handed from the history list to its page.
Object dailyRoomCacheKey(int roomId) => ('daily-room', roomId);
