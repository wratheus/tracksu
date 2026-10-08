import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/packs/data/packs_repository.dart';
import 'package:tracksu/src/packs/domain/packs.dart';

part 'event.dart';
part 'state.dart';

/// One pack with its beatmapsets; cached for the session.
final class BeatmapPackBloc extends Bloc<BeatmapPackEvent, BeatmapPackState> {
  BeatmapPackBloc({
    required this.tag,
    required this._repository,
    required this._cache,
  }) : super(const BeatmapPackState()) {
    on<BeatmapPackEvent>(_onEvent, transformer: droppable());
  }

  final String tag;
  final BeatmapPacksRepository _repository;
  final PageCache _cache;

  Object get _key => ('beatmap-pack', tag);

  Future<void> _onEvent(
    BeatmapPackEvent event,
    Emitter<BeatmapPackState> emit,
  ) async {
    if (event is BeatmapPackStarted) {
      if (state.pack != null) return;
      if (_cache.read<BeatmapPack>(_key) case final cached?) {
        emit(BeatmapPackState(pack: cached));
        return;
      }
    }
    final int revision = _cache.revision;
    emit(BeatmapPackState(pack: state.pack, loading: true));
    try {
      final BeatmapPack pack = await _repository.pack(tag);
      if (isClosed) return;
      _cache.write(_key, pack, revision: revision);
      emit(BeatmapPackState(pack: pack));
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        BeatmapPackState(
          pack: state.pack,
          failure: error is BeatmapPacksFailure
              ? error.kind
              : BeatmapPacksFailureKind.unavailable,
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
