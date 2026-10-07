import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/beatmap/leaderboard/bloc/bloc.dart';
import 'package:tracksu/src/beatmap/leaderboard/data/remote_source.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class _Repository implements LeaderboardRepository {
  Completer<List<LeaderboardEntry>> pending =
      Completer<List<LeaderboardEntry>>();
  @override
  Future<List<LeaderboardEntry>> load(LeaderboardQuery query) => pending.future;
  @override
  void cancelPending() {}
}

void main() {
  test('request distinguishes all scores, no mods and a combination', () async {
    final List<Uri> calls = [];
    final client = HttpRestClient(
      baseUri: Uri.parse('https://osu.ppy.sh/api/v2'),
      client: MockClient((request) async {
        calls.add(request.url);
        return http.Response(
          '{}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.close);
    final source = LeaderboardRemoteSource(restClient: client);
    for (final mods in <List<String>>[
      [],
      ['NM'],
      ['HD', 'HR'],
    ]) {
      await source.load(
        LeaderboardQuery(
          beatmapId: 42,
          ruleset: ProfileRuleset.osu,
          mods: mods,
        ),
        const RestClientOptions(),
      );
    }
    expect(calls[0].queryParameters.containsKey('mods[0]'), isFalse);
    expect(calls[1].queryParameters, containsPair('mods[0]', 'NM'));
    expect(calls[2].queryParameters, containsPair('mods[0]', 'HD'));
    expect(calls[2].queryParameters, containsPair('mods[1]', 'HR'));
  });
  test(
    'mod selection does not show cached rows for a different filter',
    () async {
      final repository = _Repository();
      final cache = PageCache(identityRevision: () => 0);
      final all = LeaderboardBloc(
        repository: repository,
        cache: cache,
        query: const LeaderboardQuery(
          beatmapId: 42,
          ruleset: ProfileRuleset.osu,
        ),
      );
      all.add(const LeaderboardLoadRequested());
      repository.pending.complete([]);
      await all.stream.firstWhere((s) => s is LeaderboardLoadedState);
      await all.close();
      repository.pending = Completer<List<LeaderboardEntry>>();
      final filtered = LeaderboardBloc(
        repository: repository,
        cache: cache,
        query: const LeaderboardQuery(
          beatmapId: 42,
          ruleset: ProfileRuleset.osu,
          mods: ['NM'],
        ),
      );
      final states = <LeaderboardState>[];
      final subscription = filtered.stream.listen(states.add);
      filtered.add(const LeaderboardLoadRequested());
      await Future<void>.delayed(Duration.zero);
      expect(filtered.state, isA<LeaderboardLoadingState>());
      expect(states.whereType<LeaderboardLoadedState>(), isEmpty);
      repository.pending.complete([]);
      await filtered.stream.firstWhere((s) => s is LeaderboardLoadedState);
      await subscription.cancel();
      await filtered.close();
    },
  );
}
