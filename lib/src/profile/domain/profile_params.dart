import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

final class ProfileParams {
  const ProfileParams({required this.user, required this.ruleset});

  /// Opens the player in their own main mode, known only from the profile
  /// itself: one request instead of a lookup followed by the profile.
  const ProfileParams.defaultMode({required this.user}) : ruleset = null;

  final ProfileUserReference user;

  /// Null: the player's default mode (`playmode`).
  final ProfileRuleset? ruleset;
}
