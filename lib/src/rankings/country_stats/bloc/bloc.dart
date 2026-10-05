import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/country_stats/domain/country_ranking.dart';

sealed class CountryRankingsEvent {
  const CountryRankingsEvent();
}

/// Also the start event: the ruleset comes from the shared rankings filters.
final class CountryRankingsRulesetChanged extends CountryRankingsEvent {
  const CountryRankingsRulesetChanged(this.ruleset);
  final ProfileRuleset ruleset;
}

final class CountryRankingsRefreshRequested extends CountryRankingsEvent {
  const CountryRankingsRefreshRequested();
}

final class CountryRankingsMoreRequested extends CountryRankingsEvent {
  const CountryRankingsMoreRequested();
}

enum CountryRankingsOperation { refresh, loadMore }

/// [items] is null until the first page of the current query arrives.
@immutable
final class CountryRankingsState {
  CountryRankingsState({
    required this.ruleset,
    List<CountryRankingEntry>? items,
    this.nextPage,
    this.operation,
    this.failure,
    this.failedOperation,
    this.started = false,
  }) : items = items == null ? null : List.unmodifiable(items);

  final ProfileRuleset ruleset;
  final List<CountryRankingEntry>? items;
  final int? nextPage;
  final CountryRankingsOperation? operation;
  final RankingsFailureKind? failure;
  final CountryRankingsOperation? failedOperation;
  final bool started;

  bool get busy => operation != null;
}

/// Mirrors RankingsBloc: latest query wins, paging and refresh never append
/// stale pages, the first successful page is cached per query.
final class CountryRankingsBloc extends Bloc<CountryRankingsEvent, CountryRankingsState> {
  CountryRankingsBloc({
    required CountryRankingsRepository repository,
    required PageCache cache,
  }) : _repository = repository,
       _cache = cache,
       super(
         CountryRankingsState(ruleset: ProfileRuleset.osu),
       ) {
    on<CountryRankingsEvent>(_onEvent, transformer: concurrent());
  }

  final CountryRankingsRepository _repository;
  final PageCache _cache;
  int _generation = 0;

  Future<void> _onEvent(
    CountryRankingsEvent event,
    Emitter<CountryRankingsState> emit,
  ) async {
    ProfileRuleset ruleset = state.ruleset;
    List<CountryRankingEntry>? previous = state.items;
    int? previousNext = state.nextPage;
    CountryRankingsOperation operation = CountryRankingsOperation.refresh;
    int page = 1;
    switch (event) {
      case CountryRankingsRulesetChanged():
        if (state.started && event.ruleset == ruleset) return;
        ruleset = event.ruleset;
        previous = null;
        previousNext = null;
      case CountryRankingsRefreshRequested():
        if (!state.started || state.busy) return;
      case CountryRankingsMoreRequested():
        if (state.busy ||
            state.items == null ||
            state.nextPage == null ||
            state.failedOperation == CountryRankingsOperation.refresh) {
          return;
        }
        page = state.nextPage!;
        operation = CountryRankingsOperation.loadMore;
    }
    final int generation = ++_generation;
    final Object key = ('country-rankings', ruleset);
    final int revision = _cache.revision;
    if (previous == null) {
      final CountryRankingsPage? cached = _cache.read<CountryRankingsPage>(key);
      previous = cached?.items;
      previousNext = cached?.nextPage;
    }
    emit(
      CountryRankingsState(
        ruleset: ruleset,
        items: previous,
        nextPage: previousNext,
        operation: operation,
        started: true,
      ),
    );
    try {
      final CountryRankingsPage result = await _repository.load(
        CountryRankingsQuery(
          ruleset: ruleset,
          page: page,
        ),
      );
      if (generation != _generation || emit.isDone || isClosed) return;
      if (operation == CountryRankingsOperation.refresh) {
        _cache.write(key, result, revision: revision);
      }
      final Map<String, CountryRankingEntry> unique = <String, CountryRankingEntry>{
        if (operation == CountryRankingsOperation.loadMore)
          for (final CountryRankingEntry e in previous ?? const <CountryRankingEntry>[])
            e.country.value: e,
      };
      final int before = unique.length;
      for (final CountryRankingEntry e in result.items) {
        unique.putIfAbsent(e.country.value, () => e);
      }
      if (operation == CountryRankingsOperation.loadMore &&
          result.nextPage != null &&
          unique.length == before) {
        throw const RankingsFailure(RankingsFailureKind.invalidResponse);
      }
      emit(
        CountryRankingsState(
          ruleset: ruleset,
            items: unique.values.toList(growable: false),
          nextPage: result.nextPage,
          started: true,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _generation || emit.isDone || isClosed) return;
      final RankingsFailureKind kind = error is RankingsFailure
          ? error.kind
          : RankingsFailureKind.unavailable;
      addError(RankingsFailure(kind), stackTrace);
      emit(
        CountryRankingsState(
          ruleset: ruleset,
            items: previous,
          nextPage: previousNext,
          failure: kind,
          failedOperation: operation,
          started: true,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _generation++;
    _repository.cancelPending();
    return super.close();
  }
}
