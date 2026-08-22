import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

abstract interface class ProfileRemoteSource {
  Future<Map<String, dynamic>> getCurrentProfile({
    required ProfileRuleset ruleset,
  });

  Future<Map<String, dynamic>> getProfile({
    required String userIdentifier,
    required ProfileRuleset ruleset,
  });
}
