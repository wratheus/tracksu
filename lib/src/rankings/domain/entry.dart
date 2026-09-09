import 'package:tracksu/src/profile/domain/profile_details.dart';

final class RankingEntry {
  const RankingEntry({
    required this.id,
    required this.username,
    required this.country,
    required this.pp,
    required this.rankedScore,
    required this.position,
    this.avatarUri,
    this.team,
  });
  final int id;
  final String username;
  final String country;
  final double pp;
  final int rankedScore;

  /// Position in the requested server page, not the user's global PP rank.
  final int position;
  final Uri? avatarUri;
  final ProfileTeam? team;
}

final class RankingsPage {
  RankingsPage({required List<RankingEntry> items, required this.nextPage})
    : items = List<RankingEntry>.unmodifiable(items);
  final List<RankingEntry> items;
  final int? nextPage;
}
