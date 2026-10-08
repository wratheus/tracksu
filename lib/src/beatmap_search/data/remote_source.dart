import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class BeatmapSearchRemoteException implements Exception {
  const BeatmapSearchRemoteException(this.statusCode);
  final int statusCode;
}

/// `GET /beatmapsets/search` — the beatmap listing endpoint
/// (`BeatmapsetsController@search`, public scope). Without a signed-in
/// user osu-web ignores `sort` and the advanced query syntax, so the app
/// sends only text, ruleset (or none = any), status, genre, language and the
/// cursor; NSFW sets stay hidden.
final class BeatmapSearchRemoteSource {
  const BeatmapSearchRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;

  Future<Map<String, dynamic>> search(
    BeatmapSearchQuery query, {
    String? cursor,
    RestCancellationToken? cancellationToken,
  }) async {
    final RestResponse response = await _client.get(
      path: '/beatmapsets/search',
      options: RestClientOptions(cancellationToken: cancellationToken),
      queryParameters: <String, Object?>{
        if (query.text.trim().isNotEmpty) 'q': query.text.trim(),
        // Ruleset ids: osu 0, taiko 1, fruits 2, mania 3 (enum order);
        // absent = any mode.
        'm': query.ruleset?.index,
        's': query.status.apiValue,
        'g': query.genre.id,
        'l': query.language.id,
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
