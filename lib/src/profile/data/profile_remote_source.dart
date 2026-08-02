import 'package:tracksu/src/profile/data/profile_dto.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

abstract interface class ProfileRemoteSource {
  Future<ProfileDto> getCurrentProfile({required ProfileRuleset ruleset});
}
