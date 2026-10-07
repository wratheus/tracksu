import 'package:meta/meta.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// osu-web `BeatmapsetSearchRequestParams` status (`s`) values a guest can
/// use. `favourites`, `mine` and played/rank filters need a signed-in user.
enum BeatmapSearchStatus {
  leaderboard('leaderboard'),
  ranked('ranked'),
  qualified('qualified'),
  loved('loved'),
  pending('pending'),
  wip('wip'),
  graveyard('graveyard'),
  any('any');

  const BeatmapSearchStatus(this.apiValue);
  final String apiValue;
}

/// osu! genre ids (`g`), as in the osu! API v1 reference (osu-web keeps
/// them in the `osu_genres` table; `any` sends nothing).
enum BeatmapGenre {
  any(null),
  unspecified(1),
  videoGame(2),
  anime(3),
  rock(4),
  pop(5),
  other(6),
  novelty(7),
  hipHop(9),
  electronic(10),
  metal(11),
  classical(12),
  folk(13),
  jazz(14);

  const BeatmapGenre(this.id);
  final int? id;
}

/// osu! language ids (`l`), same source as [BeatmapGenre].
enum BeatmapLanguage {
  any(null),
  english(2),
  japanese(3),
  chinese(4),
  instrumental(5),
  korean(6),
  french(7),
  german(8),
  swedish(9),
  spanish(10),
  italian(11),
  russian(12),
  polish(13),
  other(14),
  unspecified(1);

  const BeatmapLanguage(this.id);
  final int? id;
}

@immutable
final class BeatmapSearchQuery {
  const BeatmapSearchQuery({
    this.text = '',
    this.ruleset = ProfileRuleset.osu,
    this.status = BeatmapSearchStatus.leaderboard,
    this.genre = BeatmapGenre.any,
    this.language = BeatmapLanguage.any,
  });
  final String text;

  /// Null: any mode (osu-web drops an absent or invalid `m`).
  final ProfileRuleset? ruleset;
  final BeatmapSearchStatus status;
  final BeatmapGenre genre;
  final BeatmapLanguage language;

  /// [anyRuleset] clears the mode (null [ruleset] means "keep").
  BeatmapSearchQuery copyWith({
    String? text,
    ProfileRuleset? ruleset,
    bool anyRuleset = false,
    BeatmapSearchStatus? status,
    BeatmapGenre? genre,
    BeatmapLanguage? language,
  }) => BeatmapSearchQuery(
    text: text ?? this.text,
    ruleset: anyRuleset ? null : ruleset ?? this.ruleset,
    status: status ?? this.status,
    genre: genre ?? this.genre,
    language: language ?? this.language,
  );

  @override
  bool operator ==(Object other) =>
      other is BeatmapSearchQuery &&
      other.text == text &&
      other.ruleset == ruleset &&
      other.status == status &&
      other.genre == genre &&
      other.language == language;

  @override
  int get hashCode => Object.hash(text, ruleset, status, genre, language);
}

/// Beatmapsets reuse the profile list model (same card, same tap target).
final class BeatmapSearchPage {
  BeatmapSearchPage({
    required List<ProfileBeatmap> items,
    required this.cursor,
    this.total,
  }) : items = List<ProfileBeatmap>.unmodifiable(items);
  final List<ProfileBeatmap> items;

  /// osu-web `cursor_string`; null on the last page.
  final String? cursor;
  final int? total;
}

enum BeatmapSearchFailureKind { connection, unavailable, invalidResponse }

final class BeatmapSearchFailure implements Exception {
  const BeatmapSearchFailure(this.kind);
  final BeatmapSearchFailureKind kind;
}

abstract interface class BeatmapSearchRepository {
  Future<BeatmapSearchPage> search(BeatmapSearchQuery query, {String? cursor});
}
