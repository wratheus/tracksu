import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/rankings/kudosu/bloc/bloc.dart';
import 'package:tracksu/src/rankings/kudosu/data/repository_impl.dart';
import 'package:tracksu/src/rankings/kudosu/domain/kudosu_ranking.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';

Map<String, dynamic> _user(int id) => {
  'id': id,
  'username': 'Mapper $id',
  'kudosu': {'total': 100, 'available': 5},
};
KudosuRankingPage _page(List<int> ids, int page) =>
    KudosuRankingRepositoryImpl.decode({
      'ranking': [for (final id in ids) _user(id)],
    }, page);

final class _Repository implements KudosuRankingRepository {
  bool fail = false;
  final List<int> calls = [];
  @override
  Future<KudosuRankingPage> load(int page) async {
    calls.add(page);
    if (fail) throw const RankingsFailure(RankingsFailureKind.connection);
    return _page(List.generate(50, (i) => (page - 1) * 49 + i + 1), page);
  }
}

Future<void> _request(KudosuRankingBloc bloc, KudosuRankingEvent event) async {
  final done = bloc.stream.firstWhere((s) => s.operation == null);
  bloc.add(event);
  await done;
}

void main() {
  test('last full page stops at 1000; missing kudosu fails decoding', () {
    final page = _page(List.generate(50, (i) => i + 951), 20);
    expect(page.items.first.position, 951);
    expect(page.items.last.position, 1000);
    expect(page.nextPage, isNull);
    expect(
      () => KudosuRankingRepositoryImpl.decode({
        'ranking': [
          {'id': 1, 'username': 'Mapper'},
        ],
      }, 1),
      throwsFormatException,
    );
  });
  test(
    'paging deduplicates, failed refresh preserves rows and retry recovers',
    () async {
      final repository = _Repository();
      final bloc = KudosuRankingBloc(repository: repository);
      addTearDown(bloc.close);
      await _request(bloc, const KudosuRankingRequested());
      await _request(bloc, const KudosuRankingMoreRequested());
      expect(bloc.state.items, hasLength(99));
      repository.fail = true;
      await _request(bloc, const KudosuRankingRequested());
      expect(bloc.state.items, hasLength(99));
      expect(bloc.state.failedOperation, KudosuRankingOperation.refresh);
      repository.fail = false;
      await _request(bloc, const KudosuRankingRequested());
      expect(bloc.state.items, hasLength(50));
      expect(repository.calls, [1, 2, 1, 1]);
    },
  );
}
