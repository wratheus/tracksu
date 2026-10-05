import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class BeatmapSearchRemoteException implements Exception {
  const BeatmapSearchRemoteException(this.statusCode);
  final int statusCode;
}

/// `GET /beatmapsets/search` — the beatmap listing endpoint
/// (`BeatmapsetsController@search`, public scope). Without a signed-in
/// user osu-web ignores `sort` and the advanced query syntax, so the app
/// sends only text, ruleset, status and the cursor; NSFW sets stay hidden.
final class BeatmapSearchRemoteSource {
  const BeatmapSearchRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;

  Future<Map<String, dynamic>> search(
    BeatmapSearchQuery query, {
    String? cursor,
  }) async {
    final RestResponse response = await _client.get(
      path: '/beatmapsets/search',
      queryParameters: <String, Object?>{
        if (query.text.trim().isNotEmpty) 'q': query.text.trim(),
        // Ruleset ids: osu 0, taiko 1, fruits 2, mania 3 (enum order).
        'm': query.ruleset.index,
        's': query.status.apiValue,
        'nsfw': 'false',
        'cursor_string': ?cursor,
      },
    );
    if (response.statusCode != 200) {
      throw BeatmapSearchRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
