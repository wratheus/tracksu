import 'package:tracksu_network/tracksu_network.dart';

abstract interface class DailyChallengeRemoteSource {
  Future<Object?> activeRooms();
  Future<Map<String, dynamic>> leaderboard(int roomId);
}

final class DailyChallengeRemoteException implements Exception {
  const DailyChallengeRemoteException(this.statusCode);
  final int statusCode;
}

/// `GET /rooms?category=daily_challenge` — documented as "Get Multiplayer
/// Rooms"; daily-challenge rooms are returned only from response version
/// 20240529, so this request alone asks for that version (the app default
/// stays older). `GET /rooms/{room}/leaderboard` has no docblock but is open
/// to the public scope in RoomsController.
final class OsuDailyChallengeRemoteSource
    implements DailyChallengeRemoteSource {
  const OsuDailyChallengeRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;

  static const String _roomsVersion = '20240529';

  @override
  Future<Object?> activeRooms() async {
    final RestResponse response = await _client.get(
      path: '/rooms',
      headers: const <String, String>{'x-api-version': _roomsVersion},
      queryParameters: const <String, Object?>{
        'category': 'daily_challenge',
        'mode': 'active',
        'limit': 1,
      },
    );
    if (response.statusCode != 200) {
      throw DailyChallengeRemoteException(response.statusCode);
    }
    return response.payload.value;
  }

  @override
  Future<Map<String, dynamic>> leaderboard(int roomId) async {
    final RestResponse response = await _client.get(
      path: '/rooms/$roomId/leaderboard',
    );
    if (response.statusCode != 200) {
      throw DailyChallengeRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
