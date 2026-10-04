import 'package:tracksu/src/comments/domain/comment.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class CommentsRemoteException implements Exception {
  const CommentsRemoteException(this.statusCode);
  final int statusCode;
}

/// `GET /comments` — documented ("Get Comments", CommentBundle). Public for
/// guests; `parent_id=0` limits the page to top-level comments and the
/// server adds up to two levels of their replies as `included_comments`.
final class CommentsRemoteSource {
  const CommentsRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;

  static const int pageSize = 50;

  Future<Map<String, dynamic>> load(
    CommentTarget target, {
    required CommentSort sort,
    required int parentId,
    CommentCursor? cursor,
  }) async {
    final RestResponse response = await _client.get(
      path: '/comments',
      queryParameters: <String, Object?>{
        'commentable_type': target.type.apiValue,
        'commentable_id': target.id,
        'parent_id': parentId,
        'sort': sort.apiValue,
        'limit': pageSize,
        if (cursor != null)
          for (final MapEntry<String, String> entry in cursor.entries)
            'cursor[${entry.key}]': entry.value,
      },
    );
    if (response.statusCode != 200) {
      throw CommentsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}
