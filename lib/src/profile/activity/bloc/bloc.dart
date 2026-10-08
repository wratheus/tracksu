import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/activity/domain/activity.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

part 'event.dart';
part 'state.dart';

/// Recent activity of one player: first page (memory-cached for the session),
/// refresh that keeps visible rows on failure, and offset paging.
final class ProfileActivityBloc
    extends Bloc<ProfileActivityEvent, ProfileActivityState> {
  ProfileActivityBloc({
    required this._repository,
    required this._cache,
    required this._user,
  }) : super(const ProfileActivityInitialState()) {
    // Refresh/paging are ignored while busy; stale completions never emit.
    on<ProfileActivityEvent>(_onEvent, transformer: sequential());
  }

  final ProfileActivityRepository _repository;
  final PageCache _cache;
  final ProfileUserId _user;
  int _generation = 0;

  Future<void> _onEvent(
    ProfileActivityEvent event,
    Emitter<ProfileActivityState> emit,
  ) async {
    ProfileActivityLoadedState? previous;
    ProfileActivityOperation operation = ProfileActivityOperation.refresh;
    int offset = 0;
    switch (event) {
      case ProfileActivityStarted():
        if (state is! ProfileActivityInitialState) return;
      case ProfileActivityRefreshRequested():
        if (state is ProfileActivityLoadingState) return;
        if (state case final ProfileActivityLoadedState loaded) {
          if (loaded.operation != null) return;
          previous = loaded;
        }
      case ProfileActivityMoreRequested():
        if (state case final ProfileActivityLoadedState loaded
            when loaded.operation == null &&
                loaded.nextOffset != null &&
                loaded.failedOperation != ProfileActivityOperation.refresh) {
          previous = loaded;
          offset = loaded.nextOffset!;
          operation = ProfileActivityOperation.loadMore;
        } else {
          return;
        }
    }

    final int generation = ++_generation;
    final Object cacheKey = ('profile-activity', _user.apiValue);
    final int cacheRevision = _cache.revision;
    if (previous == null) {
      if (_cache.read<ProfileActivityPage>(cacheKey) case final cached?) {
        previous = ProfileActivityLoadedState(
          items: cached.items,
          nextOffset: cached.nextOffset,
        );
      }
    }
    emit(
      previous == null
          ? const ProfileActivityLoadingState()
          : ProfileActivityLoadedState(
              items: previous.items,
              nextOffset: previous.nextOffset,
              operation: operation,
            ),
    );
    try {
      final ProfileActivityPage page = await _repository.load(
        ProfileActivityQuery(user: _user, offset: offset),
      );
      if (generation != _generation || emit.isDone || isClosed) return;
      if (operation == ProfileActivityOperation.refresh) {
        _cache.write(cacheKey, page, revision: cacheRevision);
      }
      final Map<int, OsuEvent> unique = <int, OsuEvent>{
        if (operation == ProfileActivityOperation.loadMore && previous != null)
          for (final OsuEvent item in previous.items) item.id: item,
        for (final OsuEvent item in page.items) item.id: item,
      };
      emit(
        ProfileActivityLoadedState(
          items: unique.values.toList(growable: false),
          nextOffset: page.nextOffset,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _generation || emit.isDone || isClosed) return;
      final ProfileActivityFailureKind kind = error is ProfileActivityFailure
          ? error.kind
          : ProfileActivityFailureKind.unavailable;
      addError(ProfileActivityFailure(kind), stackTrace);
      emit(
        previous == null
            ? ProfileActivityFailureState(kind)
            : ProfileActivityLoadedState(
                items: previous.items,
                nextOffset: previous.nextOffset,
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
