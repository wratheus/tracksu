import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

abstract interface class ProfileRepository {
  Future<Profile> getCurrentProfile({required ProfileRuleset ruleset});
}
