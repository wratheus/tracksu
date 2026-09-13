import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/team/domain/team.dart';

part 'event.dart';
part 'state.dart';

final class TeamBloc extends Bloc<TeamEvent, TeamState> {
  factory TeamBloc({
    required TeamRepository repository,
    required PageCache cache,
    required TeamParams params,
  }) => TeamBloc._(repository, cache, params);
  TeamBloc._(this._repository, this._cache, this._params)
    : super(const TeamInitial()) {
    on<TeamEvent>(_onEvent, transformer: concurrent());
  }
  final TeamRepository _repository;
  final PageCache _cache;
  final TeamParams _params;
  ProfileRuleset? _mode;
  int _generation = 0;

  Future<void> _onEvent(TeamEvent event, Emitter<TeamState> emit) async {
    TeamDetails? previous;
    switch (event) {
      case TeamStarted():
        if (state is! TeamInitial) return;
        _mode = _params.ruleset;
      case TeamRefreshRequested():
        if (state is TeamLoading) return;
        if (state case TeamLoaded(:final data, :final refreshing)) {
          if (refreshing) return;
          previous = data;
        }
      case TeamModeSelected(:final mode):
        if (_mode == mode) return;
        if (state case TeamLoaded(:final data)) previous = data;
        _mode = mode;
    }
    final int generation = ++_generation;
    final ProfileRuleset? mode = _mode;
    final Object key = ('team', _params.id, mode);
    final int revision = _cache.revision;
    previous = _cache.read<TeamDetails>(key) ?? previous;
    emit(
      previous == null
          ? TeamLoading(mode)
          : TeamLoaded(previous, refreshing: true, requestedMode: mode),
    );
    try {
      final TeamDetails result = await _repository.load(
        TeamParams(_params.id, ruleset: mode),
      );
      if (isClosed || emit.isDone || generation != _generation) return;
      _mode = result.ruleset;
      _cache.write(key, result, revision: revision);
      _cache.write(
        ('team', _params.id, result.ruleset),
        result,
        revision: revision,
      );
      emit(TeamLoaded(result));
    } on Object catch (error, stack) {
      if (isClosed || emit.isDone || generation != _generation) return;
      addError(error, stack);
      final TeamFailureKind kind = error is TeamFailure
          ? error.kind
          : TeamFailureKind.unavailable;
      emit(
        previous == null
            ? TeamError(kind, mode)
            : TeamLoaded(previous, failure: kind, requestedMode: mode),
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
