import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';

abstract interface class ProfileBeatmapsRepository {
  Future<ProfileBeatmapsPage> load(ProfileBeatmapsQuery query);
  void cancelPending();
}

enum ProfileBeatmapsFailureKind {
  cancelled,
  notFound,
  accessDenied,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class ProfileBeatmapsFailure implements Exception {
  const ProfileBeatmapsFailure(this.kind);
  final ProfileBeatmapsFailureKind kind;
}
