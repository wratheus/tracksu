import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

abstract interface class ProfileRepository {
  /// Cancels this feature's active read without closing shared clients.
  void cancelPending();

  Future<Profile> getCurrentProfile({required ProfileRuleset ruleset});

  Future<Profile> getProfile({
    required ProfileUserReference user,
    required ProfileRuleset ruleset,
  });
}
