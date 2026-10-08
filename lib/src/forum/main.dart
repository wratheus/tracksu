import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/forum/board/bloc/bloc.dart';
import 'package:tracksu/src/forum/data/forum_repository.dart';
import 'package:tracksu/src/forum/topic/bloc/bloc.dart';
import 'package:tracksu/src/forum/widgets/board_screen.dart';
import 'package:tracksu/src/forum/widgets/topic_screen.dart';

/// Route `…/forums/{id}`: one forum (P54).
final class ForumBoardMain extends StatelessWidget {
  const ForumBoardMain({required this.forumId, super.key});
  final int forumId;

  @override
  Widget build(BuildContext context) => BlocProvider<ForumBoardBloc>(
    create: (_) => ForumBoardBloc(
      forumId: forumId,
      cache: DepsScope.of(context).pageCache,
      repository: ForumRepository(
        restClient: DepsScope.of(context).publicRestClient,
      ),
    )..add(const ForumBoardStarted()),
    child: const ForumBoardScreen(),
  );
}

/// Route `…/topic/{id}`: one topic, read from the first post (P54).
final class ForumTopicMain extends StatelessWidget {
  const ForumTopicMain({required this.topicId, super.key});
  final int topicId;

  @override
  Widget build(BuildContext context) => BlocProvider<ForumTopicBloc>(
    create: (_) => ForumTopicBloc(
      topicId: topicId,
      repository: ForumRepository(
        restClient: DepsScope.of(context).publicRestClient,
      ),
    )..add(const ForumTopicStarted()),
    child: const ForumTopicScreen(),
  );
}
