import 'dart:io';

import 'package:html/dom.dart' show DocumentFragment, Element;
import 'package:html/parser.dart' as parser;
import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/comments/data/remote_source.dart';
import 'package:tracksu/src/comments/domain/comment.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class CommentsRepositoryImpl implements CommentsRepository {
  const CommentsRepositoryImpl({required this._source});
  final CommentsRemoteSource _source;

  @override
  Future<CommentsPage> load(
    CommentTarget target, {
    required CommentSort sort,
    int parentId = 0,
    CommentCursor? cursor,
  }) async {
    try {
      return decode(
        await _source.load(
          target,
          sort: sort,
          parentId: parentId,
          cursor: cursor,
        ),
      );
    } on CommentsRemoteException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const CommentsFailure(CommentsFailureKind.unavailable),
        stackTrace,
      );
    } on OAuthRemoteSourceException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const CommentsFailure(CommentsFailureKind.unavailable),
        stackTrace,
      );
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const CommentsFailure(CommentsFailureKind.invalidResponse),
        stackTrace,
      );
    } on Object catch (error, stackTrace) {
      if (error is RestClientException || error is IOException) {
        Error.throwWithStackTrace(
          const CommentsFailure(CommentsFailureKind.connection),
          stackTrace,
        );
      }
      rethrow;
    }
  }

  static CommentsPage decode(Map<String, dynamic> raw) {
    final JsonMapReader bundle = JsonMapReader(raw);
    List<Comment> list(String key) => <Comment>[
      for (final Object? item
          in bundle.optionalList(key) ?? const <Object?>[])
        _comment(JsonMapReader.asMap(item)),
    ];
    final Map<int, CommentAuthor> users = <int, CommentAuthor>{
      for (final Object? item
          in bundle.optionalList('users') ?? const <Object?>[])
        if (_user(JsonMapReader(JsonMapReader.asMap(item)))
            case final CommentAuthor user)
          user.id: user,
    };
    final Map<String, dynamic>? cursor = bundle.optionalMap('cursor');
    return CommentsPage(
      comments: list('comments'),
      included: list('included_comments'),
      pinned: list('pinned_comments'),
      users: users,
      hasMore: raw['has_more'] == true,
      cursor: cursor == null
          ? null
          : <String, String>{
              for (final MapEntry<String, dynamic> entry in cursor.entries)
                if (entry.value != null) entry.key: '${entry.value}',
            },
      total: bundle.optionalInt('total'),
    );
  }

  static Comment _comment(Map<String, dynamic> raw) {
    final JsonMapReader json = JsonMapReader(raw);
    final int votes = json.optionalInt('votes_count') ?? 0;
    final int replies = json.optionalInt('replies_count') ?? 0;
    if (replies < 0) throw const FormatException('Negative replies count.');
    final bool deleted = json.optionalString('deleted_at') != null;
    final String? html = json.optionalString('message_html');
    return Comment(
      id: json.requiredInt('id', positive: true),
      parentId: json.optionalInt('parent_id'),
      userId: json.optionalInt('user_id'),
      legacyName: json.optionalString('legacy_name'),
      messageHtml: deleted || html == null ? null : sanitize(html),
      createdAt: DateTime.parse(json.requiredString('created_at')).toUtc(),
      editedAt: switch (json.optionalString('edited_at')) {
        final String value => DateTime.parse(value).toUtc(),
        null => null,
      },
      deleted: deleted,
      pinned: raw['pinned'] == true,
      votes: votes,
      repliesCount: replies,
    );
  }

  static CommentAuthor? _user(JsonMapReader json) {
    final int? id = json.optionalInt('id');
    final String? name = json.optionalString('username');
    if (id == null || id <= 0 || name == null || name.isEmpty) return null;
    final Uri? avatar = Uri.tryParse(json.optionalString('avatar_url') ?? '');
    return CommentAuthor(
      id: id,
      username: name,
      countryCode: json.optionalString('country_code'),
      avatarUri:
          avatar != null && avatar.isScheme('https') && avatar.host.isNotEmpty
          ? avatar
          : null,
    );
  }

  static const Set<String> _dropped = <String>{
    'img',
    'iframe',
    'video',
    'audio',
    'script',
    'style',
    'object',
    'embed',
    'form',
    'input',
  };

  /// Comment markdown is rendered by osu-web; the app keeps text formatting
  /// and links but never loads media from a comment (image links stay
  /// tappable as links).
  static String sanitize(String html) {
    if (html.length > 100000) throw const FormatException('Comment too long.');
    final DocumentFragment fragment = parser.parseFragment(html);
    for (final Element element in fragment.querySelectorAll('*').toList()) {
      if (_dropped.contains(element.localName)) {
        final String? src = element.attributes['src'];
        if (element.localName == 'img' && src != null) {
          element.replaceWith(
            Element.tag('a')
              ..attributes['href'] = src
              ..text = element.attributes['alt']?.trim().isNotEmpty == true
                  ? element.attributes['alt']!
                  : src,
          );
        } else {
          element.remove();
        }
        continue;
      }
      element.attributes.removeWhere(
        (Object key, _) =>
            key is String && (key.startsWith('on') || key == 'style'),
      );
    }
    return fragment.outerHtml;
  }
}
