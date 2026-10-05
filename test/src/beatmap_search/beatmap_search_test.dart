import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/beatmap_search/bloc/bloc.dart';
import 'package:tracksu/src/beatmap_search/data/repository_impl.dart';
import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';

Map<String, dynamic> _set(int id) => <String, dynamic>{
  'id': id,
  'title': 'Song $id',
  'artist': 'Artist',
  'creator': 'mapper',
  'status': 'ranked',
  'play_count': 10,
  'favourite_count': 2,
  'covers': <String, dynamic>{},
  'preview_url': '//b.ppy.sh/preview/$id.mp3',
  'beatmaps': <Object?>[],
};

/// Shape of osu-web BeatmapsetSearchResult.
Map<String, dynamic> _result(List<int> ids, {String? cursor}) =>
    <String, dynamic>{
      'beatmapsets': <Object?>[for (final int id in ids) _set(id)],
      'search': <String, dynamic>{'sort': 'ranked_desc'},
      'recommended_difficulty': null,
      'error': null,
      'total': 120,
      'cursor': cursor == null ? null : <String, dynamic>{'id': 1},
      'cursor_string': cursor,
    };

final class _Repository implements BeatmapSearchRepository {
  final List<({BeatmapSearchQuery query, String? cursor})> calls = [];
  final List<BeatmapSearchPage> pages = <BeatmapSearchPage>[];

  @override
  Future<BeatmapSearchPage> search(
    BeatmapSearchQuery query, {
    String? cursor,
  }) async {
    calls.add((query: query, cursor: cursor));
    return pages.removeAt(0);
  }
}

void main() {
  test('result decodes sets, cursor and total', () {
    final BeatmapSearchPage page = BeatmapSearchRepositoryImpl.decode(
      _result(<int>[1, 2], cursor: 'abc'),
    );
    expect(page.items.map((b) => b.id), <int>[1, 2]);
    expect(page.items.first.isBeatmapset, isTrue);
    expect(page.cursor, 'abc');
    expect(page.total, 120);
    expect(
      BeatmapSearchRepositoryImpl.decode(_result(<int>[3])).cursor,
      isNull,
    );
  });

  test('duplicate sets fail loudly', () {
    expect(
      () => BeatmapSearchRepositoryImpl.decode(_result(<int>[1, 1])),
      throwsFormatException,
    );
  });

  test('next page uses the cursor; a new query starts over', () async {
    final _Repository repository = _Repository()
      ..pages.addAll(<BeatmapSearchPage>[
        BeatmapSearchRepositoryImpl.decode(_result(<int>[1, 2], cursor: 'c1')),
        BeatmapSearchRepositoryImpl.decode(_result(<int>[2, 3])),
        BeatmapSearchRepositoryImpl.decode(_result(<int>[9])),
      ]);
    final BeatmapSearchBloc bloc = BeatmapSearchBloc(repository: repository);
    bloc.add(const BeatmapSearchQueryChanged(BeatmapSearchQuery()));
    await bloc.stream.firstWhere((s) => s.items != null && !s.busy);

    bloc.add(const BeatmapSearchMoreRequested());
    await bloc.stream.firstWhere((s) => s.items!.length == 3 && !s.busy);
    expect(repository.calls[1].cursor, 'c1');
    expect(bloc.state.cursor, isNull);

    bloc.add(
      const BeatmapSearchQueryChanged(BeatmapSearchQuery(text: 'freedom')),
    );
    await bloc.stream.firstWhere(
      (s) => s.query.text == 'freedom' && s.items != null && !s.busy,
    );
    expect(bloc.state.items!.map((b) => b.id), <int>[9]);
    expect(repository.calls[2].cursor, isNull);
    await bloc.close();
  });
}
