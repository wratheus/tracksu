import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_repository.dart';

part 'event.dart';
part 'state.dart';

final class ProfileBeatmapsBloc
    extends Bloc<ProfileBeatmapsEvent, ProfileBeatmapsState> {
  factory ProfileBeatmapsBloc({
    required ProfileBeatmapsRepository repository,
    required PageCache cache,
    required ProfileUserId user,
  }) => ProfileBeatmapsBloc._(repository, cache, user);

  ProfileBeatmapsBloc._(this._repository, this._cache, this._user)
    : super(const ProfileBeatmapsInitialState()) {
    // Concurrent bucket: type changes supersede in-flight reads.
    // Paging/refresh are guarded while busy; stale completions never emit.
    on<ProfileBeatmapsEvent>(_onEvent, transformer: concurrent());
  }

  final ProfileBeatmapsRepository _repository;
  final PageCache _cache;
  final ProfileUserId _user;
  int _generation = 0;

  Future<void> _onEvent(
    ProfileBeatmapsEvent event,
    Emitter<ProfileBeatmapsState> emit,
  ) async {
    ProfileBeatmapsLoadedState? previous;
    var type = state.type;
    var operation = ProfileBeatmapsOperation.refresh;
    var offset = 0;
    switch (event) {
      case ProfileBeatmapsStarted():
        if (state is! ProfileBeatmapsInitialState) {
          return;
        }
      case ProfileBeatmapsTypeSelected(:final value):
        if (value == state.type) {
          return;
        }
        type = value;
      case ProfileBeatmapsRefreshRequested():
        if (state is ProfileBeatmapsLoadingState) {
          return;
        }
        if (state case final ProfileBeatmapsLoadedState loaded) {
          if (loaded.operation != null) {
            return;
          }
          previous = loaded;
        }
      case ProfileBeatmapsMoreRequested():
        if (state case final ProfileBeatmapsLoadedState loaded
            when loaded.operation == null && loaded.nextOffset != null) {
          // Do not append to stale content after a failed refresh.
          if (loaded.failedOperation == ProfileBeatmapsOperation.refresh) {
            return;
          }
          previous = loaded;
          offset = loaded.nextOffset!;
          operation = ProfileBeatmapsOperation.loadMore;
        } else {
          return;
        }
    }

    final int generation = ++_generation;
    final Object cacheKey = ('profile-beatmaps', _user.apiValue, type);
    final int cacheRevision = _cache.revision;
    if (previous == null) {
      final ProfileBeatmapsPage? cached = _cache.read<ProfileBeatmapsPage>(
        cacheKey,
      );
      if (cached != null) {
        previous = ProfileBeatmapsLoadedState(
          type: type,
          items: cached.items,
          nextOffset: cached.nextOffset,
        );
      }
    }
    emit(
      previous == null
          ? ProfileBeatmapsLoadingState(type: type)
          : ProfileBeatmapsLoadedState(
              type: type,
              items: previous.items,
              nextOffset: previous.nextOffset,
              operation: operation,
            ),
    );
    try {
      final ProfileBeatmapsPage page = await _repository.load(
        ProfileBeatmapsQuery(user: _user, type: type, offset: offset),
      );
      if (generation != _generation || emit.isDone || isClosed) {
        return;
      }
      if (operation == ProfileBeatmapsOperation.refresh) {
        _cache.write(cacheKey, page, revision: cacheRevision);
      }
      final Map<int, ProfileBeatmap> unique = <int, ProfileBeatmap>{
        if (operation == ProfileBeatmapsOperation.loadMore && previous != null)
          for (final ProfileBeatmap beatmap in previous.items)
            beatmap.id: beatmap,
        for (final ProfileBeatmap beatmap in page.items) beatmap.id: beatmap,
      };
      if (operation == ProfileBeatmapsOperation.loadMore &&
          previous != null &&
          page.nextOffset != null &&
          (page.nextOffset! <= offset ||
              unique.length == previous.items.length)) {
        throw const ProfileBeatmapsFailure(
          ProfileBeatmapsFailureKind.invalidResponse,
        );
      }
      emit(
        ProfileBeatmapsLoadedState(
          type: type,
          items: unique.values.toList(growable: false),
          nextOffset: page.nextOffset,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _generation || emit.isDone || isClosed) {
        return;
      }
      final ProfileBeatmapsFailureKind kind = error is ProfileBeatmapsFailure
          ? error.kind
          : ProfileBeatmapsFailureKind.unavailable;
      addError(ProfileBeatmapsFailure(kind), stackTrace);
      emit(
        previous == null
            ? ProfileBeatmapsFailureState(type: type, failure: kind)
            : ProfileBeatmapsLoadedState(
                type: type,
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
