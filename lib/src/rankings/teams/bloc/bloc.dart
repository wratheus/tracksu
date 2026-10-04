import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/teams/domain/team_ranking.dart';

sealed class TeamRankingsEvent {
  const TeamRankingsEvent();
}

/// Also the start event: the ruleset comes from the shared rankings filters.
/// Teams have no sort choice: the API orders them by PP only.
final class TeamRankingsQueryChanged extends TeamRankingsEvent {
  const TeamRankingsQueryChanged({required this.ruleset});
  final ProfileRuleset ruleset;
}

final class TeamRankingsRefreshRequested extends TeamRankingsEvent {
  const TeamRankingsRefreshRequested();
}

final class TeamRankingsMoreRequested extends TeamRankingsEvent {
  const TeamRankingsMoreRequested();
}

enum TeamRankingsOperation { refresh, loadMore }

/// [items] is null until the first page of the current query arrives.
@immutable
final class TeamRankingsState {
  TeamRankingsState({
    required this.ruleset,
    List<TeamRankingEntry>? items,
    this.nextPage,
    this.operation,
    this.failure,
    this.failedOperation,
    this.started = false,
  }) : items = items == null ? null : List.unmodifiable(items);

  final ProfileRuleset ruleset;
  final List<TeamRankingEntry>? items;
  final int? nextPage;
  final TeamRankingsOperation? operation;
  final RankingsFailureKind? failure;
  final TeamRankingsOperation? failedOperation;
  final bool started;

  bool get busy => operation != null;
}

/// Mirrors RankingsBloc: latest query wins, paging and refresh never append
/// stale pages, the first successful page is cached per query.
final class TeamRankingsBloc extends Bloc<TeamRankingsEvent, TeamRankingsState> {
  TeamRankingsBloc({
    required TeamRankingsRepository repository,
    required PageCache cache,
  }) : _repository = repository,
       _cache = cache,
       super(
         TeamRankingsState(ruleset: ProfileRuleset.osu),
       ) {
    on<TeamRankingsEvent>(_onEvent, transformer: concurrent());
  }

  final TeamRankingsRepository _repository;
  final PageCache _cache;
  int _generation = 0;

  Future<void> _onEvent(
    TeamRankingsEvent event,
    Emitter<TeamRankingsState> emit,
  ) async {
    ProfileRuleset ruleset = state.ruleset;
    List<TeamRankingEntry>? previous = state.items;
    int? previousNext = state.nextPage;
    TeamRankingsOperation operation = TeamRankingsOperation.refresh;
    int page = 1;
    switch (event) {
      case TeamRankingsQueryChanged():
        if (state.started && event.ruleset == ruleset) return;
        ruleset = event.ruleset;
        previous = null;
        previousNext = null;
      case TeamRankingsRefreshRequested():
        if (!state.started || state.busy) return;
      case TeamRankingsMoreRequested():
        if (state.busy ||
            state.items == null ||
            state.nextPage == null ||
            state.failedOperation == TeamRankingsOperation.refresh) {
          return;
        }
        page = state.nextPage!;
        operation = TeamRankingsOperation.loadMore;
    }
    final int generation = ++_generation;
    final Object key = ('team-rankings', ruleset);
    final int revision = _cache.revision;
    if (previous == null) {
      final TeamRankingsPage? cached = _cache.read<TeamRankingsPage>(key);
      previous = cached?.items;
      previousNext = cached?.nextPage;
    }
    emit(
      TeamRankingsState(
        ruleset: ruleset,
        items: previous,
        nextPage: previousNext,
        operation: operation,
        started: true,
      ),
    );
    try {
      final TeamRankingsPage result = await _repository.load(
        TeamRankingsQuery(
          ruleset: ruleset,
          page: page,
        ),
      );
      if (generation != _generation || emit.isDone || isClosed) return;
      if (operation == TeamRankingsOperation.refresh) {
        _cache.write(key, result, revision: revision);
      }
      final Map<int, TeamRankingEntry> unique = <int, TeamRankingEntry>{
        if (operation == TeamRankingsOperation.loadMore)
          for (final TeamRankingEntry e in previous ?? const <TeamRankingEntry>[])
            e.team.id: e,
      };
      final int before = unique.length;
      for (final TeamRankingEntry e in result.items) {
        unique.putIfAbsent(e.team.id, () => e);
      }
      if (operation == TeamRankingsOperation.loadMore &&
          result.nextPage != null &&
          unique.length == before) {
        throw const RankingsFailure(RankingsFailureKind.invalidResponse);
      }
      emit(
        TeamRankingsState(
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
        TeamRankingsState(
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
