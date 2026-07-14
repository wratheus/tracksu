part of 'user_cubit.dart';


@immutable
abstract class UserState {}

class UserInitial extends UserState {
}

class UserLoadedState extends UserState {
  final User userInstance;
  UserLoadedState(this.userInstance);
}

class UserErrorState extends UserState {
  final String errorMessage;

  UserErrorState(this.errorMessage);
}

class UserLoadingState extends UserState{

}