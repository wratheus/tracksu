import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';
import 'package:tracksu/src/_shared/content/widgets/content_frame.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/navigation/app_links.dart';
import 'package:tracksu/src/_shared/navigation/external_links.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/ui/relative_time.dart';
import 'package:tracksu/src/forum/domain/forum.dart';
import 'package:tracksu/src/forum/topic/bloc/bloc.dart';
import 'package:tracksu/src/forum/widgets/forum_rows.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// A forum topic, read only: posts oldest first in the shared reader
/// (quotes, spoilers, images, links), authors open their profiles; later
/// posts load at the end. Replying needs a signed-in user (after P37).
final class ForumTopicScreen extends StatelessWidget {
  const ForumTopicScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ForumTopicBloc, ForumTopicState>(
        builder: (BuildContext context, ForumTopicState state) {
          final ForumTopic? topic = state.topic;
          final List<ForumPost>? posts = state.posts;
          final ForumTopicBloc bloc = context.read<ForumTopicBloc>();
          return Scaffold(
            appBar: UiAppBar(
              title: UiText.titleLarge(
                topic?.title ?? context.t.forumTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: <Widget>[
                AppBarActions(
                  share: topic == null
                      ? null
                      : ShareTarget.forumTopic(topic.id, topic.title),
                ),
              ],
              bottom: UiAppBarProgressSlot(
                child: UiAppBarProgress(
                  visible:
                      topic != null &&
                      state.operation == ForumTopicOperation.refresh,
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
                      bloc.add(const ForumTopicRefreshRequested()),
                  child: CustomScrollView(
                    primary: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      if (topic == null || posts == null)
                        SliverToBoxAdapter(
                          child: state.failure == null
                              ? UiPageSkeleton.article(
                                  label: context.t.forumLoading,
                                )
                              : UiContentState.error(
                                  title: forumFailureTitle(
                                    context,
                                    state.failure!,
                                  ),
                                  actionLabel: context.t.retry,
                                  onAction: () => bloc.add(
                                    const ForumTopicRefreshRequested(),
                                  ),
                                ),
                        )
                      else ...<Widget>[
                        if (state.failure case final ForumFailureKind failure
                            when state.failedOperation ==
                                ForumTopicOperation.refresh)
                          SliverToBoxAdapter(
                            child: UiContentState.error(
                              title: forumFailureTitle(context, failure),
                              message: context.t.newsKeepingContent,
                              actionLabel: context.t.retry,
                              onAction: () => bloc.add(
                                const ForumTopicRefreshRequested(),
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            UiSpace.lg,
                            UiSpace.lg,
                            UiSpace.lg,
                            UiSpace.sm,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _TopicHeader(topic: topic),
                          ),
                        ),
                        for (final ForumPost post in posts)
                          _PostSlivers(
                            key: ValueKey<int>(post.id),
                            topic: topic,
                            post: post,
                            author: state.authors[post.userId],
                          ),
                        if (state.operation == ForumTopicOperation.loadMore)
                          SliverToBoxAdapter(
                            child: UiContentState.loading(
                              title: context.t.forumLoading,
                            ),
                          )
                        else if (state.failure
                            case final ForumFailureKind failure
                            when state.failedOperation ==
                                ForumTopicOperation.loadMore)
                          SliverToBoxAdapter(
                            child: UiContentState.error(
                              title: forumFailureTitle(context, failure),
                              actionLabel: context.t.retry,
                              onAction: () =>
                                  bloc.add(const ForumTopicMoreRequested()),
                            ),
                          )
                        else if (state.cursor case final String cursor
                            when state.operation == null)
                          UiSliverAutoLoad(
                            pageKey: cursor,
                            label: context.t.forumLoading,
                            onLoad: () =>
                                bloc.add(const ForumTopicMoreRequested()),
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

final class _TopicHeader extends StatelessWidget {
  const _TopicHeader({required this.topic});
  final ForumTopic topic;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: UiSpace.xs,
      children: <Widget>[
        UiText.headlineSmall(topic.title),
        Wrap(
          spacing: UiSpace.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            if (topic.isLocked)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: UiSpace.xs,
                children: <Widget>[
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: colors.tertiary,
                  ),
                  UiText.labelMedium(
                    context.t.forumLocked,
                    color: colors.tertiary,
                  ),
                ],
              ),
            UiText.bodySmall(
              <String>[
                context.t.forumReplies(topic.replies),
                context.t.forumViews(topic.views),
              ].join(' · '),
              secondary: true,
            ),
          ],
        ),
      ],
    );
  }
}

/// Author line, body and a divider for one post.
final class _PostSlivers extends StatelessWidget {
  const _PostSlivers({
    required this.topic,
    required this.post,
    required this.author,
    super.key,
  });
  final ForumTopic topic;
  final ForumPost post;
  final ForumAuthor? author;

  Future<bool> _open(BuildContext context, String url) {
    if (url.startsWith('#')) return Future<bool>.value(true);
    final Uri? uri = PublicWebLink.resolve(url, base: topic.webUri);
    if (uri == null) return Future<bool>.value(true);
    return AppLinks.open(context, uri);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String name = author?.username ?? context.t.commentsUnknownUser;
    final VoidCallback? openAuthor = post.userId > 0
        ? () => unawaited(
            DepsScope.of(context).appRouter.openProfile(
              context,
              ProfileParams.defaultMode(user: ProfileUserId(post.userId)),
            ),
          )
        : null;
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              UiSpace.lg,
              UiSpace.md,
              UiSpace.lg,
              UiSpace.sm,
            ),
            child: Semantics(
              button: openAuthor != null,
              label: name,
              child: InkWell(
                onTap: openAuthor,
                borderRadius: BorderRadius.circular(UiShape.control),
                child: Row(
                  spacing: UiSpace.md,
                  children: <Widget>[
                    ExcludeSemantics(
                      child: UiAvatar.small(
                        name: name,
                        image: AppMedia.image(context, author?.avatarUri),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          UiText.titleSmall(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            color: openAuthor == null ? null : colors.primary,
                          ),
                          UiText.bodySmall(
                            post.editedAt == null
                                ? relativeTime(context, post.createdAt)
                                : '${relativeTime(context, post.createdAt)}'
                                      ' · ${context.t.commentsEdited}',
                            secondary: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (post.document case final document?)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
            sliver: ContentFrame.sliver(
              audioController: DepsScope.of(context).audioPlaybackController,
              mediaPermission: DepsScope.of(context).contentMediaController,
              document: document,
              onOpenLink: (String url) => _open(context, url),
            ),
          )
        else
          SliverToBoxAdapter(
            child: UiContentState.error(
              title: context.t.forumPostUnavailable,
              actionLabel: context.t.contentOriginal,
              onAction: () => unawaited(
                ExternalLinks.openInBrowser(
                  Uri.https('osu.ppy.sh', '/community/forums/posts/${post.id}'),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: UiSpace.md),
            child: Divider(
              height: 1,
              indent: UiSpace.lg,
              endIndent: UiSpace.lg,
            ),
          ),
        ),
      ],
    );
  }
}
