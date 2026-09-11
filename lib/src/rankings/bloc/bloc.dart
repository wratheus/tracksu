import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';

part 'event.dart';
part 'state.dart';

final class RankingsBloc extends Bloc<RankingsEvent, RankingsState> {
  factory RankingsBloc({
    required RankingsRepository repository,
    required PageCache cache,
  }) => RankingsBloc._(repository, cache);

  RankingsBloc._(this._repository, this._cache)
    : super(const RankingsInitialState()) {
    // Concurrent bucket: type changes supersede in-flight reads.
    // Paging/refresh are guarded while busy; stale completions never emit.
    on<RankingsEvent>(_onEvent, transformer: concurrent());
  }

  final RankingsRepository _repository;
  final PageCache _cache;
  int _generation = 0;

  Future<void> _onEvent(
    RankingsEvent event,
    Emitter<RankingsState> emit,
  ) async {
    RankingsLoadedState? previous;
    var type = state.type;
    var country = state.country;
    var variant = state.variant;
    var operation = RankingsOperation.refresh;
    var requestedPage = 1;
    switch (event) {
      case RankingsStarted():
        if (state is! RankingsInitialState) {
          return;
        }
      case RankingsTypeSelected(:final value):
        if (value == state.type) {
          return;
        }
        type = value;
        if (type.ruleset != ProfileRuleset.mania) variant = ManiaVariant.all;
      case RankingsCountrySelected(:final value):
        if (value?.value == country?.value) return;
        country = value;
      case RankingsVariantSelected(:final value):
        if (type.ruleset != ProfileRuleset.mania || value == variant) return;
        variant = value;
      case RankingsRefreshRequested():
        if (state is RankingsLoadingState) {
          return;
        }
        if (state case final RankingsLoadedState loaded) {
          if (loaded.operation != null) {
            return;
          }
          previous = loaded;
        }
      case RankingsMoreRequested():
        if (state case final RankingsLoadedState loaded
            when loaded.operation == null && loaded.nextPage != null) {
          // Do not append to stale content after a failed refresh.
          if (loaded.failedOperation == RankingsOperation.refresh) {
            return;
          }
          previous = loaded;
          requestedPage = loaded.nextPage!;
          operation = RankingsOperation.loadMore;
        } else {
          return;
        }
    }

    final int generation = ++_generation;
    final Object cacheKey = ('rankings', type, country?.value, variant);
    final int cacheRevision = _cache.revision;
    final RankingsPage? cached = _cache.read<RankingsPage>(cacheKey);
    if (previous == null && cached != null) {
      previous = RankingsLoadedState(
        type: type,
        country: country,
        variant: variant,
        items: cached.items,
        nextPage: cached.nextPage,
      );
    }
    emit(
      previous == null
          ? RankingsLoadingState(type: type, country: country, variant: variant)
          : RankingsLoadedState(
              type: type,
              country: country,
              variant: variant,
              items: previous.items,
              nextPage: previous.nextPage,
              operation: operation,
            ),
    );
    try {
      final RankingsPage page = await _repository.load(
        RankingsQuery(
          type: type,
          country: country,
          variant: variant,
          page: requestedPage,
        ),
      );
      if (generation != _generation || emit.isDone || isClosed) {
        return;
      }
      final Map<int, RankingEntry> unique = <int, RankingEntry>{
        if (operation == RankingsOperation.loadMore && previous != null)
          for (final RankingEntry entry in previous.items) entry.id: entry,
      };
      // Only successful first pages become the revalidation snapshot.
      if (operation == RankingsOperation.refresh) {
        _cache.write(cacheKey, page, revision: cacheRevision);
      }
      for (final RankingEntry entry in page.items) {
        // A live ranking can move between reads. Keep earlier page snapshots
        // in place rather than replacing them with a later page's position.
        unique.putIfAbsent(entry.id, () => entry);
      }
      if (operation == RankingsOperation.loadMore &&
          previous != null &&
          page.nextPage != null &&
          (page.nextPage! <= requestedPage ||
              unique.length == previous.items.length)) {
        throw const RankingsFailure(RankingsFailureKind.invalidResponse);
      }
      emit(
        RankingsLoadedState(
          type: type,
          country: country,
          variant: variant,
          items: unique.values.toList(growable: false),
          nextPage: page.nextPage,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _generation || emit.isDone || isClosed) {
        return;
      }
      final RankingsFailureKind kind = error is RankingsFailure
          ? error.kind
          : RankingsFailureKind.unavailable;
      addError(RankingsFailure(kind), stackTrace);
      emit(
        previous == null
            ? RankingsFailureState(
                type: type,
                country: country,
                variant: variant,
                failure: kind,
              )
            : RankingsLoadedState(
                type: type,
                country: country,
                variant: variant,
                items: previous.items,
                nextPage: previous.nextPage,
                failure: kind,
                failedOperation: operation,
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
