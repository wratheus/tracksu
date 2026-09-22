import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/spotlights/domain/spotlight.dart';

part 'event.dart';
part 'state.dart';

final class SpotlightsBloc extends Bloc<SpotlightsEvent, SpotlightsState> {
  factory SpotlightsBloc({
    required SpotlightsRepository repository,
    required PageCache cache,
  }) => SpotlightsBloc._(repository, cache);
  SpotlightsBloc._(this._repository, this._cache)
    : super(const SpotlightsInitialState()) {
    // Concurrent latest-wins selection; repeated refresh is ignored while busy.
    on<SpotlightsEvent>(_onEvent, transformer: concurrent());
  }
  final SpotlightsRepository _repository;
  final PageCache _cache;
  static const String _catalogKey = 'spotlights-catalog';
  int _generation = 0;

  Future<void> _onEvent(
    SpotlightsEvent event,
    Emitter<SpotlightsState> emit,
  ) async {
    List<Spotlight>? catalog;
    ProfileRuleset ruleset = ProfileRuleset.osu;
    int? id;
    SpotlightDetails? previous;
    final SpotlightsState current = state;
    if (current is SpotlightsLoadedState) {
      catalog = current.catalog;
      ruleset = current.ruleset;
      id = current.selectedId;
    }
    switch (event) {
      case SpotlightsStarted():
        if (current is! SpotlightsInitialState) return;
      case SpotlightSelected(:final id):
        if (current is! SpotlightsLoadedState ||
            id == current.selectedId ||
            !current.catalog.any((Spotlight item) => item.id == id)) {
          return;
        }
      case SpotlightRulesetSelected(:final ruleset):
        if (current is! SpotlightsLoadedState ||
            current.selectedId == null ||
            ruleset == current.ruleset) {
          return;
        }
      case SpotlightsRefreshRequested():
        if (current is SpotlightsLoadingState ||
            (current is SpotlightsLoadedState && current.loading)) {
          return;
        }
        if (current is SpotlightsLoadedState) {
          previous = current.details;
          // An empty catalog can be retried; a selected chart refreshes only itself.
          if (current.catalog.isEmpty) catalog = null;
        }
    }
    if (event is SpotlightSelected) id = event.id;
    if (event is SpotlightRulesetSelected) ruleset = event.ruleset;
    final int generation = ++_generation;
    final int cacheRevision = _cache.revision;
    // Reopen revalidates the catalog; a selected chart refresh only reloads
    // its details. Empty catalogs still retry discovery of new charts.
    final bool refreshCatalog = catalog == null;
    if (catalog == null) {
      catalog = _cache.read<List<Spotlight>>(_catalogKey);
      id = catalog?.firstOrNull?.id;
    }
    Object detailsKey(int value) => ('spotlight-details', value, ruleset);
    previous ??= id == null
        ? null
        : _cache.read<SpotlightDetails>(detailsKey(id));
    bool stale() => generation != _generation || emit.isDone || isClosed;
    emit(
      catalog == null
          ? const SpotlightsLoadingState()
          : SpotlightsLoadedState(
              catalog: catalog,
              ruleset: ruleset,
              selectedId: id,
              details: previous,
              loading: refreshCatalog || id != null,
            ),
    );
    try {
      if (refreshCatalog) {
        final List<Spotlight> result = List<Spotlight>.unmodifiable(
          await _repository.catalog(),
        );
        if (stale()) return;
        _cache.write(_catalogKey, result, revision: cacheRevision);
        catalog = result;
        if (!catalog.any((Spotlight item) => item.id == id)) {
          id = catalog.firstOrNull?.id;
          previous = id == null
              ? null
              : _cache.read<SpotlightDetails>(detailsKey(id));
        }
      }
      emit(
        SpotlightsLoadedState(
          catalog: catalog!,
          ruleset: ruleset,
          selectedId: id,
          details: previous,
          loading: id != null,
        ),
      );
      if (id == null) return;
      final SpotlightDetails details = await _repository.load(
        SpotlightQuery(id: id, ruleset: ruleset),
      );
      if (stale()) return;
      _cache.write(detailsKey(id), details, revision: cacheRevision);
      emit(
        SpotlightsLoadedState(
          catalog: catalog,
          ruleset: ruleset,
          selectedId: id,
          details: details,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (stale()) return;
      final RankingsFailureKind failure = error is RankingsFailure
          ? error.kind
          : RankingsFailureKind.unavailable;
      addError(RankingsFailure(failure), stackTrace);
      emit(
        catalog == null
            ? SpotlightsFailureState(failure)
            : SpotlightsLoadedState(
                catalog: catalog,
                ruleset: ruleset,
                selectedId: id,
                details: previous,
                failure: failure,
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
