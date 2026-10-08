import 'package:html/parser.dart' as html;
import 'package:tracksu/src/_shared/content/data/content_parser.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/forum/domain/forum.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// osu! forum, read only (scope public; osu-web `ForumsController`,
/// `TopicsController`). Each read has its own cancellation token so a
/// forum page can load its header and first topics together; [cancelPending]
/// stops all of them.
final class ForumRepository {
  ForumRepository({required RestClient restClient}) : _client = restClient;
  final RestClient _client;
  final Set<RestCancellationToken> _pending = <RestCancellationToken>{};

  /// osu-web caps topic and user pages at 50.
  static const int topicsPerPage = 50;
  static const int postsPerPage = 20;

  void cancelPending() {
    for (final RestCancellationToken token in _pending) {
      token.cancel();
    }
    _pending.clear();
  }

  /// Top-level forums with their subforums (`GET /forums`).
  Future<List<ForumNode>> forums() => _read(
    '/forums',
    const <String, Object?>{},
    (Map<String, dynamic> json) => <ForumNode>[
      for (final Object? item in _list(json['forums'])) _forum(item),
    ],
  );

  /// Forum header, subforums and pinned topics (`GET /forums/{id}`). Its
  /// first normal topics are not used: [topics] pages them with a cursor.
  Future<ForumBoard> board(int id) => _read(
    '/forums/$id',
    const <String, Object?>{},
    (Map<String, dynamic> json) => ForumBoard(
      forum: _forum(json['forum']),
      pinned: <ForumTopic>[
        for (final Object? item in _list(json['pinned_topics'])) _topic(item),
      ],
    ),
  );

  /// Topics of one forum by last post (`GET /forums/topics`). Pinned topics
  /// come in this list too; callers drop the ones already shown on top.
  Future<ForumTopicsPage> topics(int forumId, {String? cursor}) => _read(
    '/forums/topics',
    <String, Object?>{
      'forum_id': forumId,
      'sort': 'new',
      'limit': topicsPerPage,
      'cursor_string': ?cursor,
    },
    (Map<String, dynamic> json) {
      final Object? next = json['cursor_string'];
      return ForumTopicsPage(
        topics: <ForumTopic>[
          for (final Object? item in _list(json['topics'])) _topic(item),
        ],
        cursor: next is String && next.isNotEmpty ? next : null,
      );
    },
  );

  /// Posts oldest first with rendered bodies (`GET /forums/topics/{id}`).
  /// The API returns a cursor after every non-empty page; a short page is
  /// the end of the topic.
  Future<ForumPostsPage> posts(int topicId, {String? cursor}) => _read(
    '/forums/topics/$topicId',
    <String, Object?>{
      'sort': 'id_asc',
      'limit': postsPerPage,
      'cursor_string': ?cursor,
    },
    (Map<String, dynamic> json) {
      final ForumTopic topic = _topic(json['topic']);
      final List<ForumPost> posts = <ForumPost>[
        for (final Object? item in _list(json['posts'])) _post(item, topic),
      ];
      final Object? next = json['cursor_string'];
      return ForumPostsPage(
        topic: topic,
        posts: posts,
        cursor:
            posts.length >= postsPerPage && next is String && next.isNotEmpty
            ? next
            : null,
      );
    },
  );

  /// Authors by id (`GET /users?ids[]=`), at most 50 per request.
  Future<List<ForumAuthor>> authors(Iterable<int> ids) {
    final List<int> unique = ids.toSet().take(50).toList(growable: false);
    if (unique.isEmpty) return Future<List<ForumAuthor>>.value(const []);
    return _read(
      '/users',
      <String, Object?>{'ids[]': unique},
      (Map<String, dynamic> json) => <ForumAuthor>[
        for (final Object? item in _list(json['users'])) _author(item),
      ],
    );
  }

