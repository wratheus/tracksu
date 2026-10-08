import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/comments/bloc/bloc.dart';
import 'package:tracksu/src/comments/data/repository_impl.dart';
import 'package:tracksu/src/comments/domain/comment.dart';

Map<String, dynamic> _comment(
  int id, {
  int? parent,
  int replies = 0,
  int votes = 0,
  bool deleted = false,
}) => <String, dynamic>{
  'id': id,
  'parent_id': parent,
  'user_id': 7,
  'pinned': false,
  'replies_count': replies,
  'votes_count': votes,
  'commentable_type': 'news_post',
  'commentable_id': 1,
  'legacy_name': null,
  'created_at': '2026-10-03T12:00:00+00:00',
  'updated_at': '2026-10-03T12:00:00+00:00',
  'deleted_at': deleted ? '2026-10-03T13:00:00+00:00' : null,
  'edited_at': null,
  'edited_by_id': null,
  'message': 'hi',
  'message_html': '<div class="osu-md"><p>hi <img src="https://x.test/a.png" alt="pic"></p></div>',
};

/// Shape of osu-web CommentBundle (`GET /comments`).
Map<String, dynamic> _bundle({
  required List<Map<String, dynamic>> comments,
  List<Map<String, dynamic>> included = const <Map<String, dynamic>>[],
  bool hasMore = false,
}) => <String, dynamic>{
  'comments': comments,
  'included_comments': included,
  'pinned_comments': <Object?>[],
  'has_more': hasMore,
  'has_more_id': null,
  'cursor': hasMore
      ? <String, dynamic>{'created_at': '2026-10-03T12:00:00+00:00', 'id': 3}
      : null,
  'users': <Object?>[
    <String, dynamic>{
      'id': 7,
      'username': 'peppy',
      'avatar_url': 'https://a.ppy.sh/7',
      'country_code': 'AU',
    },
  ],
  'user_votes': <Object?>[],
  'user_follow': false,
  'sort': 'new',
  'top_level_count': comments.length,
  'total': 12,
  'commentable_meta': <Object?>[],
};

final class _Repository implements CommentsRepository {
  final List<({int parentId, CommentCursor? cursor})> calls = [];
  final Map<int, List<CommentsPage>> pages = <int, List<CommentsPage>>{};

  @override
  Future<CommentsPage> load(
    CommentTarget target, {
    required CommentSort sort,
    int parentId = 0,
    CommentCursor? cursor,
  }) async {
    calls.add((parentId: parentId, cursor: cursor));
    return pages[parentId]!.removeAt(0);
  }
}

void main() {
  test('bundle decodes comments, replies, users and cursor', () {
    final CommentsPage page = CommentsRepositoryImpl.decode(
      _bundle(
        comments: <Map<String, dynamic>>[_comment(1, replies: 2, votes: 5)],
        included: <Map<String, dynamic>>[_comment(2, parent: 1)],
        hasMore: true,
      ),
    );
    expect(page.comments.single.votes, 5);
    expect(page.comments.single.repliesCount, 2);
    expect(page.included.single.parentId, 1);
    expect(page.users[7]?.username, 'peppy');
    expect(page.cursor, <String, String>{
      'created_at': '2026-10-03T12:00:00+00:00',
      'id': '3',
    });
    expect(page.total, 12);
    // Comment images become links; nothing is fetched from a comment.
    expect(page.comments.single.messageHtml, isNot(contains('<img')));
    expect(
      page.comments.single.messageHtml,
      contains('href="https://x.test/a.png"'),
    );
  });

  test('deleted comments keep their place without text', () {
    final Comment comment = CommentsRepositoryImpl.decode(
      _bundle(comments: <Map<String, dynamic>>[_comment(1, deleted: true)]),
    ).comments.single;
    expect(comment.deleted, isTrue);
    expect(comment.messageHtml, isNull);
  });

  test('pages append, replies load per parent without duplicates', () async {
    final _Repository repository = _Repository()
      ..pages[0] = <CommentsPage>[
        CommentsRepositoryImpl.decode(
          _bundle(
            comments: <Map<String, dynamic>>[_comment(1, replies: 3)],
            included: <Map<String, dynamic>>[_comment(2, parent: 1)],
            hasMore: true,
          ),
        ),
        CommentsRepositoryImpl.decode(
          _bundle(comments: <Map<String, dynamic>>[_comment(4)]),
        ),
      ]
      ..pages[1] = <CommentsPage>[
        CommentsRepositoryImpl.decode(
          _bundle(
            comments: <Map<String, dynamic>>[
              _comment(2, parent: 1),
              _comment(3, parent: 1),
            ],
          ),
        ),
      ];
    final CommentsBloc bloc = CommentsBloc(
      repository: repository,
      target: const CommentTarget(CommentableType.newsPost, 1),
    );
    bloc.add(const CommentsStarted());
    await bloc.stream.firstWhere((CommentsState s) => s.roots != null);
    expect(bloc.state.canLoadReplies(bloc.state.roots!.single), isTrue);

    bloc.add(const CommentsMoreRequested());
    await bloc.stream.firstWhere(
      (CommentsState s) => s.roots!.length == 2 && !s.busy,
    );
    expect(repository.calls[1].cursor?['id'], '3');
    expect(bloc.state.hasMore, isFalse);

    bloc.add(const CommentsRepliesRequested(1));
    await bloc.stream.firstWhere(
      (CommentsState s) => s.repliesDone.contains(1),
    );
    expect(bloc.state.children[1]!.map((Comment c) => c.id), <int>[2, 3]);
    await bloc.close();
  });
}
