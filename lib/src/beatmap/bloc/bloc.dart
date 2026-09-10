import 'package:bloc/bloc.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/domain/repository.dart';

part 'event.dart';
part 'state.dart';

final class BeatmapBloc extends Bloc<BeatmapEvent, BeatmapState> {
  factory BeatmapBloc({
    required BeatmapRepository repository,
    required PageCache cache,
    required BeatmapParams params,
  }) => BeatmapBloc._(repository, cache, params);

  BeatmapBloc._(this._repository, this._cache, this._params)
    : super(const BeatmapLoadingState()) {
    // Reads are guarded while busy. Selection is local and does not start IO.
    on<BeatmapEvent>(_onEvent);
  }
  final BeatmapRepository _repository;
  final PageCache _cache;
  final BeatmapParams _params;
  bool _busy = false;

  Future<void> _onEvent(BeatmapEvent event, Emitter<BeatmapState> emit) async {
    if (_busy) return;
    switch (event) {
      case BeatmapSelected(:final id):
        if (state case final BeatmapLoadedState current) {
          if (!current.details.difficulties.any(
            (BeatmapDifficulty d) => d.id == id,
          )) {
            return;
          }
          emit(BeatmapLoadedState(details: current.details, selectedId: id));
        }
        return;
      case BeatmapLoadRequested():
        break;
    }
    final Object cacheKey = ('beatmap', _params.runtimeType, _params.id);
    final int cacheRevision = _cache.revision;
    final BeatmapDetails? cached = _cache.read<BeatmapDetails>(cacheKey);
    final int? preferredCachedId = _params is BeatmapDifficultyParams
        ? _params.id
        : null;
    final BeatmapLoadedState? previous = state is BeatmapLoadedState
        ? state as BeatmapLoadedState
        : cached == null
        ? null
        : BeatmapLoadedState(
            details: cached,
            selectedId:
                cached.difficulties.any(
                  (BeatmapDifficulty d) => d.id == preferredCachedId,
                )
                ? preferredCachedId
                : cached.difficulties.firstOrNull?.id,
          );
    _busy = true;
    emit(
      previous == null
          ? const BeatmapLoadingState()
          : BeatmapLoadedState(
              details: previous.details,
              selectedId: previous.selectedId,
              refreshing: true,
            ),
    );
    try {
      final BeatmapDetails details = await _repository.load(_params);
      if (emit.isDone || isClosed) return;
      _cache.write(cacheKey, details, revision: cacheRevision);
      final int? preferred =
          previous?.selectedId ??
          (_params is BeatmapDifficultyParams ? _params.id : null);
      final int? selected =
          details.difficulties.any((BeatmapDifficulty d) => d.id == preferred)
          ? preferred
          : details.difficulties.firstOrNull?.id;
      emit(BeatmapLoadedState(details: details, selectedId: selected));
    } on Object catch (error, stackTrace) {
      if (emit.isDone || isClosed) return;
      final BeatmapFailureKind failure = error is BeatmapFailure
          ? error.kind
          : BeatmapFailureKind.unavailable;
      addError(BeatmapFailure(failure), stackTrace);
      emit(
        previous == null
            ? BeatmapErrorState(failure)
            : BeatmapLoadedState(
                details: previous.details,
                selectedId: previous.selectedId,
                failure: failure,
              ),
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
