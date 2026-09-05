part of 'bloc.dart';

sealed class AuthorizationState {
  const AuthorizationState();
}

final class AuthorizationIdleState extends AuthorizationState {
  const AuthorizationIdleState();
}

final class AuthorizationPreparingState extends AuthorizationState {
  const AuthorizationPreparingState();
}

final class AuthorizationWaitingState extends AuthorizationState {
  const AuthorizationWaitingState();
}

final class AuthorizationCompletingState extends AuthorizationState {
  const AuthorizationCompletingState();
}

final class AuthorizationSuccessState extends AuthorizationState {
  const AuthorizationSuccessState();
}

final class AuthorizationFailureState extends AuthorizationState {
  const AuthorizationFailureState(this.failure);
  final AuthorizationFailure failure;
}
