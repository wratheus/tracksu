import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/events/data/events_repository.dart';

part 'event.dart';
part 'state.dart';

/// Global osu! feed: first page cached for the session, cursor paging.
final class OsuEventsBloc extends Bloc<OsuEventsEvent, OsuEventsState> {
  OsuEventsBloc({required this._repository, required this._cache})
    : super(const OsuEventsState()) {
    on<OsuEventsLoadEvent>(_onLoad, transformer: sequential());
    // Switching the group never waits for a request in flight.
    on<OsuEventsFilterSelected>((
      OsuEventsFilterSelected event,
      Emitter<OsuEventsState> emit,
    ) {
      if (event.filter != state.filter) {
        emit(state.copyWith(filter: event.filter));
      }
    });
  }

  final OsuEventsRepository _repository;
  final PageCache _cache;
  static const Object _cacheKey = 'osu-events';
  static const Duration _minPageInterval = Duration(seconds: 1);
  DateTime _lastPage = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _onLoad(
    OsuEventsLoadEvent event,
    Emitter<OsuEventsState> emit,
  ) async {
    final OsuEventsOperation operation;
    switch (event) {
      case OsuEventsStarted():
        if (state.items != null || state.busy) return;
        operation = OsuEventsOperation.refresh;
      case OsuEventsRefreshRequested():
        if (state.busy) return;
        operation = OsuEventsOperation.refresh;
      case OsuEventsMoreRequested():
        if (state.busy ||
            state.cursor == null ||
            state.failedOperation == OsuEventsOperation.refresh) {
          return;
        }
        operation = OsuEventsOperation.loadMore;
    }
    final int revision = _cache.revision;
    List<OsuEvent>? items = state.items;
    String? cursor = state.cursor;
    if (operation == OsuEventsOperation.loadMore) {
      // Paging is user-driven, but never faster than one page per second.
      final Duration wait =
          _minPageInterval - DateTime.now().difference(_lastPage);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
      if (isClosed) return;
      _lastPage = DateTime.now();
    }
    if (items == null) {
      if (_cache.read<OsuEventsPage>(_cacheKey) case final cached?) {
        items = cached.items;
        cursor = cached.cursor;
      }
    }
    emit(
      OsuEventsState(
        filter: state.filter,
        items: items,
        cursor: cursor,
        operation: operation,
      ),
    );
    try {
      final OsuEventsPage page = await _repository.load(
        cursor: operation == OsuEventsOperation.loadMore ? cursor : null,
      );
      if (isClosed) return;
      if (operation == OsuEventsOperation.refresh) {
        _cache.write(_cacheKey, page, revision: revision);
      }
      final Map<int, OsuEvent> unique = <int, OsuEvent>{
        if (operation == OsuEventsOperation.loadMore)
          for (final OsuEvent item in items ?? const <OsuEvent>[])
            item.id: item,
        for (final OsuEvent item in page.items) item.id: item,
      };
      emit(
        OsuEventsState(
          filter: state.filter,
          items: unique.values.toList(growable: false),
          cursor: page.cursor,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      final OsuEventsFailureKind kind = error is OsuEventsFailure
          ? error.kind
          : OsuEventsFailureKind.unavailable;
      addError(OsuEventsFailure(kind), stackTrace);
      emit(
        OsuEventsState(
          filter: state.filter,
          items: items,
          cursor: cursor,
          failure: kind,
          failedOperation: operation,
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
