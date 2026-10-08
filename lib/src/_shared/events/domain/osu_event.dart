import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// osu-web Event types: a player's recent activity and the global feed.
enum OsuEventKind {
  achievement,
  beatmapPlaycount,
  beatmapsetApprove,
  beatmapsetDelete,
  beatmapsetRevive,
  beatmapsetUpdate,
  beatmapsetUpload,
  rank,
  rankLost,
  userSupportAgain,
  userSupportFirst,
  userSupportGift,
  usernameChange,
}

/// One profile event. Fields are filled only where the event type has them;
/// IDs are read from the website links the API returns (`/b/1`, `/s/2`).
final class OsuEvent {
  const OsuEvent({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.ruleset,
    this.rank,
    this.grade,
    this.count,
    this.approval,
    this.beatmapId,
    this.beatmapsetId,
    this.title,
    this.medalName,
    this.medalIcon,
    this.userId,
    this.username,
    this.previousUsername,
  });

  final int id;
  final OsuEventKind kind;
  final DateTime createdAt;
  final ProfileRuleset? ruleset;

  /// Leaderboard position for `rank`.
  final int? rank;

  /// Score grade (XH, X, SH, S, A, B, C, D) for `rank`.
  final String? grade;

  /// Play count milestone for `beatmapPlaycount`.
  final int? count;

  /// `ranked`, `approved`, `qualified` or `loved` for `beatmapsetApprove`.
  final String? approval;
  final int? beatmapId;
  final int? beatmapsetId;

  /// Beatmap or beatmapset title as the API formats it.
  final String? title;
  final String? medalName;
  final Uri? medalIcon;
  /// Player the event is about (the beatmapset owner for map events).
  final int? userId;
  final String? username;
  final String? previousUsername;
}

/// Feed filters: the API has no type filter, so the client groups the
/// event types it already parses.
enum OsuEventFilter {
  all,
  ranks,
  medals,
  beatmaps,
  supporters;

  bool matches(OsuEventKind kind) => switch (this) {
    OsuEventFilter.all => true,
    OsuEventFilter.ranks =>
      kind == OsuEventKind.rank || kind == OsuEventKind.rankLost,
    OsuEventFilter.medals => kind == OsuEventKind.achievement,
    OsuEventFilter.beatmaps => switch (kind) {
      OsuEventKind.beatmapPlaycount ||
      OsuEventKind.beatmapsetApprove ||
      OsuEventKind.beatmapsetDelete ||
      OsuEventKind.beatmapsetRevive ||
      OsuEventKind.beatmapsetUpdate ||
      OsuEventKind.beatmapsetUpload => true,
      _ => false,
    },
    OsuEventFilter.supporters => switch (kind) {
      OsuEventKind.userSupportAgain ||
      OsuEventKind.userSupportFirst ||
      OsuEventKind.userSupportGift ||
      OsuEventKind.usernameChange => true,
      _ => false,
    },
  };
}
