import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/forum/data/forum_repository.dart';
import 'package:tracksu/src/forum/domain/forum.dart';

part 'event.dart';
part 'state.dart';

/// Forum sections for the osu! tab; cached for the session.
final class ForumIndexBloc extends Bloc<ForumIndexEvent, ForumIndexState> {
  ForumIndexBloc({required this._repository, required this._cache})
    : super(const ForumIndexState()) {
    on<ForumIndexEvent>(_onLoad, transformer: droppable());
  }

  final ForumRepository _repository;
  final PageCache _cache;
  static const Object _cacheKey = 'forum-index';

  Future<void> _onLoad(
    ForumIndexEvent event,
    Emitter<ForumIndexState> emit,
  ) async {
    List<ForumNode>? forums = state.forums;
    if (event is ForumIndexStarted) {
      if (forums != null) return;
      forums = _cache.read<List<ForumNode>>(_cacheKey);
      if (forums != null) {
        emit(ForumIndexState(forums: forums));
        return;
      }
    }
    final int revision = _cache.revision;
    emit(ForumIndexState(forums: forums, loading: true));
    try {
      final List<ForumNode> loaded = await _repository.forums();
      if (isClosed) return;
      _cache.write(_cacheKey, loaded, revision: revision);
      emit(ForumIndexState(forums: loaded));
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        ForumIndexState(
          forums: forums,
          failure: error is ForumFailure
              ? error.kind
              : ForumFailureKind.unavailable,
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
