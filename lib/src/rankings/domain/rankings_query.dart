import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

enum RankingsType {
  osuPerformance('osu', 'performance'),
  osuScore('osu', 'score'),
  taikoPerformance('taiko', 'performance'),
  taikoScore('taiko', 'score'),
  fruitsPerformance('fruits', 'performance'),
  fruitsScore('fruits', 'score'),
  maniaPerformance('mania', 'performance'),
  maniaScore('mania', 'score');

  const RankingsType(this.mode, this.sort);
  final String mode;
  final String sort;

  ProfileRuleset get ruleset => switch (this) {
    osuPerformance || osuScore => ProfileRuleset.osu,
    taikoPerformance || taikoScore => ProfileRuleset.taiko,
    fruitsPerformance || fruitsScore => ProfileRuleset.fruits,
    maniaPerformance || maniaScore => ProfileRuleset.mania,
  };
}

final class RankingsQuery {
  RankingsQuery({required this.type, this.page = 1}) {
    if (page < 1) throw ArgumentError.value(page, 'page');
  }
  final RankingsType type;
  final int page;
}
