import 'package:tracksu/src/_shared/content/domain/content_document.dart';

/// A forum section with its subforums (the API nests up to two levels).
final class ForumNode {
  ForumNode({
    required this.id,
    required this.name,
    required this.description,
    List<ForumNode> subforums = const <ForumNode>[],
  }) : subforums = List<ForumNode>.unmodifiable(subforums);
  final int id;
  final String name;

  /// Plain text; empty when the forum has none.
  final String description;
  final List<ForumNode> subforums;
}

enum ForumTopicType { normal, sticky, announcement }

final class ForumTopic {
  const ForumTopic({
    required this.id,
    required this.forumId,
    required this.title,
    required this.type,
    required this.isLocked,
    required this.postCount,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });
  final int id;
  final int forumId;
  final String title;
  final ForumTopicType type;
  final bool isLocked;

  /// Including the opening post; replies are one fewer.
  final int postCount;
  final int views;
  final DateTime createdAt;

  /// Time of the last post.
  final DateTime updatedAt;
  final int userId;

  bool get pinned => type != ForumTopicType.normal;
  int get replies => postCount > 0 ? postCount - 1 : 0;

  Uri get webUri => Uri.https('osu.ppy.sh', '/community/forums/topics/$id');
}

final class ForumPost {
  const ForumPost({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.editedAt,
    required this.document,
  });
  final int id;
  final int userId;
  final DateTime createdAt;
  final DateTime? editedAt;

  /// Null when the body could not be read safely (too large or malformed).
  final ContentDocument? document;
}

/// Author shown above a post (UserCompact).
final class ForumAuthor {
  const ForumAuthor({
    required this.id,
    required this.username,
    required this.avatarUri,
    required this.countryCode,
  });
  final int id;
  final String username;
  final Uri? avatarUri;
  final String? countryCode;
}

/// One forum page: the forum with its subforums and pinned topics
/// (`GET /forums/{id}`).
final class ForumBoard {
  ForumBoard({required this.forum, required List<ForumTopic> pinned})
    : pinned = List<ForumTopic>.unmodifiable(pinned);
  final ForumNode forum;
  final List<ForumTopic> pinned;

  Uri get webUri => Uri.https('osu.ppy.sh', '/community/forums/${forum.id}');
}

/// Topics by last post, newest first; [cursor] null at the end.
final class ForumTopicsPage {
  ForumTopicsPage({required List<ForumTopic> topics, this.cursor})
    : topics = List<ForumTopic>.unmodifiable(topics);
  final List<ForumTopic> topics;
  final String? cursor;
}

/// Posts oldest first; [cursor] null once the topic is read to the end.
final class ForumPostsPage {
  ForumPostsPage({
    required this.topic,
    required List<ForumPost> posts,
    this.cursor,
  }) : posts = List<ForumPost>.unmodifiable(posts);
  final ForumTopic topic;
  final List<ForumPost> posts;
  final String? cursor;
}

enum ForumFailureKind {
  cancelled,
  notFound,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class ForumFailure implements Exception {
  const ForumFailure(this.kind);
  final ForumFailureKind kind;
}

/// osu.ppy.sh forum links: `/community/forums/{id}`,
/// `/community/forums/topics/{id}` and the legacy `/forum/{id}`,
/// `/forum/t/{id}` redirects.
abstract final class ForumLinks {
  static int? boardId(Uri uri) => switch (uri.pathSegments
      .where((String part) => part.isNotEmpty)
      .toList()) {
    ['community', 'forums', final String id] ||
    ['forum', final String id] => _id(id),
    _ => null,
  };

  static int? topicId(Uri uri) => switch (uri.pathSegments
      .where((String part) => part.isNotEmpty)
      .toList()) {
    ['community', 'forums', 'topics', final String id] ||
    ['forum', 't', final String id] => _id(id),
    _ => null,
  };

  static int? _id(String value) {
    final int? id = int.tryParse(value);
    return id != null && id > 0 && id.toString() == value ? id : null;
  }
}
