import 'package:meta/meta.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';

/// One row of the kudosu ranking (`UserCompact` with the `kudosu` include):
/// kudosu are earned by helping mappers in modding discussions.
@immutable
final class KudosuRankingEntry {
  const KudosuRankingEntry({
    required this.position,
    required this.userId,
    required this.username,
    required this.total,
    required this.available,
    this.countryCode,
    this.avatarUri,
    this.team,
  });
  final int position;
  final int userId;
  final String username;
  final int total;
  final int available;
  final String? countryCode;
  final Uri? avatarUri;
  final ProfileTeam? team;
}

final class KudosuRankingPage {
  KudosuRankingPage({
    required List<KudosuRankingEntry> items,
    required this.nextPage,
  }) : items = List<KudosuRankingEntry>.unmodifiable(items);
  final List<KudosuRankingEntry> items;
  final int? nextPage;
}

abstract interface class KudosuRankingRepository {
  Future<KudosuRankingPage> load(int page);
}
