import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/_shared/content/domain/content_page.dart';

final class TeamParams {
  const TeamParams(this.id, {this.ruleset});
  final int id;
  final ProfileRuleset? ruleset;
}

final class TeamDetails {
  TeamDetails({
    required this.identity,
    required this.createdAt,
    required this.defaultRuleset,
    required this.ruleset,
    required this.isOpen,
    required this.emptySlots,
    required this.leader,
    required List<TeamMember> members,
    required this.statistics,
    this.cover,
    this.description,
  }) : members = List<TeamMember>.unmodifiable(members);
  final ProfileTeam identity;
  final DateTime createdAt;
  final ProfileRuleset defaultRuleset;
  final ProfileRuleset ruleset;
  final bool isOpen;
  final int emptySlots;
  final TeamMember leader;
  final List<TeamMember> members;
  final TeamStatistics statistics;
  final Uri? cover;
  final ContentPage? description;
  Uri get uri =>
      Uri.https('osu.ppy.sh', '/teams/${identity.id}/${ruleset.apiValue}');
}

final class TeamStatistics {
  const TeamStatistics({
    required this.playCount,
    required this.rankedScore,
    required this.performance,
    this.rank,
  });
  final int playCount;
  final int rankedScore;
  final double performance;
  final int? rank;
}

final class TeamMember {
  TeamMember({
    required this.id,
    required this.name,
    required this.country,
    required this.online,
    required this.deleted,
    required this.supporter,
    required List<ProfileGroup> groups,
    this.avatar,
    this.lastVisit,
  }) : groups = List<ProfileGroup>.unmodifiable(groups);
  final int id;
  final String name;
  final String country;
  final Uri? avatar;
  final bool online;
  final bool deleted;
  final bool supporter;
  final DateTime? lastVisit;
  final List<ProfileGroup> groups;
}

abstract interface class TeamRepository {
  Future<TeamDetails> load(TeamParams params);
  void cancelPending();
}

enum TeamFailureKind {
  notFound,
  accessDenied,
  connection,
  rateLimited,
  invalidResponse,
  unavailable,
}

final class TeamFailure implements Exception {
  const TeamFailure(this.kind);
  final TeamFailureKind kind;
}
