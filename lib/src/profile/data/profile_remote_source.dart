import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class ProfileRemoteSource {
  Future<Map<String, dynamic>> getCurrentProfile({
    required ProfileRuleset ruleset,
    RestClientOptions options = const RestClientOptions(),
  });

  Future<Map<String, dynamic>> getProfile({
    required String userIdentifier,
    required ProfileRuleset ruleset,
    RestClientOptions options = const RestClientOptions(),
  });
}
