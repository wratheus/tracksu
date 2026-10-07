import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';
import 'package:tracksu/src/_shared/content/domain/content_page.dart';
import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';

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
    this.stats,
  });
  final int id;
  final String name;
  final ProfileRuleset ruleset;
  final double stars;
  final int lengthSeconds;
  final double? bpm;

  /// Attributes and counts from BeatmapExtended; null when absent.
  final BeatmapDifficultyStats? stats;
}

/// osu-web BeatmapExtended attributes of one difficulty. `cs` is the key
/// count in mania; `accuracy` is OD and `drain` is HP.
final class BeatmapDifficultyStats {
  const BeatmapDifficultyStats({
    required this.cs,
    required this.ar,
    required this.od,
    required this.hp,
    this.circles,
    this.sliders,
    this.spinners,
    this.maxCombo,
    this.playCount,
    this.passCount,
  });
  final double cs;
  final double ar;
  final double od;
  final double hp;
  final int? circles;
  final int? sliders;
  final int? spinners;
  final int? maxCombo;
  final int? playCount;
  final int? passCount;
}

final class BeatmapDetails {
  BeatmapDetails({
    required this.id,
    required this.title,
    required this.artist,
    required this.creator,
    required List<BeatmapDifficulty> difficulties,
    this.metadata,
    this.description,
    this.preview,
  }) : difficulties = List<BeatmapDifficulty>.unmodifiable(difficulties);
  final int id;
  final String title;
  final String artist;
  final String creator;
  final List<BeatmapDifficulty> difficulties;
  final BeatmapMetadata? metadata;
  final ContentPage? description;
  final AudioTrack? preview;
}
