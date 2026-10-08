import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/forum/board/bloc/bloc.dart';
import 'package:tracksu/src/forum/domain/forum.dart';
import 'package:tracksu/src/forum/widgets/forum_index_slivers.dart';
import 'package:tracksu/src/forum/widgets/forum_rows.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// One forum: description, subforums, pinned topics, then topics by last
/// post; older topics load at the end. Pull down to refresh.
final class ForumBoardScreen extends StatelessWidget {
  const ForumBoardScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ForumBoardBloc, ForumBoardState>(
        builder: (BuildContext context, ForumBoardState state) {
          final ForumBoard? board = state.board;
          final List<ForumTopic>? topics = state.topics;
          final ForumBoardBloc bloc = context.read<ForumBoardBloc>();
          void openTopic(ForumTopic topic) => unawaited(
            DepsScope.of(context).appRouter.openForumTopic(context, topic.id),
          );
          return Scaffold(
            appBar: UiAppBar(
              title: UiText.titleLarge(
                board?.forum.name ?? context.t.forumTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: <Widget>[
                AppBarActions(
                  share: board == null
                      ? null
                      : ShareTarget.forum(board.forum.id, board.forum.name),
                ),
              ],
              bottom: UiAppBarProgressSlot(
                child: UiAppBarProgress(
                  visible:
                      board != null &&
                      state.operation == ForumBoardOperation.refresh,
                  semanticsLabel: context.t.forumLoading,
                ),
              ),
            ),
            body: UiScrollToTop(
              tooltip: context.t.scrollToTop,
              child: SafeArea(
                top: false,
                child: RefreshIndicator(
                  onRefresh: () async =>
                      bloc.add(const ForumBoardRefreshRequested()),
                  child: CustomScrollView(
                    primary: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      if (board == null || topics == null)
                        SliverToBoxAdapter(
                          child: state.failure == null
                              ? UiPageSkeleton.list(
                                  label: context.t.forumLoading,
                                )
                              : UiContentState.error(
                                  title: forumFailureTitle(
                                    context,
                                    state.failure!,
                                  ),
                                  actionLabel: context.t.retry,
                                  onAction: () => bloc.add(
                                    const ForumBoardRefreshRequested(),
                                  ),
                                ),
                        )
                      else ...<Widget>[
                        if (state.failure case final ForumFailureKind failure
                            when state.failedOperation ==
                                ForumBoardOperation.refresh)
                          SliverToBoxAdapter(
                            child: UiContentState.error(
                              title: forumFailureTitle(context, failure),
                              message: context.t.newsKeepingContent,
                              actionLabel: context.t.retry,
                              onAction: () => bloc.add(
                                const ForumBoardRefreshRequested(),
                              ),
                            ),
                          ),
                        if (board.forum.description.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              UiSpace.lg,
                              UiSpace.lg,
                              UiSpace.lg,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: UiText.bodyMedium(
                                board.forum.description,
                                secondary: true,
                              ),
                            ),
                          ),
                        if (board.forum.subforums.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              UiSpace.lg,
                              UiSpace.lg,
                              UiSpace.lg,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: UiListGroup(
                                title: context.t.forumSubforums,
                                children: <Widget>[
                                  for (final ForumNode forum
                                      in board.forum.subforums)
                                    ForumNodeTile(forum: forum),
                                ],
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            UiSpace.lg,
                            UiSpace.xl,
                            UiSpace.lg,
                            UiSpace.md,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: UiText.titleMedium(context.t.forumTopics),
                          ),
                        ),
                        if (board.pinned.isEmpty &&
                            topics.isEmpty &&
                            state.cursor == null)
                          SliverToBoxAdapter(
                            child: UiContentState.empty(
                              title: context.t.forumEmpty,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UiSpace.lg,
                            ),
                            sliver: UiSliverCardList(
                              itemCount: board.pinned.length + topics.length,
                              itemBuilder: (BuildContext context, int index) {
                                final ForumTopic topic =
                                    index < board.pinned.length
                                    ? board.pinned[index]
                                    : topics[index - board.pinned.length];
                                return ForumTopicCard(
                                  key: ValueKey<int>(topic.id),
                                  topic: topic,
                                  onTap: () => openTopic(topic),
                                );
                              },
                            ),
                          ),
                        if (state.operation == ForumBoardOperation.loadMore)
                          SliverToBoxAdapter(
                            child: UiContentState.loading(
                              title: context.t.forumLoading,
                            ),
                          )
                        else if (state.failure
                            case final ForumFailureKind failure
                            when state.failedOperation ==
                                ForumBoardOperation.loadMore)
                          SliverToBoxAdapter(
                            child: UiContentState.error(
                              title: forumFailureTitle(context, failure),
                              actionLabel: context.t.retry,
                              onAction: () =>
                                  bloc.add(const ForumBoardMoreRequested()),
                            ),
                          )
                        else if (state.cursor case final String cursor
                            when state.operation == null)
                          UiSliverAutoLoad(
                            pageKey: cursor,
                            label: context.t.forumLoading,
                            onLoad: () =>
                                bloc.add(const ForumBoardMoreRequested()),
                          ),
                      ],
                      UiSliverScrollToTopSpace(
                        tooltip: context.t.scrollToTop,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}
