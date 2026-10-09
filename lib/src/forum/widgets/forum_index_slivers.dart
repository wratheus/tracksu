import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/forum/domain/forum.dart';
import 'package:tracksu/src/forum/index/bloc/bloc.dart';
import 'package:tracksu/src/forum/widgets/forum_rows.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Forum sections for the osu! tab: each top-level forum is a group, its
/// subforums are rows (a forum without subforums is its own row).
final class ForumIndexSlivers extends StatelessWidget {
  const ForumIndexSlivers({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ForumIndexBloc, ForumIndexState>(
        builder: (BuildContext context, ForumIndexState state) {
          final List<ForumNode>? forums = state.forums;
          if (forums == null) {
            return SliverToBoxAdapter(
              child: state.failure == null
                  ? UiPageSkeleton.list(label: context.t.forumLoading)
                  : UiContentState.error(
                      title: forumFailureTitle(context, state.failure!),
                      actionLabel: context.t.retry,
                      onAction: () => context.read<ForumIndexBloc>().add(
                        const ForumIndexRefreshRequested(),
                      ),
                    ),
            );
          }
          if (forums.isEmpty) {
            return SliverToBoxAdapter(
              child: UiContentState.empty(title: context.t.forumEmpty),
            );
          }
          return UiSliverReveal(
            sliver: SliverPadding(
              padding: const EdgeInsets.all(UiSpace.lg),
              sliver: SliverList.separated(
                itemCount: forums.length,
                separatorBuilder: (_, _) => const SizedBox(height: UiSpace.lg),
                itemBuilder: (BuildContext context, int index) {
                  final ForumNode group = forums[index];
                  return UiListGroup(
                    title: group.name,
                    children: <Widget>[
                      for (final ForumNode forum
                          in group.subforums.isEmpty
                              ? <ForumNode>[group]
                              : group.subforums)
                        ForumNodeTile(forum: forum),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
}

/// A forum row that opens the forum.
final class ForumNodeTile extends StatelessWidget {
  const ForumNodeTile({required this.forum, super.key});
  final ForumNode forum;

  @override
  Widget build(BuildContext context) => UiTile.navigation(
    title: forum.name,
    subtitle: forum.description.isEmpty ? null : forum.description,
    leading: const UiTileIcon(Icons.forum_outlined),
    onTap: () =>
        unawaited(DepsScope.of(context).appRouter.openForum(context, forum.id)),
  );
}
