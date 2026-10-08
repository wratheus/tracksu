import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';
import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';

sealed class BeatmapSearchEvent {
  const BeatmapSearchEvent();
}

/// Also the start event.
final class BeatmapSearchQueryChanged extends BeatmapSearchEvent {
  const BeatmapSearchQueryChanged(this.query);
  final BeatmapSearchQuery query;
}

final class BeatmapSearchRefreshRequested extends BeatmapSearchEvent {
  const BeatmapSearchRefreshRequested();
}

final class BeatmapSearchMoreRequested extends BeatmapSearchEvent {
  const BeatmapSearchMoreRequested();
}

final class BeatmapSearchPaused extends BeatmapSearchEvent {
  const BeatmapSearchPaused({this.text});
  final String? text;
}

enum BeatmapSearchOperation { refresh, loadMore }

/// [items] is null until the first page of the current query arrives.
@immutable
final class BeatmapSearchState {
  BeatmapSearchState({
    required this.query,
    List<ProfileBeatmap>? items,
    this.cursor,
    this.total,
    this.operation,
    this.failure,
    this.failedOperation,
    this.started = false,
  }) : items = items == null ? null : List.unmodifiable(items);
  final BeatmapSearchQuery query;
  final List<ProfileBeatmap>? items;
  final String? cursor;
  final int? total;
  final BeatmapSearchOperation? operation;
  final BeatmapSearchFailureKind? failure;
  final BeatmapSearchOperation? failedOperation;
  final bool started;

  bool get busy => operation != null;
}

/// Latest query wins; pages of an older query are dropped and paging never
/// duplicates a beatmapset.
final class BeatmapSearchBloc
    extends Bloc<BeatmapSearchEvent, BeatmapSearchState> {
  BeatmapSearchBloc({
    required this._repository,
    this.minimumQueryLength = 0,
    BeatmapSearchQuery initial = const BeatmapSearchQuery(),
  }) : super(BeatmapSearchState(query: initial)) {
    on<BeatmapSearchEvent>(_onEvent, transformer: concurrent());
  }

  final BeatmapSearchRepository _repository;
  int _generation = 0;
  final int minimumQueryLength;
  final Map<BeatmapSearchQuery, (DateTime, BeatmapSearchState)> _cache = {};

  @override
  Future<void> close() {
    _generation++;
    _repository.cancelPending();
    return super.close();
  }

  Future<void> _onEvent(
    BeatmapSearchEvent event,
    Emitter<BeatmapSearchState> emit,
  ) async {
    BeatmapSearchQuery query = state.query;
    bool more = false;
    switch (event) {
      case BeatmapSearchPaused():
        _generation++;
        _repository.cancelPending();
        emit(BeatmapSearchState(query: query.copyWith(text: event.text)));
        return;
      case BeatmapSearchQueryChanged():
        if (state.started && event.query == query) return;
        query = event.query;
        final cached = _cache[query];
        if (cached != null &&
            DateTime.now().difference(cached.$1) < const Duration(minutes: 2)) {
          _generation++;
          _repository.cancelPending();
          emit(cached.$2);
          return;
        }
      case BeatmapSearchRefreshRequested():
        if (state.busy) return;
      case BeatmapSearchMoreRequested():
        if (state.busy ||
            state.items == null ||
            state.cursor == null ||
            state.failedOperation == BeatmapSearchOperation.refresh) {
          return;
        }
        more = true;
    }
    if (query.text.length < minimumQueryLength) {
      _generation++;
      _repository.cancelPending();
      emit(BeatmapSearchState(query: query));
      return;
    }
    final int generation = more ? _generation : ++_generation;
    final BeatmapSearchOperation operation = more
        ? BeatmapSearchOperation.loadMore
        : BeatmapSearchOperation.refresh;
    final bool sameQuery = query == state.query;
    final List<ProfileBeatmap>? previous = sameQuery ? state.items : null;
    final String? previousCursor = sameQuery ? state.cursor : null;
    emit(
      BeatmapSearchState(
        query: query,
        items: previous,
        cursor: previousCursor,
        total: sameQuery ? state.total : null,
        operation: operation,
        started: true,
      ),
    );
    try {
      final BeatmapSearchPage page = await _repository.search(
        query,
        cursor: more ? previousCursor : null,
      );
      if (generation != _generation || isClosed) return;
      final Map<int, ProfileBeatmap> unique = <int, ProfileBeatmap>{
        if (more)
          for (final ProfileBeatmap b in previous ?? const <ProfileBeatmap>[])
            b.id: b,
      };
      final int before = unique.length;
      for (final ProfileBeatmap b in page.items) {
        unique.putIfAbsent(b.id, () => b);
      }
      if (more && page.cursor != null && unique.length == before) {
        throw const BeatmapSearchFailure(
          BeatmapSearchFailureKind.invalidResponse,
        );
      }
      emit(
        BeatmapSearchState(
          query: query,
          items: unique.values.toList(growable: false),
          cursor: page.cursor,
          total: page.total ?? state.total,
          started: true,
        ),
      );
      _cache.remove(query);
      _cache[query] = (DateTime.now(), state);
      if (_cache.length > 10) _cache.remove(_cache.keys.first);
    } on Object catch (error, stackTrace) {
      if (generation != _generation || isClosed) return;
      final BeatmapSearchFailureKind kind = error is BeatmapSearchFailure
          ? error.kind
          : BeatmapSearchFailureKind.unavailable;
      addError(BeatmapSearchFailure(kind), stackTrace);
      emit(
        BeatmapSearchState(
          query: query,
          items: previous,
          cursor: previousCursor,
          total: state.total,
          failure: kind,
          failedOperation: operation,
          started: true,
        ),
      );
    }
  }
}
