import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';

/// Public website addresses only. Never shares an API URL, token or OAuth state.
final class ShareTarget {
  const ShareTarget._(this.uri, this.title);

  factory ShareTarget.search(String title) =>
      ShareTarget._(Uri.https('github.com', '/wratheus/tracksu'), title);
  factory ShareTarget.newsList(String title) =>
      ShareTarget._(Uri.https('osu.ppy.sh', '/home/news'), title);
  factory ShareTarget.rankings(RankingsQuery query, String title) =>
      ShareTarget._(
        Uri.https(
          'osu.ppy.sh',
          '/rankings/${query.type.mode}/global/${query.type.sort}',
          <String, String>{
            if (query.country != null) 'country': query.country!.value,
            if (query.variant.apiValue != null)
              'variant': query.variant.apiValue!,
          },
        ),
        title,
      );
  factory ShareTarget.rankingCategory(
    ProfileRuleset ruleset,
    String category,
    String title,
  ) {
    if (!{'team', 'country', 'kudosu'}.contains(category)) {
      throw ArgumentError.value(category, 'category');
    }
    return ShareTarget._(
      Uri.https(
        'osu.ppy.sh',
        category == 'kudosu'
            ? '/rankings/kudosu'
            : '/rankings/${ruleset.apiValue}/$category',
      ),
      title,
    );
  }
  factory ShareTarget.spotlight(
    ProfileRuleset ruleset,
    int? id,
    String title,
  ) => ShareTarget._(
    Uri.https(
      'osu.ppy.sh',
      '/rankings/${ruleset.apiValue}/charts',
      <String, String>{if (id != null) 'spotlight': _id(id).toString()},
    ),
    title,
  );

  factory ShareTarget.profile(
    int id,
    ProfileRuleset ruleset,
    String username,
  ) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/users/${_id(id)}/${ruleset.apiValue}'),
    username,
  );

  factory ShareTarget.beatmap(int id, String title) =>
      ShareTarget._(Uri.https('osu.ppy.sh', '/beatmaps/${_id(id)}'), title);

  factory ShareTarget.team(int id, ProfileRuleset? mode, String title) =>
      ShareTarget._(
        Uri.https(
          'osu.ppy.sh',
          '/teams/${_id(id)}${mode == null ? '' : '/${mode.apiValue}'}',
        ),
        title,
      );

  factory ShareTarget.medals(int userId, String title) => ShareTarget._(
    Uri.https(
      'osu.ppy.sh',
      '/users/${_id(userId)}',
    ).replace(fragment: 'medals'),
    title,
  );

  factory ShareTarget.beatmapset(int id, String title) =>
      ShareTarget._(Uri.https('osu.ppy.sh', '/beatmapsets/${_id(id)}'), title);

  factory ShareTarget.score(int id, String title) =>
      ShareTarget._(Uri.https('osu.ppy.sh', '/scores/${_id(id)}'), title);

  /// The website's own player search; an empty query opens the search page.
  factory ShareTarget.playerSearch(String query, String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/home/search', <String, String>{
      'mode': 'user',
      if (query.trim().isNotEmpty) 'query': query.trim(),
    }),
    title,
  );

  factory ShareTarget.beatmapSearch(String query, String title) =>
      ShareTarget._(
        Uri.https('osu.ppy.sh', '/beatmapsets', <String, String>{
          if (query.trim().isNotEmpty) 'q': query.trim(),
        }),
        title,
      );

  /// osu.ppy.sh/home/changelog, optionally filtered to one update stream.
  factory ShareTarget.changelog(String? stream, String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/home/changelog', <String, String>{
      'stream': ?stream,
    }),
    title,
  );

  /// Beatmap packs of a type, or one pack (P55).
  factory ShareTarget.packs(String type, String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/beatmaps/packs', <String, String>{'type': type}),
    title,
  );
  factory ShareTarget.pack(String tag, String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/beatmaps/packs/${Uri.encodeComponent(tag)}'),
    title,
  );

  /// osu! forum index, one forum or one topic (P54).
  factory ShareTarget.forums(String title) =>
      ShareTarget._(Uri.https('osu.ppy.sh', '/community/forums'), title);
  factory ShareTarget.forum(int id, String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/community/forums/${_id(id)}'),
    title,
  );
  factory ShareTarget.forumTopic(int id, String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/community/forums/topics/${_id(id)}'),
    title,
  );

  factory ShareTarget.wikiSearch(String query, String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/home/search', <String, String>{
      'mode': 'wiki_page',
      if (query.trim().isNotEmpty) 'query': query.trim(),
    }),
    title,
  );

  /// A linked page opened in the page viewer; only https links are shared.
  factory ShareTarget.webPage(Uri uri, String? title) {
    if (!uri.isScheme('https') || uri.userInfo.isNotEmpty) {
      throw ArgumentError('Expected a public https page.');
    }
    return ShareTarget._(uri, title ?? uri.host);
  }

  /// An osu! wiki article on the website.
  factory ShareTarget.wiki(Uri uri, String title) {
    if (uri.scheme != 'https' ||
        uri.host != 'osu.ppy.sh' ||
        !uri.path.startsWith('/wiki/')) {
      throw ArgumentError('Expected an osu! wiki page.');
    }
    return ShareTarget._(Uri.https('osu.ppy.sh', uri.path), title);
  }

  /// Daily challenges are multiplayer rooms on the website.
  factory ShareTarget.room(int id, String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/multiplayer/rooms/${_id(id)}'),
    title,
  );

  factory ShareTarget.dailyHistory(String title) => ShareTarget._(
    Uri.https('osu.ppy.sh', '/rankings/daily-challenge'),
    title,
  );

  factory ShareTarget.news(Uri uri, String title) {
    if (uri.scheme != 'https' ||
        uri.host != 'osu.ppy.sh' ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        !uri.path.startsWith('/home/news/')) {
      throw ArgumentError('Expected an osu! news page.');
    }
    return ShareTarget._(Uri.https('osu.ppy.sh', uri.path), title);
  }

  final Uri uri;
  final String title;

  static int _id(int value) {
    if (value <= 0) throw ArgumentError.value(value, 'id');
    return value;
  }
}
