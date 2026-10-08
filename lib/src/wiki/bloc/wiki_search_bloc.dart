import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/wiki/data/wiki_repository.dart';
import 'package:tracksu/src/wiki/domain/wiki.dart';

sealed class WikiSearchEvent {
  const WikiSearchEvent();
}

/// The screen debounces typing; the newest query always wins.
final class WikiSearchChanged extends WikiSearchEvent {
  const WikiSearchChanged(this.query);
  final String query;
}

final class WikiSearchMoreRequested extends WikiSearchEvent {
  const WikiSearchMoreRequested();
}

final class WikiSearchState {
  const WikiSearchState({
    this.query = '',
    this.items = const <WikiSearchHit>[],
    this.total = 0,
    this.page = 0,
    this.busy = false,
    this.failure,
  });
  final String query;
  final List<WikiSearchHit> items;
  final int total;
  final int page;
  final bool busy;
  final WikiFailureKind? failure;

  bool get started => page > 0 || busy;
  bool get hasMore => items.length < total && page > 0;
}

final class WikiSearchBloc extends Bloc<WikiSearchEvent, WikiSearchState> {
  WikiSearchBloc({required this._repository, required this._locale})
    : super(const WikiSearchState()) {
    on<WikiSearchChanged>(_changed, transformer: restartable());
    on<WikiSearchMoreRequested>(_more, transformer: droppable());
  }

  final WikiRepository _repository;
  final String Function() _locale;

  Future<void> _changed(
    WikiSearchChanged event,
    Emitter<WikiSearchState> emit,
  ) async {
    final String query = event.query.trim();
    // Same query again is a no-op unless it failed (Retry resends it).
    if (query == state.query && state.page > 0 && state.failure == null) {
      return;
    }
    if (query.length < 2) {
      emit(WikiSearchState(query: query));
      return;
    }
    emit(WikiSearchState(query: query, busy: true));
    try {
      final WikiSearchPage page = await _repository.search(
        query,
        locale: _locale(),
      );
      emit(
        WikiSearchState(
          query: query,
          items: page.items,
          total: page.total,
          page: 1,
        ),
      );
    } on Object catch (error) {
      if (error is WikiFailure && error.kind == WikiFailureKind.cancelled) {
        return;
      }
      emit(
        WikiSearchState(
          query: query,
          failure: error is WikiFailure
              ? error.kind
              : WikiFailureKind.unavailable,
        ),
      );
    }
  }

  Future<void> _more(
    WikiSearchMoreRequested event,
    Emitter<WikiSearchState> emit,
  ) async {
    final WikiSearchState current = state;
    if (current.busy || !current.hasMore) return;
    emit(
      WikiSearchState(
        query: current.query,
        items: current.items,
        total: current.total,
        page: current.page,
        busy: true,
      ),
    );
    try {
      final WikiSearchPage page = await _repository.search(
        current.query,
        locale: _locale(),
        page: current.page + 1,
      );
      if (state.query != current.query) return;
      emit(
        WikiSearchState(
          query: current.query,
          items: <WikiSearchHit>[...current.items, ...page.items],
          total: page.items.isEmpty ? current.items.length : page.total,
          page: page.page,
        ),
      );
    } on Object catch (error) {
      if (state.query != current.query) return;
      emit(
        WikiSearchState(
          query: current.query,
          items: current.items,
          total: current.total,
          page: current.page,
          failure: error is WikiFailure
              ? error.kind
              : WikiFailureKind.unavailable,
        ),
      );
    }
  }
}
