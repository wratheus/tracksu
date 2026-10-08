import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_shared/navigation/app_links.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';
import 'package:tracksu/src/_shared/ui/page_activity.dart';
import 'package:tracksu/src/comments/bloc/bloc.dart';
import 'package:tracksu/src/comments/domain/comment.dart';
import 'package:tracksu/src/comments/widgets/comment_tile.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Sliver with the comments of one news post or beatmapset: count, sort,
/// pinned first, replies on demand and the next page when the end nears.
/// Reads [CommentsBloc] from above and starts it on first build.
final class CommentsSection extends StatefulWidget {
  const CommentsSection({this.showTitle = true, super.key});

  /// False where the surrounding page already labels the section.
  final bool showTitle;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

typedef _Row = ({Comment? comment, int depth, int? moreFor});

final class _CommentsSectionState extends State<CommentsSection> {
  final Set<int> _expanded = <int>{};

  @override
  void initState() {
    super.initState();
    context.read<CommentsBloc>().add(const CommentsStarted());
  }

  void _toggle(CommentsState state, Comment comment) {
    setState(() {
      if (!_expanded.remove(comment.id)) {
        _expanded.add(comment.id);
        if ((state.children[comment.id]?.isEmpty ?? true) &&
            state.canLoadReplies(comment)) {
          context.read<CommentsBloc>().add(
            CommentsRepliesRequested(comment.id),
          );
        }
      }
    });
  }

  List<_Row> _rows(CommentsState state) {
    final List<_Row> rows = <_Row>[];
    void visit(Comment comment, int depth) {
      rows.add((comment: comment, depth: depth, moreFor: null));
      if (!_expanded.contains(comment.id)) return;
      for (final Comment reply in state.children[comment.id] ?? const []) {
        visit(reply, depth + 1);
      }
      if (state.canLoadReplies(comment) &&
          (state.children[comment.id]?.isNotEmpty ?? false)) {
        rows.add((comment: null, depth: depth + 1, moreFor: comment.id));
      }
    }

    for (final Comment comment in <Comment>[...state.pinned, ...?state.roots]) {
      visit(comment, 0);
    }
    return rows;
  }

  Future<bool> _openLink(String value) async {
    final Uri? uri = PublicWebLink.resolve(
      value,
      base: Uri.https('osu.ppy.sh'),
    );
    if (uri == null) return true;
    // Profile links stay in the app.
    final RegExpMatch? user = RegExp(r'^/(?:users|u)/([1-9][0-9]*)/?$')
        .firstMatch(uri.path);
    if (uri.host == 'osu.ppy.sh' && user != null) {
      _openProfile(int.parse(user.group(1)!));
      return true;
    }
    try {
      if (!await AppLinks.open(context, uri) && mounted) {
        UiFeedback.snack(context, message: context.t.newsLinkFailed);
      }
    } on Object {
      if (mounted) UiFeedback.snack(context, message: context.t.newsLinkFailed);
    }
    return true;
  }

