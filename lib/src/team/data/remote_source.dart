import 'package:tracksu/src/team/domain/team.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class TeamRemoteSource {
  Future<Map<String, dynamic>> load(
    TeamParams params,
    RestClientOptions options,
  );
}

final class OsuTeamRemoteSource implements TeamRemoteSource {
  const OsuTeamRemoteSource(this._client);
  final RestClient _client;
  @override
  Future<Map<String, dynamic>> load(
    TeamParams params,
    RestClientOptions options,
  ) async {
    final String mode = params.ruleset == null
        ? ''
        : '/${params.ruleset!.apiValue}';
    final RestResponse response = await _client.get(
      path: '/teams/${params.id}$mode',
      options: options,
    );
    if (response.statusCode != 200) {
      throw TeamRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}

final class TeamRemoteException implements Exception {
  const TeamRemoteException(this.statusCode);
  final int statusCode;
}
