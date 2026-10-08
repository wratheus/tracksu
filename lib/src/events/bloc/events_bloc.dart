import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/events/data/events_repository.dart';

sealed class OsuEventsEvent {
  const OsuEventsEvent();
}

final class OsuEventsStarted extends OsuEventsEvent {
  const OsuEventsStarted();
}

final class OsuEventsRefreshRequested extends OsuEventsEvent {
  const OsuEventsRefreshRequested();
}

final class OsuEventsMoreRequested extends OsuEventsEvent {
  const OsuEventsMoreRequested();
}

enum OsuEventsOperation { refresh, loadMore }

/// [items] null until the first page arrives; a failed refresh or page keeps
/// the visible rows and records [failure] with its [failedOperation].
final class OsuEventsState {
  const OsuEventsState({
    this.items,
    this.cursor,
    this.operation,
    this.failure,
    this.failedOperation,
  });
  final List<OsuEvent>? items;
  final String? cursor;
  final OsuEventsOperation? operation;
  final OsuEventsFailureKind? failure;
  final OsuEventsOperation? failedOperation;

  bool get busy => operation != null;
}

/// Global osu! feed: first page cached for the session, cursor paging.
final class OsuEventsBloc extends Bloc<OsuEventsEvent, OsuEventsState> {
  OsuEventsBloc({
    required OsuEventsRepository repository,
    required PageCache cache,
  }) : _repository = repository,
       _cache = cache,
       super(const OsuEventsState()) {
    on<OsuEventsEvent>(_onEvent, transformer: sequential());
  }

  final OsuEventsRepository _repository;
  final PageCache _cache;
  static const Object _cacheKey = 'osu-events';

  Future<void> _onEvent(
    OsuEventsEvent event,
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
    if (items == null) {
      if (_cache.read<OsuEventsPage>(_cacheKey) case final cached?) {
        items = cached.items;
        cursor = cached.cursor;
      }
    }
    emit(OsuEventsState(items: items, cursor: cursor, operation: operation));
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
