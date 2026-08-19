import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

abstract interface class ProfileRepository {
  Future<Profile> getCurrentProfile({required ProfileRuleset ruleset});

  Future<Profile> getProfile({
    required ProfileUserReference user,
    required ProfileRuleset ruleset,
  });
}
