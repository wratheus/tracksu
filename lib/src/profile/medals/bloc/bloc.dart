import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/medals/domain/medal.dart';
import 'package:tracksu/src/profile/medals/domain/repository.dart';

part 'event.dart';
part 'state.dart';

final class MedalsBloc extends Bloc<MedalsEvent, MedalsState> {
  factory MedalsBloc({
    required MedalsRepository repository,
    required PageCache cache,
    required int userId,
  }) => MedalsBloc._(repository, cache, userId);

  MedalsBloc._(this._repository, this._cache, this._userId)
    : super(const MedalsLoading()) {
    on<MedalsEvent>(_onEvent, transformer: droppable());
  }
  final MedalsRepository _repository;
  final PageCache _cache;
  final int _userId;
  bool _busy = false;

  Future<void> _onEvent(MedalsEvent event, Emitter<MedalsState> emit) async {
    // One read at a time; repeated refresh taps never queue network work.
    if (_busy) return;
    switch (event) {
      case MedalsLoadRequested():
        break;
    }
    _busy = true;
    final Object cacheKey = ('medals', _userId);
    final int cacheRevision = _cache.revision;
    final List<EarnedMedal>? cached = _cache.read<List<EarnedMedal>>(cacheKey);
    final MedalsLoaded? previous = switch (state) {
      final MedalsLoaded value => value,
      _ => cached == null ? null : MedalsLoaded(cached),
    };
    emit(
      previous == null
          ? const MedalsLoading()
          : MedalsLoaded(previous.medals, refreshing: true),
    );
    try {
      final List<EarnedMedal> medals = await _repository.load(_userId);
      if (isClosed || emit.isDone) return;
      final MedalsLoaded loaded = MedalsLoaded(medals);
      _cache.write(cacheKey, loaded.medals, revision: cacheRevision);
      emit(loaded);
    } on Object catch (_, stackTrace) {
      if (isClosed || emit.isDone) return;
      // Never forward an upstream HTML body or decoded content to telemetry.
      addError(StateError('Medal collection unavailable.'), stackTrace);
      emit(
        previous == null
            ? const MedalsError()
            : MedalsLoaded(previous.medals, refreshFailed: true),
      );
    } finally {
      _busy = false;
    }
  }

  @override
  Future<void> close() {
    _repository.cancelPending();
    return super.close();
  }
}
