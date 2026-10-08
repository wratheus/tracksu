import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/search/domain/user_search.dart';

sealed class UserSearchEvent {
  const UserSearchEvent();
}

final class UserSearchChanged extends UserSearchEvent {
  const UserSearchChanged(this.query);
  final String query;
}

final class UserSearchPaused extends UserSearchEvent {
  const UserSearchPaused({this.query});
  final String? query;
}

final class UserSearchMore extends UserSearchEvent {
  const UserSearchMore();
}

final class UserSearchRetry extends UserSearchEvent {
  const UserSearchRetry();
}

final class UserSearchState {
  UserSearchState({
    this.query = '',
    List<SearchPlayer> items = const [],
    this.started = false,
    this.busy = false,
    this.nextPage,
    this.failure,
  }) : items = List.unmodifiable(items);
  final String query;
  final List<SearchPlayer> items;
  final bool started;
  final bool busy;
  final int? nextPage;
  final UserSearchFailureKind? failure;
}

final class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  UserSearchBloc({required this._repository}) : super(UserSearchState()) {
    on<UserSearchEvent>(_onEvent, transformer: concurrent());
  }
  final UserSearchRepository _repository;
  final Map<String, (DateTime, UserSearchState)> _cache = {};
  int _generation = 0;

  Future<SearchPlayer> resolve(SearchPlayer player) async {
    if (player.ruleset != null) return player;
    try {
      return await _repository.lookup(player.id.toString());
    } on Object catch (error, stack) {
      if (!isClosed) {
        addError(
          UserSearchFailure(
            error is UserSearchFailure
                ? error.kind
                : UserSearchFailureKind.unavailable,
          ),
          stack,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _generation++;
    _repository.cancelPending();
    return super.close();
  }

  Future<void> _onEvent(
    UserSearchEvent event,
    Emitter<UserSearchState> emit,
  ) async {
    String query = state.query;
    int page = 1;
    switch (event) {
      case UserSearchPaused():
        _generation++;
        _repository.cancelPending();
        emit(UserSearchState(query: event.query ?? query));
        return;
      case UserSearchChanged():
        query = event.query.trim();
        if (state.started && query == state.query) return;
        final cached = _cache[query];
        if (cached != null &&
            DateTime.now().difference(cached.$1) < const Duration(minutes: 2)) {
          _generation++;
          _repository.cancelPending();
          emit(cached.$2);
          return;
        }
      case UserSearchMore():
        if (state.busy || state.nextPage == null || state.failure != null) {
          return;
        }
        page = state.nextPage!;
      case UserSearchRetry():
        if (state.busy) return;
        page = state.nextPage ?? 1;
    }
    final int generation = ++_generation;
    if (page == 1) _repository.cancelPending();
    if (query.length < 2 && !RegExp(r'^[1-9]$').hasMatch(query)) {
      emit(UserSearchState(query: query));
      return;
    }
    final List<SearchPlayer> previous = page > 1 ? state.items : [];
    emit(
      UserSearchState(query: query, items: previous, started: true, busy: true),
    );
    try {
      final UserSearchPage result = await _repository.search(query, page: page);
      if (generation != _generation || isClosed) return;
      final Map<int, SearchPlayer> unique = {for (final p in previous) p.id: p};
      for (final SearchPlayer player in result.items) {
        unique[player.id] = player;
      }
      final bool hasMore =
          result.items.isNotEmpty &&
          unique.length > previous.length &&
          page < 5 &&
          page * 20 < result.total;
      final UserSearchState loaded = UserSearchState(
        query: query,
        items: unique.values.toList(),
        started: true,
        nextPage: hasMore ? page + 1 : null,
      );
      _cache.remove(query);
      _cache[query] = (DateTime.now(), loaded);
      if (_cache.length > 10) _cache.remove(_cache.keys.first);
      emit(loaded);
    } on Object catch (error, stack) {
      if (generation != _generation || isClosed) return;
      final kind = error is UserSearchFailure
          ? error.kind
          : UserSearchFailureKind.unavailable;
      addError(UserSearchFailure(kind), stack);
      emit(
        UserSearchState(
          query: query,
          items: previous,
          started: true,
          nextPage: page > 1 ? page : null,
          failure: kind,
        ),
      );
    }
  }
}
