import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// osu-web `BeatmapPack::TYPES`: the API value and the tag letter.
enum BeatmapPackType {
  standard('standard'),
  featured('featured'),
  tournament('tournament'),
  loved('loved'),
  chart('chart'),
  theme('theme'),
  artist('artist');

  const BeatmapPackType(this.apiValue);
  final String apiValue;

  static BeatmapPackType? fromApi(String? value) => BeatmapPackType.values
      .where((BeatmapPackType type) => type.apiValue == value)
      .firstOrNull;
}

final class BeatmapPack {
  BeatmapPack({
    required this.tag,
    required this.name,
    required this.author,
    required this.date,
    required this.ruleset,
    required this.noDiffReduction,
    List<ProfileBeatmap>? beatmapsets,
  }) : beatmapsets = beatmapsets == null
           ? null
           : List<ProfileBeatmap>.unmodifiable(beatmapsets);

  /// Unique id in links (`S1234`, `F12`, `P345`…).
  final String tag;
  final String name;
  final String author;
  final DateTime? date;

  /// Null: every ruleset.
  final ProfileRuleset? ruleset;

  /// Difficulty-reduction mods do not count towards completion.
  final bool noDiffReduction;

  /// Only on the pack page (`GET /beatmaps/packs/{tag}`).
  final List<ProfileBeatmap>? beatmapsets;

  Uri get webUri =>
      Uri.https('osu.ppy.sh', '/beatmaps/packs/${Uri.encodeComponent(tag)}');
}

/// 100 packs per page, newest first; [cursor] null at the end.
final class BeatmapPacksPage {
  BeatmapPacksPage({required List<BeatmapPack> items, this.cursor})
    : items = List<BeatmapPack>.unmodifiable(items);
  final List<BeatmapPack> items;
  final String? cursor;
}

enum BeatmapPacksFailureKind {
  cancelled,
  notFound,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class BeatmapPacksFailure implements Exception {
  const BeatmapPacksFailure(this.kind);
  final BeatmapPacksFailureKind kind;
}

/// osu.ppy.sh `/beatmaps/packs` (`?type=`) and `/beatmaps/packs/{tag}`.
abstract final class BeatmapPackLinks {
  static final RegExp tagPattern = RegExp(r'^[A-Za-z0-9_-]{1,40}$');

  static String? tag(Uri uri) => switch (uri.pathSegments
      .where((String part) => part.isNotEmpty)
      .toList()) {
    ['beatmaps', 'packs', final String tag] when tagPattern.hasMatch(tag) =>
      tag,
    _ => null,
  };

  static BeatmapPackType? list(Uri uri) => switch (uri.pathSegments
      .where((String part) => part.isNotEmpty)
      .toList()) {
    ['beatmaps', 'packs'] =>
      BeatmapPackType.fromApi(uri.queryParameters['type']) ??
          BeatmapPackType.standard,
    _ => null,
  };
}
