import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';

final class Spotlight {
  const Spotlight({
    required this.id,
    required this.name,
    this.startsAt,
    this.endsAt,
    this.participantCount,
  });
  final int id;
  final String name;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? participantCount;
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
  Future<List<Spotlight>> catalog();
  Future<SpotlightDetails> load(SpotlightQuery query);
  void cancelPending();
}
