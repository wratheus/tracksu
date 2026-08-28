import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_failure.dart';
import 'package:tracksu/src/profile/domain/profile_repository.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

part 'event.dart';
part 'state.dart';

final class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  factory ProfileBloc({required ProfileRepository repository}) =>
      ProfileBloc._(repository);

  ProfileBloc._(this._repository) : super(const ProfileInitialState()) {
    // One concurrent event bucket, latest-wins across search AND ruleset.
    // A generation guard covers completions; the repository aborts old IO.
    on<ProfileEvent>(_onEvent);
  }

  final ProfileRepository _repository;
  ProfileUserReference? _user;
  bool _hasTarget = false;
  int _generation = 0;

  Future<void> _onEvent(ProfileEvent event, Emitter<ProfileState> emit) async {
    final ProfileRuleset ruleset;
    ProfileLoadedState? previous;
    switch (event) {
      case ProfileLookupRequested(:final user):
        if (_hasTarget &&
            _user?.apiValue == user.apiValue &&
            state is ProfileLoadingState) {
          return;
        }
        _user = user;
        _hasTarget = true;
        ruleset = state.ruleset;
      case CurrentProfileLoadRequested():
        _user = null;
        _hasTarget = true;
        ruleset = state.ruleset;
      case ProfileRulesetSelected(:final value):
        if (value == state.ruleset) {
          return;
        }
        ruleset = value;
        if (!_hasTarget) {
          emit(ProfileInitialState(ruleset: ruleset));
          return;
        }
      case ProfileRefreshRequested():
        if (!_hasTarget || state is ProfileLoadingState) {
          return;
        }
        if (state case final ProfileLoadedState loaded) {
          if (loaded.isRefreshing) {
            return;
          }
          previous = loaded;
        }
        ruleset = state.ruleset;
      case ProfileCleared():
        _generation++;
        _repository.cancelPending();
        _hasTarget = false;
        _user = null;
        emit(ProfileInitialState(ruleset: state.ruleset));
        return;
    }
    final int generation = ++_generation;
    final ProfileUserReference? user = _user;
    emit(
      previous == null
          ? ProfileLoadingState(ruleset: ruleset)
          : ProfileLoadedState(
              ruleset: ruleset,
              profile: previous.profile,
              isRefreshing: true,
            ),
    );
    try {
      final Profile profile = user == null
          ? await _repository.getCurrentProfile(ruleset: ruleset)
          : await _repository.getProfile(user: user, ruleset: ruleset);
      if (generation != _generation || emit.isDone || isClosed) {
        return;
      }
      // Follow this player's stable ID after resolving a name.
      if (user != null) {
        _user = ProfileUserId(profile.id);
      }
      emit(ProfileLoadedState(ruleset: ruleset, profile: profile));
    } on Object catch (error, stackTrace) {
      if (generation != _generation || emit.isDone || isClosed) {
        return;
      }
      final ProfileFailureKind kind = error is ProfileFailure
          ? error.kind
          : ProfileFailureKind.unavailable;
      // Keep diagnostics typed: never report OAuth payloads/headers.
      addError(ProfileFailure(kind), stackTrace);
      emit(
        previous == null
            ? ProfileFailureState(ruleset: ruleset, failure: kind)
            : ProfileLoadedState(
                ruleset: ruleset,
                profile: previous.profile,
                refreshFailure: kind,
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
