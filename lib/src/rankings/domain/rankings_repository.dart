import 'package:tracksu/src/rankings/domain/entry.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';

abstract interface class RankingsRepository {
  Future<RankingsPage> load(RankingsQuery query);
  void cancelPending();
}

enum RankingsFailureKind {
  cancelled,
  notFound,
  accessDenied,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class RankingsFailure implements Exception {
  const RankingsFailure(this.kind);
  final RankingsFailureKind kind;
}