  Future<T> _read<T>(
    String path,
    Map<String, Object?> query,
    T Function(Map<String, dynamic> json) decode,
  ) async {
    final RestCancellationToken token = RestCancellationToken();
    _pending.add(token);
    try {
      final RestResponse response = await _client.get(
        path: path,
        queryParameters: query,
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const ForumFailure(ForumFailureKind.cancelled);
      }
      if (response.statusCode != 200) throw _status(response.statusCode);
      return decode(response.payload.asMap());
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_status(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ForumFailure(ForumFailureKind.invalidResponse),
        stackTrace,
      );
    } on TypeError catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ForumFailure(ForumFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ForumFailure(ForumFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ForumFailure(ForumFailureKind.connection),
        stackTrace,
      );
    } finally {
      _pending.remove(token);
    }
  }

  static ForumFailure _status(int status) => ForumFailure(switch (status) {
    404 || 403 => ForumFailureKind.notFound,
    429 => ForumFailureKind.rateLimited,
    _ => ForumFailureKind.unavailable,
  });

  static List<Object?> _list(Object? value) => switch (value) {
    null => const <Object?>[],
    final List<dynamic> list => list,
    _ => throw const FormatException('Expected a list.'),
  };

  static Map<String, dynamic> _map(Object? value) => switch (value) {
    final Map<String, dynamic> map => map,
    _ => throw const FormatException('Expected an object.'),
  };

  static int _id(Object? value) => switch (value) {
    final int id when id > 0 => id,
    _ => throw const FormatException('Expected a positive id.'),
  };

  static DateTime _time(Object? value) => switch (value) {
    final String text => DateTime.parse(text).toUtc(),
    _ => throw const FormatException('Expected a timestamp.'),
  };

  static DateTime? _optionalTime(Object? value) =>
      value == null ? null : _time(value);

  static ForumNode _forum(Object? value) {
    final Map<String, dynamic> json = _map(value);
    return ForumNode(
      id: _id(json['id']),
      name: json['name'] as String,
      description: _plain(json['description'] as String?),
      subforums: <ForumNode>[
        for (final Object? item in _list(json['subforums'])) _forum(item),
      ],
    );
  }

  /// Forum descriptions can carry markup and entities; rows show text.
  static String _plain(String? value) {
    if (value == null || value.isEmpty) return '';
    final String? text = html.parseFragment(value).text;
    return (text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static ForumTopic _topic(Object? value) {
    final Map<String, dynamic> json = _map(value);
    return ForumTopic(
      id: _id(json['id']),
      forumId: _id(json['forum_id']),
      title: json['title'] as String,
      type: switch (json['type']) {
        'sticky' => ForumTopicType.sticky,
        'announcement' => ForumTopicType.announcement,
        _ => ForumTopicType.normal,
      },
      isLocked: json['is_locked'] == true,
      postCount: (json['post_count'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      createdAt: _time(json['created_at']),
      updatedAt: _optionalTime(json['updated_at']) ?? _time(json['created_at']),
      // Legacy topics may have no poster (0).
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
    );
  }

  static ForumPost _post(Object? value, ForumTopic topic) {
    final Map<String, dynamic> json = _map(value);
    final int id = _id(json['id']);
    ContentDocument? document;
    final Object? body = json['body'];
    if (body is Map<String, dynamic> && body['html'] is String) {
      try {
        document = ContentParser.parse(
          body['html'] as String,
          format: ContentFormat.html,
          base: topic.webUri,
        );
      } on FormatException {
        // A malformed or huge post keeps its place; the screen links to it.
        document = null;
      }
    }
    return ForumPost(
      id: id,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      createdAt: _time(json['created_at']),
      editedAt: _optionalTime(json['edited_at']),
      document: document,
    );
  }

  static ForumAuthor _author(Object? value) {
    final Map<String, dynamic> json = _map(value);
    final Object? avatar = json['avatar_url'];
    final Uri? avatarUri = avatar is String ? Uri.tryParse(avatar) : null;
    final Object? country = json['country_code'];
    return ForumAuthor(
      id: _id(json['id']),
      username: json['username'] as String,
      avatarUri: avatarUri != null && avatarUri.isScheme('https')
          ? avatarUri
          : null,
      countryCode: country is String && country.length == 2 ? country : null,
    );
  }
}
