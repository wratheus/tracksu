import 'package:bloc/bloc.dart';
import 'package:tracksu/src/beatmap/domain/repository.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';

part 'event.dart';
part 'state.dart';

final class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  factory LeaderboardBloc({
    required LeaderboardRepository repository,
    required LeaderboardQuery query,
  }) => LeaderboardBloc._(repository, query);

  LeaderboardBloc._(this._repository, this._query)
    : super(const LeaderboardLoadingState()) {
    // One fixed difficulty per scope; ignore refresh repeats while busy.
    on<LeaderboardEvent>(_onEvent);
  }
  final LeaderboardRepository _repository;
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
    final LeaderboardLoadedState? previous = state is LeaderboardLoadedState
        ? state as LeaderboardLoadedState
        : null;
    emit(
      previous == null
          ? const LeaderboardLoadingState()
          : LeaderboardLoadedState(previous.entries, refreshing: true),
    );
    try {
      final List<LeaderboardEntry> entries = await _repository.load(_query);
      if (isClosed || emit.isDone) return;
      emit(LeaderboardLoadedState(entries));
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
