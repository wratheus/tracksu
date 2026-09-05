final class AuthorizationParams {
  const AuthorizationParams({
    this.initialCallbackUri,
    this.startOnOpen = false,
  });
  final Uri? initialCallbackUri;
  final bool startOnOpen;
}

final class AuthorizationAttempt {
  const AuthorizationAttempt({required this.state, required this.uri});
  final String state;
  final Uri uri;
}

abstract interface class AuthorizationRepository {
  Future<AuthorizationAttempt> prepare();
  Future<String?> restoreState();
  Future<bool> openBrowser(Uri uri);
  Future<void> clear();
}

enum AuthorizationFailure {
  expired,
  responseUnavailable,
  mismatch,
  cancelled,
  invalidResponse,
  preparation,
  launch,
  completion,
  incomplete,
}
