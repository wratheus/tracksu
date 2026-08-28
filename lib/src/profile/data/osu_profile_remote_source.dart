import 'package:tracksu/src/profile/data/profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_remote_source_exception.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class OsuProfileRemoteSource implements ProfileRemoteSource {
  factory OsuProfileRemoteSource({
    required RestClient restClient,
    required RestClient publicRestClient,
  }) {
    return OsuProfileRemoteSource._(restClient, publicRestClient);
  }

  const OsuProfileRemoteSource._(this._restClient, this._publicRestClient);

  final RestClient _restClient;
  final RestClient _publicRestClient;

  @override
  Future<Map<String, dynamic>> getCurrentProfile({
    required ProfileRuleset ruleset,
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final RestResponse response = await _restClient.get(
      path: '/me/${ruleset.apiValue}',
      options: options,
    );
    if (response.statusCode != 200) {
      throw ProfileRemoteSourceException(statusCode: response.statusCode);
    }

    return response.payload.asMap();
  }

  @override
  Future<Map<String, dynamic>> getProfile({
    required String userIdentifier,
    required ProfileRuleset ruleset,
    RestClientOptions options = const RestClientOptions(),
  }) async {
    final String encodedUserIdentifier = Uri.encodeComponent(userIdentifier);
    final RestResponse response = await _publicRestClient.get(
      path: '/users/$encodedUserIdentifier/${ruleset.apiValue}',
      options: options,
    );
    if (response.statusCode != 200) {
      throw ProfileRemoteSourceException(statusCode: response.statusCode);
    }

    return response.payload.asMap();
  }
}
