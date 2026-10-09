import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/packs/data/packs_repository.dart';
import 'package:tracksu/src/packs/domain/packs.dart';

part 'event.dart';
part 'state.dart';

/// Packs of one type, newest first, 100 a page; the first page of each type
/// is cached for the session, so switching types back is instant.
final class BeatmapPacksBloc
    extends Bloc<BeatmapPacksEvent, BeatmapPacksState> {
  BeatmapPacksBloc({
    required BeatmapPackType type,
    required this._repository,
    required this._cache,
  }) : super(BeatmapPacksState(type: type)) {
    on<BeatmapPacksEvent>(_onEvent, transformer: sequential());
  }

  final BeatmapPacksRepository _repository;
  final PageCache _cache;
  static const Duration _minPageInterval = Duration(seconds: 1);
  DateTime _lastPage = DateTime.fromMillisecondsSinceEpoch(0);

  static Object _key(BeatmapPackType type) => ('beatmap-packs', type);

  Future<void> _onEvent(
    BeatmapPacksEvent event,
    Emitter<BeatmapPacksState> emit,
  ) async {
    final bool more;
    switch (event) {
      case BeatmapPacksStarted():
        if (state.items != null || state.busy) return;
        more = false;
      case BeatmapPacksTypeSelected(:final type):
        if (type == state.type) return;
        _repository.cancelPending();
        emit(BeatmapPacksState(type: type));
        more = false;
      case BeatmapPacksRefreshRequested():
        if (state.busy) return;
        more = false;
      case BeatmapPacksMoreRequested():
        if (state.busy || state.cursor == null) return;
        more = true;
        final Duration wait =
            _minPageInterval - DateTime.now().difference(_lastPage);
        if (wait > Duration.zero) await Future<void>.delayed(wait);
        if (isClosed) return;
        _lastPage = DateTime.now();
    }
    final BeatmapPackType type = state.type;
    if (!more && event is! BeatmapPacksRefreshRequested) {
      final BeatmapPacksPage? cached = _cache.read<BeatmapPacksPage>(
        _key(type),
      );
      if (cached != null) {
        emit(
          BeatmapPacksState(
            type: type,
            items: cached.items,
            cursor: cached.cursor,
          ),
        );
        return;
      }
    }
    final BeatmapPacksState before = state;
    emit(before.copyWith(busy: true, more: more));
    final int revision = _cache.revision;
    try {
      final BeatmapPacksPage page = await _repository.list(
        type,
        cursor: more ? before.cursor : null,
      );
      if (isClosed || state.type != type) return;
      if (!more) _cache.write(_key(type), page, revision: revision);
      emit(
        BeatmapPacksState(
          type: type,
          items: <BeatmapPack>[if (more) ...?before.items, ...page.items],
          cursor: page.cursor,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (isClosed || state.type != type) return;
      if (error is BeatmapPacksFailure &&
          error.kind == BeatmapPacksFailureKind.cancelled) {
        return;
      }
      addError(error, stackTrace);
      emit(
        BeatmapPacksState(
          type: type,
          items: before.items,
          cursor: before.cursor,
          failure: error is BeatmapPacksFailure
              ? error.kind
              : BeatmapPacksFailureKind.unavailable,
          failedMore: more,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _repository.cancelPending();
    return super.close();
  }
}
