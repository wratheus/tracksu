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

@immutable
final class BeatmapSearchQuery {
  const BeatmapSearchQuery({
    this.text = '',
    this.ruleset = ProfileRuleset.osu,
    this.status = BeatmapSearchStatus.leaderboard,
  });
  final String text;
  final ProfileRuleset ruleset;
  final BeatmapSearchStatus status;

  BeatmapSearchQuery copyWith({
    String? text,
    ProfileRuleset? ruleset,
    BeatmapSearchStatus? status,
  }) => BeatmapSearchQuery(
    text: text ?? this.text,
    ruleset: ruleset ?? this.ruleset,
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) =>
      other is BeatmapSearchQuery &&
      other.text == text &&
      other.ruleset == ruleset &&
      other.status == status;

  @override
  int get hashCode => Object.hash(text, ruleset, status);
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