  void _openProfile(int id) => DepsScope.of(context).appRouter.openProfile(
    context,
    ProfileParams(user: ProfileUserId(id), ruleset: ProfileRuleset.osu),
  );

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<CommentsBloc, CommentsState>(
    builder: (BuildContext context, CommentsState state) {
      final List<_Row> rows = _rows(state);
      final bool empty =
          state.roots != null && state.roots!.isEmpty && state.pinned.isEmpty;
      return SliverMainAxisGroup(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              UiSpace.lg,
              UiSpace.lg,
              UiSpace.lg,
              UiSpace.sm,
            ),
            sliver: SliverToBoxAdapter(
              // A page with a PageRefreshScope refreshes comments on pull.
              child: PageRefreshTarget(
                onRefresh: () => context.read<CommentsBloc>().add(
                  const CommentsRefreshRequested(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: UiSpace.md,
                  children: <Widget>[
                    if (widget.showTitle)
                      UiText.titleMedium(
                        state.total == null
                            ? context.t.commentsTitle
                            : context.t.commentsTitleCount(state.total!),
                      ),
                    UiSegmentedControl<CommentSort>(
                      selected: state.sort,
                      segments: <UiSegment<CommentSort>>[
                        UiSegment<CommentSort>(
                          value: CommentSort.newest,
                          label: context.t.commentsSortNew,
                          icon: const Icon(Icons.schedule_rounded),
                        ),
                        UiSegment<CommentSort>(
                          value: CommentSort.oldest,
                          label: context.t.commentsSortOld,
                          icon: const Icon(Icons.history_rounded),
                        ),
                        UiSegment<CommentSort>(
                          value: CommentSort.top,
                          label: context.t.commentsSortTop,
                          icon: const Icon(Icons.thumb_up_alt_outlined),
                        ),
                      ],
                      onChanged: (CommentSort sort) {
                        setState(_expanded.clear);
                        context.read<CommentsBloc>().add(
                          CommentsSortChanged(sort),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.roots == null)
            SliverToBoxAdapter(
              child: state.failure == null
                  ? UiPageSkeleton.list(label: context.t.commentsLoading)
                  : UiContentState.error(
                      title: context.t.commentsFailed,
                      actionLabel: context.t.retry,
                      onAction: () => context.read<CommentsBloc>().add(
                        const CommentsRefreshRequested(),
                      ),
                    ),
            )
          else if (empty)
            SliverToBoxAdapter(
              child: UiContentState.empty(title: context.t.commentsEmpty),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
              sliver: SliverList.builder(
                itemCount: rows.length,
                itemBuilder: (BuildContext context, int index) {
                  final _Row row = rows[index];
                  final Widget child = switch (row) {
                    (comment: final Comment comment, depth: _, moreFor: _) =>
                      CommentTile(
                        key: ValueKey<int>(comment.id),
                        comment: comment,
                        author: comment.userId == null
                            ? null
                            : state.users[comment.userId],
                        onOpenAuthor: comment.userId == null
                            ? null
                            : () => _openProfile(comment.userId!),
                        onOpenLink: _openLink,
                        onOpenOnSite: () => _openLink(
                          'https://osu.ppy.sh/comments/${comment.id}',
                        ),
                        repliesExpanded: _expanded.contains(comment.id),
                        onToggleReplies: comment.repliesCount > 0
                            ? () => _toggle(state, comment)
                            : null,
                      ),
                    (comment: null, depth: _, moreFor: final int? parent) =>
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: state.loadingReplies.contains(parent)
                            ? Padding(
                                padding: const EdgeInsets.all(UiSpace.sm),
                                child: UiLoading(
                                  label: context.t.commentsLoading,
                                ),
                              )
                            : TextButton(
                                onPressed: parent == null
                                    ? null
                                    : () => context.read<CommentsBloc>().add(
                                        CommentsRepliesRequested(parent),
                                      ),
                                child: Text(context.t.commentsMoreReplies),
                              ),
                      ),
                  };
                  // Each thread is one soft card: the root opens it,
                  // the last reply (or the root alone) closes it, and
                  // threads are separated by space instead of lines.
                  final bool first = row.depth == 0;
                  final bool last =
                      index == rows.length - 1 || rows[index + 1].depth == 0;
                  return _ThreadRow(
                    depth: row.depth,
                    first: first,
                    last: last,
                    child: child,
                  );
                },
              ),
            ),
          if (state.roots != null &&
              state.hasMore &&
              state.operation == null &&
              state.failure == null)
            UiSliverAutoLoad(
              pageKey: (state.sort, state.cursor, state.roots!.length),
              label: context.t.commentsLoading,
              onLoad: () => context.read<CommentsBloc>().add(
                const CommentsMoreRequested(),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: UiSpace.xl),
              child: switch (state) {
                CommentsState(operation: CommentsOperation.loadMore) => Padding(
                  padding: const EdgeInsets.all(UiSpace.lg),
                  child: UiLoading(label: context.t.commentsLoading),
                ),
                CommentsState(failure: _?, roots: _?) => Padding(
                  padding: const EdgeInsets.all(UiSpace.lg),
                  child: UiNotice(
                    message: context.t.commentsFailed,
                    tone: UiNoticeTone.warning,
                    actionLabel: context.t.retry,
                    onAction: () => context.read<CommentsBloc>().add(
                      state.failedOperation == CommentsOperation.loadMore
                          ? const CommentsMoreRequested()
                          : const CommentsRefreshRequested(),
                    ),
                  ),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      );
    },
  );
}

/// One row of a thread card. Replies are indented with a thin guide line
/// per level (capped at three) so nesting reads without borders between
/// comments.
final class _ThreadRow extends StatelessWidget {
  const _ThreadRow({
    required this.depth,
    required this.first,
    required this.last,
    required this.child,
  });
  final int depth;
  final bool first;
  final bool last;
  final Widget child;

  static const double _radius = UiShape.card;
  static const double _step = UiSpace.lg;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int levels = depth.clamp(0, 3);
    Widget content = child;
    for (int level = 0; level < levels; level++) {
      content = Padding(
        padding: const EdgeInsetsDirectional.only(start: _step / 2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(
                color: colors.outlineVariant.withValues(alpha: .7),
                width: 1.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: _step / 2),
            child: content,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: last ? UiSpace.md : 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.vertical(
            top: first ? const Radius.circular(_radius) : Radius.zero,
            bottom: last ? const Radius.circular(_radius) : Radius.zero,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            UiSpace.md,
            first ? UiSpace.sm : 0,
            UiSpace.md,
            last ? UiSpace.sm : 0,
          ),
          child: content,
        ),
      ),
    );
  }
}
