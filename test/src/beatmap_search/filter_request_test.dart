import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tracksu/src/beatmap_search/data/remote_source.dart';
import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu_network/tracksu_network.dart';

void main() {
  test('any ruleset omits mode; genre and language survive paging', () async {
    final List<Uri> calls = [];
    final client = HttpRestClient(
      client: MockClient((request) async {
        calls.add(request.url);
        return http.Response(
          '{}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
      baseUri: Uri.parse('https://osu.ppy.sh/api/v2'),
    );
    addTearDown(client.close);
    final source = BeatmapSearchRemoteSource(restClient: client);
    final query = const BeatmapSearchQuery().copyWith(
      anyRuleset: true,
      genre: BeatmapGenre.electronic,
      language: BeatmapLanguage.instrumental,
    );
    await source.search(query);
    await source.search(query, cursor: 'next');
    expect(calls.first.queryParameters.containsKey('m'), isFalse);
    expect(calls.last.queryParameters, containsPair('g', '10'));
    expect(calls.last.queryParameters, containsPair('l', '5'));
    expect(calls.last.queryParameters, containsPair('cursor_string', 'next'));
    await source.search(
      query.copyWith(genre: BeatmapGenre.any, language: BeatmapLanguage.any),
    );
    expect(calls.last.queryParameters.containsKey('g'), isFalse);
    expect(calls.last.queryParameters.containsKey('l'), isFalse);
  });
}
