import 'package:tracksu/src/profile/scores/domain/scores_page.dart';
import 'package:tracksu/src/profile/scores/domain/scores_query.dart';

abstract interface class ProfileScoresRepository {
  Future<ProfileScoresPage> load(ProfileScoresQuery query);
  void cancelPending();
}

enum ProfileScoresFailureKind {
  cancelled,
  notFound,
  accessDenied,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class ProfileScoresFailure implements Exception {
  const ProfileScoresFailure(this.kind);
  final ProfileScoresFailureKind kind;
}
