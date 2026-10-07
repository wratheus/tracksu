import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/daily/bloc/bloc.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

DailyChallenge _day(int id) => DailyChallenge(
  roomId: id,
  beatmapId: id,
  ruleset: ProfileRuleset.osu,
  title: 'Day $id',
  artist: 'Artist',
  version: 'Hard',
  stars: 4,
  requiredMods: const <String>[],
);

final class _Repository implements DailyChallengeRepository {
  final List<int> limits = <int>[];
  List<DailyChallenge> days = <DailyChallenge>[_day(1)];
  bool fail = false;
  @override
  Future<List<DailyChallenge>> history({required int limit}) async {
    limits.add(limit);
    if (fail) {
      throw const DailyChallengeFailure(DailyChallengeFailureKind.connection);
    }
    return days;
  }

  @override
  Future<DailyChallenge?> today() async => days.first;
  @override
  Future<List<DailyChallengeScore>> leaderboard(int roomId) async => [];
}

Future<void> _request(DailyHistoryBloc bloc, DailyHistoryEvent event) async {
  final Future<DailyHistoryState> loaded = bloc.stream.firstWhere(
    (s) => !s.busy,
  );
  bloc.add(event);
  await loaded;
}

void main() {
  test('failed refresh retains rows and the end of history', () async {
    final _Repository repository = _Repository();
    final DailyHistoryBloc bloc = DailyHistoryBloc(repository: repository);
    addTearDown(bloc.close);
    await _request(bloc, const DailyHistoryRequested());
    expect(bloc.state.done, isTrue);
    repository.fail = true;
    await _request(bloc, const DailyHistoryRequested());
    expect(bloc.state.items!.single.roomId, 1);
    expect(bloc.state.done, isTrue);
    expect(bloc.state.failure, DailyChallengeFailureKind.connection);
  });
  test(
    'retry repeats refresh or load-more without skipping its limit',
    () async {
      final _Repository repository = _Repository()
        ..days = List.generate(30, (i) => _day(i + 1));
      final DailyHistoryBloc bloc = DailyHistoryBloc(repository: repository);
      addTearDown(bloc.close);
      await _request(bloc, const DailyHistoryRequested());
      repository.fail = true;
      await _request(bloc, const DailyHistoryMoreRequested());
      expect(bloc.state.items, hasLength(30));
      repository.fail = false;
      repository.days = List.generate(60, (i) => _day(i + 1));
      await _request(bloc, const DailyHistoryRetryRequested());
      expect(repository.limits, [30, 60, 60]);
      expect(bloc.state.items, hasLength(60));
      repository.fail = true;
      await _request(bloc, const DailyHistoryRequested());
      repository.fail = false;
      await _request(bloc, const DailyHistoryRetryRequested());
      expect(repository.limits, [30, 60, 60, 60, 60]);
    },
  );
}
