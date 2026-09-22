import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/beatmap/domain/repository.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';

part 'event.dart';
part 'state.dart';

final class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  factory LeaderboardBloc({
    required LeaderboardRepository repository,
    required PageCache cache,
    required LeaderboardQuery query,
  }) => LeaderboardBloc._(repository, cache, query);

  LeaderboardBloc._(this._repository, this._cache, this._query)
    : super(const LeaderboardLoadingState()) {
    // One fixed difficulty per scope; ignore refresh repeats while busy.
    on<LeaderboardEvent>(_onEvent, transformer: droppable());
  }
  final LeaderboardRepository _repository;
  final PageCache _cache;
  final LeaderboardQuery _query;
  bool _busy = false;

  Future<void> _onEvent(
    LeaderboardEvent event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (_busy) return;
    switch (event) {
      case LeaderboardLoadRequested():
        break;
    }
    _busy = true;
    final Object cacheKey = (
      'beatmap-leaderboard',
      _query.beatmapId,
      _query.ruleset,
      _query.legacy,
    );
    final int cacheRevision = _cache.revision;
    final List<LeaderboardEntry>? cached = _cache.read<List<LeaderboardEntry>>(
      cacheKey,
    );
    final LeaderboardLoadedState? previous = state is LeaderboardLoadedState
        ? state as LeaderboardLoadedState
        : cached == null
        ? null
        : LeaderboardLoadedState(cached);
    emit(
      previous == null
          ? const LeaderboardLoadingState()
          : LeaderboardLoadedState(previous.entries, refreshing: true),
    );
    try {
      final List<LeaderboardEntry> entries = await _repository.load(_query);
      if (isClosed || emit.isDone) return;
      final LeaderboardLoadedState loaded = LeaderboardLoadedState(entries);
      _cache.write(cacheKey, loaded.entries, revision: cacheRevision);
      emit(loaded);
    } on Object catch (error, stackTrace) {
      if (isClosed || emit.isDone) return;
      final BeatmapFailureKind kind = error is BeatmapFailure
          ? error.kind
          : BeatmapFailureKind.unavailable;
      addError(BeatmapFailure(kind), stackTrace);
      emit(
        previous == null
            ? LeaderboardErrorState(kind)
            : LeaderboardLoadedState(previous.entries, failure: kind),
      );
    } finally {
      _busy = false;
    }
  }

  @override
  Future<void> close() {
    _repository.cancelPending();
    return super.close();
  }
}
