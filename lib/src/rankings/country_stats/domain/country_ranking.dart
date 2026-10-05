import 'package:meta/meta.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';

/// One row of osu! country rankings (`CountryStatistics`), ordered by PP.
@immutable
final class CountryRankingEntry {
  const CountryRankingEntry({
    required this.country,
    required this.position,
    required this.performance,
    required this.rankedScore,
    required this.playCount,
    required this.activeUsers,
  });
  final RankingCountry country;
  final int position;
  final double performance;
  final int rankedScore;
  final int playCount;
  final int activeUsers;
}

@immutable
final class CountryRankingsQuery {
  CountryRankingsQuery({required this.ruleset, this.page = 1}) {
    if (page < 1) throw ArgumentError.value(page, 'page');
  }
  final ProfileRuleset ruleset;
  final int page;
}

final class CountryRankingsPage {
  CountryRankingsPage({
    required List<CountryRankingEntry> items,
    required this.nextPage,
  }) : items = List<CountryRankingEntry>.unmodifiable(items);
  final List<CountryRankingEntry> items;
  final int? nextPage;
}

abstract interface class CountryRankingsRepository {
  Future<CountryRankingsPage> load(CountryRankingsQuery query);
  void cancelPending();
}
