import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';

/// osu-web `Spotlight` ("chart"): a ranked-score leaderboard over a curated
/// set of beatmapsets. osu! now lists these as "Spotlights (old)"; current
/// competitions are Seasons, a separate system this feature does not cover.
final class Spotlight {
  const Spotlight({
    required this.id,
    required this.name,
    required this.kind,
    this.startDate,
    this.endDate,
    this.participantCount,
  });
  final int id;
  final String name;
  final SpotlightKind kind;

  /// Descriptive dates entered by osu! staff and shown verbatim by osu-web.
  /// The server neither validates nor uses them, so they carry no ordering
  /// contract: chart 68 "Best of 2012" starts 2013-02-01 and ends 2013-01-31.
  /// Show them as two independent facts, never as a computed range/duration.
  final DateTime? startDate;
  final DateTime? endDate;

  /// Only present in the charts response; the catalog does not include it.
  final int? participantCount;
}

/// `type` of osu-web spotlights. `bestof` and `monthly` are the periodic
/// kinds (`Spotlight::PERIODIC_TYPES`). Unknown future values stay [other].
enum SpotlightKind {
  monthly('monthly'),
  bestOf('bestof'),
  special('special'),
  theme('theme'),
  other(null);

  const SpotlightKind(this.apiValue);
  final String? apiValue;

  static SpotlightKind fromApi(String? value) => values.firstWhere(
    (SpotlightKind kind) => kind.apiValue != null && kind.apiValue == value,
    orElse: () => other,
  );
}

final class SpotlightQuery {
  SpotlightQuery({required this.id, required this.ruleset}) {
    if (id <= 0) throw ArgumentError.value(id, 'id');
  }
  final int id;
  final ProfileRuleset ruleset;
}

final class SpotlightPlayer {
  const SpotlightPlayer({
    required this.id,
    required this.name,
    required this.country,
    required this.score,
    this.avatarUri,
    this.team,
  });
  final int id;
  final String name;
  final String country;
  final int score;
  final Uri? avatarUri;
  final ProfileTeam? team;
}

final class SpotlightMap {
  const SpotlightMap({
    required this.id,
    required this.title,
    required this.artist,
    this.metadata,
    this.difficultyCount,
  });
  final int id;
  final String title;
  final String artist;
  final BeatmapMetadata? metadata;
  final int? difficultyCount;
}

final class SpotlightDetails {
  SpotlightDetails({
    required this.spotlight,
    required List<SpotlightPlayer> players,
    required List<SpotlightMap> maps,
  }) : players = List<SpotlightPlayer>.unmodifiable(players),
       maps = List<SpotlightMap>.unmodifiable(maps);
  final Spotlight spotlight;
  final List<SpotlightPlayer> players;
  final List<SpotlightMap> maps;
}

abstract interface class SpotlightsRepository {
  /// Newest first: osu-web orders the catalog by `chart_id` descending.
  Future<List<Spotlight>> catalog();

  /// A 404 for a catalog chart means the ruleset has no chart table
  /// (`Spotlight::hasMode`), surfaced as `RankingsFailureKind.notFound`.
  Future<SpotlightDetails> load(SpotlightQuery query);
  void cancelPending();
}
