import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/spotlights/bloc/bloc.dart';
import 'package:tracksu/src/spotlights/domain/spotlight.dart';

/// osu-web answers 404 when a chart has no table for the requested ruleset.
final class _Repository implements SpotlightsRepository {
  @override
  Future<List<Spotlight>> catalog() async => const <Spotlight>[
    Spotlight(id: 68, name: 'Best of 2012', kind: SpotlightKind.bestOf),
  ];

  @override
  Future<SpotlightDetails> load(SpotlightQuery query) async {
    if (query.ruleset != ProfileRuleset.osu) {
      throw const RankingsFailure(RankingsFailureKind.notFound);
    }
    return SpotlightDetails(
      spotlight: const Spotlight(
        id: 68,
        name: 'Best of 2012',
        kind: SpotlightKind.bestOf,
      ),
      players: const <SpotlightPlayer>[],
      maps: const <SpotlightMap>[],
    );
  }

  @override
  void cancelPending() {}
}

Future<SpotlightsLoadedState> _settled(SpotlightsBloc bloc) async =>
    await bloc.stream.firstWhere(
      (SpotlightsState state) =>
          state is SpotlightsLoadedState && !state.loading,
    ) as SpotlightsLoadedState;

void main() {
  test('a ruleset without a chart is an empty state, not an error', () async {
    final SpotlightsBloc bloc = SpotlightsBloc(
      repository: _Repository(),
      cache: PageCache(identityRevision: () => 0),
    )..add(const SpotlightsStarted());
    addTearDown(bloc.close);

    final SpotlightsLoadedState osu = await _settled(bloc);
    expect(osu.details, isNotNull);
    expect(osu.rulesetUnavailable, isFalse);

    bloc.add(const SpotlightRulesetSelected(ProfileRuleset.taiko));
    final SpotlightsLoadedState taiko = await _settled(bloc);
    expect(taiko.rulesetUnavailable, isTrue);
    expect(taiko.failure, isNull);
    expect(taiko.details, isNull);
    expect(taiko.ruleset, ProfileRuleset.taiko);

    bloc.add(const SpotlightRulesetSelected(ProfileRuleset.osu));
    final SpotlightsLoadedState back = await _settled(bloc);
    expect(back.rulesetUnavailable, isFalse);
    expect(back.details?.spotlight.id, 68);
  });
}
