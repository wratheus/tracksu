enum ProfileFailureKind {
  notFound,
  accessDenied,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class ProfileFailure implements Exception {
  const ProfileFailure(this.kind);

  final ProfileFailureKind kind;
}
