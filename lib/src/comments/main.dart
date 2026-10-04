import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/comments/bloc/bloc.dart';
import 'package:tracksu/src/comments/data/remote_source.dart';
import 'package:tracksu/src/comments/data/repository_impl.dart';
import 'package:tracksu/src/comments/domain/comment.dart';

/// Provides a [CommentsBloc] for [target]. Lazy: nothing is requested until a
/// [CommentsSection] below is built (e.g. scrolled near or its tab opened).
final class CommentsScope extends StatelessWidget {
  const CommentsScope({required this.target, required this.child, super.key});
  final CommentTarget target;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final deps = DepsScope.of(context);
    return BlocProvider<CommentsBloc>(
      key: ValueKey<CommentTarget>(target),
      create: (_) => CommentsBloc(
        target: target,
        repository: CommentsRepositoryImpl(
          source: CommentsRemoteSource(restClient: deps.publicRestClient),
        ),
      ),
      child: child,
    );
  }
}
