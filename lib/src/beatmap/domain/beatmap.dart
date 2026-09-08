import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';

sealed class BeatmapParams {
  BeatmapParams(this.id) {
    if (id <= 0) throw ArgumentError.value(id, 'id');
  }
  final int id;
}

final class BeatmapDifficultyParams extends BeatmapParams {
  BeatmapDifficultyParams(super.id, {this.ruleset});
  final ProfileRuleset? ruleset;
}

final class BeatmapsetParams extends BeatmapParams {
  BeatmapsetParams(super.id);
}

final class BeatmapDifficulty {
  const BeatmapDifficulty({
    required this.id,
    required this.name,
    required this.ruleset,
    required this.stars,
    required this.lengthSeconds,
    this.bpm,
  });
  final int id;
  final String name;
  final ProfileRuleset ruleset;
  final double stars;
  final int lengthSeconds;
  final double? bpm;
}

final class BeatmapDetails {
  BeatmapDetails({
    required this.id,
    required this.title,
    required this.artist,
    required this.creator,
    required List<BeatmapDifficulty> difficulties,
    this.metadata,
  }) : difficulties = List<BeatmapDifficulty>.unmodifiable(difficulties);
  final int id;
  final String title;
  final String artist;
  final String creator;
  final List<BeatmapDifficulty> difficulties;
  final BeatmapMetadata? metadata;
}
