import 'package:tracksu/src/beatmap/domain/beatmap.dart';

abstract interface class BeatmapRepository {
  Future<BeatmapDetails> load(BeatmapParams params);
  void cancelPending();
}

enum BeatmapFailureKind {
  notFound,
  accessDenied,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class BeatmapFailure implements Exception {
  const BeatmapFailure(this.kind);
  final BeatmapFailureKind kind;
}
