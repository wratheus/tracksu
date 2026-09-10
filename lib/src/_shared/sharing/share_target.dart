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
