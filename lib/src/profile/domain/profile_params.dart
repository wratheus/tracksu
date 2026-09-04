import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

final class ProfileParams {
  const ProfileParams({required this.user, required this.ruleset});
  final ProfileUserId user;
  final ProfileRuleset ruleset;
}
