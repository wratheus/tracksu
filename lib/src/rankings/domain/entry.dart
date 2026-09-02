final class RankingEntry {
  const RankingEntry({
    required this.id,
    required this.username,
    required this.country,
    required this.pp,
    required this.rankedScore,
  });
  final int id;
  final String username;
  final String country;
  final double pp;
  final int rankedScore;
}

final class RankingsPage {
  RankingsPage({required List<RankingEntry> items, required this.nextPage})
    : items = List<RankingEntry>.unmodifiable(items);
  final List<RankingEntry> items;
  final int? nextPage;
}
