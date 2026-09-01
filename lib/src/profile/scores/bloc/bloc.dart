import 'package:bloc/bloc.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/scores/domain/score.dart';
import 'package:tracksu/src/profile/scores/domain/scores_query.dart';
import 'package:tracksu/src/profile/scores/domain/scores_repository.dart';

part 'event.dart';
part 'state.dart';

final class ProfileScoresBloc
    extends Bloc<ProfileScoresEvent, ProfileScoresState> {
  factory ProfileScoresBloc({
    required ProfileScoresRepository repository,
    required ProfileUserId user,
    required ProfileRuleset ruleset,
  }) => ProfileScoresBloc._(repository, user, ruleset);

  ProfileScoresBloc._(this._repository, this._user, this._ruleset)
    : super(const ProfileScoresInitialState()) {
    // Concurrent bucket: type changes supersede in-flight reads.
    // Paging/refresh are guarded while busy; stale completions never emit.
    on<ProfileScoresEvent>(_onEvent);
  }

  final ProfileScoresRepository _repository;
  final ProfileUserId _user;
  final ProfileRuleset _ruleset;
  int _generation = 0;

  Future<void> _onEvent(
    ProfileScoresEvent event,
    Emitter<ProfileScoresState> emit,
  ) async {
    ProfileScoresLoadedState? previous;
    var type = state.type;
    var operation = ProfileScoresOperation.refresh;
    var offset = 0;
    switch (event) {
      case ProfileScoresStarted():
        if (state is! ProfileScoresInitialState) {
          return;
        }
      case ProfileScoresTypeSelected(:final value):
        if (value == state.type) {
          return;
        }
        type = value;
      case ProfileScoresRefreshRequested():
        if (state is ProfileScoresLoadingState) {
          return;
        }
        if (state case final ProfileScoresLoadedState loaded) {
          if (loaded.operation != null) {
            return;
          }
          previous = loaded;
        }
      case ProfileScoresMoreRequested():
        if (state case final ProfileScoresLoadedState loaded
            when loaded.operation == null && loaded.nextOffset != null) {
          // Do not append to stale content after a failed refresh.
          if (loaded.failedOperation == ProfileScoresOperation.refresh) {
            return;
          }
          previous = loaded;
          offset = loaded.nextOffset!;
          operation = ProfileScoresOperation.loadMore;
        } else {
          return;
        }
    }

    final int generation = ++_generation;
    emit(
      previous == null
          ? ProfileScoresLoadingState(type: type)
          : ProfileScoresLoadedState(
              type: type,
              items: previous.items,
              nextOffset: previous.nextOffset,
              operation: operation,
            ),
    );
    try {
      final ProfileScoresPage page = await _repository.load(
        ProfileScoresQuery(
          user: _user,
          ruleset: _ruleset,
          type: type,
          offset: offset,
        ),
      );
      if (generation != _generation || emit.isDone || isClosed) {
        return;
      }
      final Map<int, ProfileScore> unique = <int, ProfileScore>{
        if (operation == ProfileScoresOperation.loadMore && previous != null)
          for (final ProfileScore score in previous.items) score.id: score,
        for (final ProfileScore score in page.items) score.id: score,
      };
      emit(
        ProfileScoresLoadedState(
          type: type,
          items: unique.values.toList(growable: false),
          nextOffset: page.nextOffset,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _generation || emit.isDone || isClosed) {
        return;
      }
      final ProfileScoresFailureKind kind = error is ProfileScoresFailure
          ? error.kind
          : ProfileScoresFailureKind.unavailable;
      addError(ProfileScoresFailure(kind), stackTrace);
      emit(
        previous == null
            ? ProfileScoresFailureState(type: type, failure: kind)
            : ProfileScoresLoadedState(
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
