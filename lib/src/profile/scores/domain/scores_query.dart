import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

enum ProfileScoresType { best, recent }

final class ProfileScoresQuery {
  ProfileScoresQuery({
    required this.user,
    required this.ruleset,
    required this.type,
    this.limit = 20,
    this.offset = 0,
    this.legacy = false,
    this.includeFails = false,
  }) {
    // App page-size policy; do not allow accidentally unbounded reads.
    if (limit < 1 || limit > 100 || offset < 0) {
      throw ArgumentError('Expected limit 1..100 and a non-negative offset.');
    }
    if (includeFails && type != ProfileScoresType.recent) {
      throw ArgumentError('Failed plays are available only for recent scores.');
    }
  }

  final ProfileUserId user;
  final ProfileRuleset ruleset;
  final ProfileScoresType type;
  final int limit;
  final int offset;
  final bool legacy;
  final bool includeFails;
}
