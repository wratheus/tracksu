import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

/// Event types of `GET /users/{id}/recent_activity` (osu-web Event).
enum ProfileActivityKind {
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
final class ProfileActivity {
  const ProfileActivity({
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
    this.username,
    this.previousUsername,
  });

  final int id;
  final ProfileActivityKind kind;
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
  final String? username;
  final String? previousUsername;
}

final class ProfileActivityQuery {
  ProfileActivityQuery({required this.user, this.limit = 20, this.offset = 0}) {
    if (limit < 1 || limit > 100 || offset < 0) {
      throw ArgumentError('Expected limit 1..100 and a non-negative offset.');
    }
  }
  final ProfileUserId user;
  final int limit;
  final int offset;
}

final class ProfileActivityPage {
  ProfileActivityPage({required List<ProfileActivity> items, this.nextOffset})
    : items = List<ProfileActivity>.unmodifiable(items);
  final List<ProfileActivity> items;
  final int? nextOffset;
}

enum ProfileActivityFailureKind {
  cancelled,
  notFound,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class ProfileActivityFailure implements Exception {
  const ProfileActivityFailure(this.kind);
  final ProfileActivityFailureKind kind;
}

abstract interface class ProfileActivityRepository {
  Future<ProfileActivityPage> load(ProfileActivityQuery query);
  void cancelPending();
}
