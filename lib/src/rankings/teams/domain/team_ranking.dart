import 'package:meta/meta.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// One row of osu! team rankings (`TeamStatistics` with `team` and
/// `member_count`). The position is this table's, by the selected sort.
@immutable
final class TeamRankingEntry {
  const TeamRankingEntry({
    required this.team,
    required this.position,
    required this.performance,
    required this.rankedScore,
    required this.playCount,
    required this.memberCount,
  });
  final ProfileTeam team;
  final int position;
  final double performance;
  final int rankedScore;
  final int playCount;
  final int memberCount;
}

@immutable
final class TeamRankingsQuery {
  TeamRankingsQuery({
    required this.ruleset,
    required this.performance,
    this.page = 1,
  }) {
    if (page < 1) throw ArgumentError.value(page, 'page');
  }
  final ProfileRuleset ruleset;

  /// `sort=performance` when true, `sort=score` otherwise.
  final bool performance;
  final int page;
}

final class TeamRankingsPage {
  TeamRankingsPage({
    required List<TeamRankingEntry> items,
    required this.nextPage,
  }) : items = List<TeamRankingEntry>.unmodifiable(items);
  final List<TeamRankingEntry> items;
  final int? nextPage;
}

abstract interface class TeamRankingsRepository {
  Future<TeamRankingsPage> load(TeamRankingsQuery query);
  void cancelPending();
}
