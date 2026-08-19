import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_repository.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

final class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  factory ProfileBloc({required ProfileRepository repository}) {
    return ProfileBloc._(repository);
  }

  ProfileBloc._(this._repository) : super(const ProfileInitialState()) {
    on<CurrentProfileLoadRequested>(_onCurrentProfileLoadRequested);
    on<ProfileLookupRequested>(_onProfileLookupRequested);
  }

  final ProfileRepository _repository;

  Future<void> _onCurrentProfileLoadRequested(
    CurrentProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState(request: event));

    try {
      final Profile profile = await _repository.getCurrentProfile(
        ruleset: event.ruleset,
      );
      emit(ProfileLoadedState(request: event, profile: profile));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(ProfileFailureState(request: event));
    }
  }

  Future<void> _onProfileLookupRequested(
    ProfileLookupRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState(request: event));

    try {
      final Profile profile = await _repository.getProfile(
        user: event.user,
        ruleset: event.ruleset,
      );
      emit(ProfileLoadedState(request: event, profile: profile));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(ProfileFailureState(request: event));
    }
  }
}

@immutable
sealed class ProfileEvent {
  const ProfileEvent({required this.ruleset});

  final ProfileRuleset ruleset;
}

final class CurrentProfileLoadRequested extends ProfileEvent {
  const CurrentProfileLoadRequested({required super.ruleset});
}

final class ProfileLookupRequested extends ProfileEvent {
  const ProfileLookupRequested({required this.user, required super.ruleset});

  final ProfileUserReference user;
}

@immutable
sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

final class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState({required this.request});

  final ProfileEvent request;
}

final class ProfileLoadedState extends ProfileState {
  const ProfileLoadedState({required this.request, required this.profile});

  final ProfileEvent request;
  final Profile profile;
}

final class ProfileFailureState extends ProfileState {
  const ProfileFailureState({required this.request});

  final ProfileEvent request;
}
