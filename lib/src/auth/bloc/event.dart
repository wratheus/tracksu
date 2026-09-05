part of 'bloc.dart';

sealed class AuthorizationEvent {
  const AuthorizationEvent();
}

final class AuthorizationStarted extends AuthorizationEvent {
  const AuthorizationStarted(this.params);
  final AuthorizationParams params;
}

final class AuthorizationRequested extends AuthorizationEvent {
  const AuthorizationRequested();
}

final class AuthorizationLeftApp extends AuthorizationEvent {
  const AuthorizationLeftApp();
}

final class AuthorizationReturned extends AuthorizationEvent {
  const AuthorizationReturned();
}

final class _CallbackReceived extends AuthorizationEvent {
  const _CallbackReceived(this.uri);
  final Uri uri;
}

final class _CallbackFailed extends AuthorizationEvent {
  const _CallbackFailed();
}

final class _ReturnTimedOut extends AuthorizationEvent {
  const _ReturnTimedOut(this.generation);
  final int generation;
}
