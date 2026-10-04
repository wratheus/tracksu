import 'package:meta/meta.dart';

/// osu-web `Comment::SORTS`; the wire value goes to `?sort=`.
enum CommentSort {
  newest('new'),
  oldest('old'),
  top('top');

  const CommentSort(this.apiValue);
  final String apiValue;
}

/// Commentable types the app shows comments for.
enum CommentableType {
  newsPost('news_post'),
  beatmapset('beatmapset');

  const CommentableType(this.apiValue);
  final String apiValue;
}

@immutable
final class CommentTarget {
  const CommentTarget(this.type, this.id);
  final CommentableType type;
  final int id;

  @override
  bool operator ==(Object other) =>
      other is CommentTarget && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

@immutable
final class CommentAuthor {
  const CommentAuthor({
    required this.id,
    required this.username,
    this.countryCode,
    this.avatarUri,
  });
  final int id;
  final String username;
  final String? countryCode;
  final Uri? avatarUri;
}

@immutable
final class Comment {
  const Comment({
    required this.id,
    required this.createdAt,
    required this.votes,
    required this.repliesCount,
    this.parentId,
    this.userId,
    this.legacyName,
    this.messageHtml,
    this.editedAt,
    this.deleted = false,
    this.pinned = false,
  });
  final int id;
  final int? parentId;
  final int? userId;

  /// Author name of very old comments that have no account attached.
  final String? legacyName;

  /// Sanitized osu! markdown output; null for deleted comments.
  final String? messageHtml;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool deleted;
  final bool pinned;
  final int votes;
  final int repliesCount;
}

/// Opaque pagination cursor exactly as osu-web returned it.
typedef CommentCursor = Map<String, String>;

/// One `GET /comments` response: [comments] for the requested level
/// (top level, or replies of one parent) and nested replies the server
/// included for them.
@immutable
final class CommentsPage {
  CommentsPage({
    required List<Comment> comments,
    required List<Comment> included,
    required List<Comment> pinned,
    required Map<int, CommentAuthor> users,
    required this.hasMore,
    this.cursor,
    this.total,
  }) : comments = List<Comment>.unmodifiable(comments),
       included = List<Comment>.unmodifiable(included),
       pinned = List<Comment>.unmodifiable(pinned),
       users = Map<int, CommentAuthor>.unmodifiable(users);
  final List<Comment> comments;
  final List<Comment> included;
  final List<Comment> pinned;
  final Map<int, CommentAuthor> users;
  final bool hasMore;
  final CommentCursor? cursor;

  /// All comments of the target, including replies.
  final int? total;
}

enum CommentsFailureKind { connection, unavailable, invalidResponse }

final class CommentsFailure implements Exception {
  const CommentsFailure(this.kind);
  final CommentsFailureKind kind;
}

abstract interface class CommentsRepository {
  /// [parentId] 0 = top level; otherwise replies of that comment.
  Future<CommentsPage> load(
    CommentTarget target, {
    required CommentSort sort,
    int parentId = 0,
    CommentCursor? cursor,
  });
}
