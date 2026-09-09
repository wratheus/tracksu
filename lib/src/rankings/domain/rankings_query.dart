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

  static RankingsType select(ProfileRuleset ruleset, bool performance) =>
      values.firstWhere(
        (RankingsType type) =>
            type.ruleset == ruleset &&
            (type.sort == 'performance') == performance,
      );

  ProfileRuleset get ruleset => switch (this) {
    osuPerformance || osuScore => ProfileRuleset.osu,
    taikoPerformance || taikoScore => ProfileRuleset.taiko,
    fruitsPerformance || fruitsScore => ProfileRuleset.fruits,
    maniaPerformance || maniaScore => ProfileRuleset.mania,
  };
}

final class RankingsQuery {
  RankingsQuery({
    required this.type,
    this.page = 1,
    this.country,
    this.variant = ManiaVariant.all,
  }) {
    if (page < 1) throw ArgumentError.value(page, 'page');
    if (type.ruleset != ProfileRuleset.mania && variant != ManiaVariant.all) {
      throw ArgumentError('Variants are only available for mania.');
    }
  }
  final RankingsType type;
  final int page;
  final RankingCountry? country;
  final ManiaVariant variant;
}

enum ManiaVariant {
  all(null),
  fourKeys('4k'),
  sevenKeys('7k');

  const ManiaVariant(this.apiValue);
  final String? apiValue;
}

final class RankingCountry {
  factory RankingCountry(String input) {
    final String value = input.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(value)) {
      throw const FormatException('Expected a two-letter country code.');
    }
    return RankingCountry._(value);
  }
  const RankingCountry._(this.value);
  final String value;
}
