import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    show HtmlWidget;
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/ui/relative_time.dart';
import 'package:tracksu/src/comments/domain/comment.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// One comment: avatar and name open the author's profile; text keeps the
/// osu! markdown formatting and links; votes and replies are read-only facts.
final class CommentTile extends StatelessWidget {
  const CommentTile({
    required this.comment,
    required this.author,
    required this.onOpenAuthor,
    required this.onOpenLink,
    this.onOpenOnSite,
    this.repliesExpanded = false,
    this.onToggleReplies,
    super.key,
  });
  final Comment comment;
  final CommentAuthor? author;
  final VoidCallback? onOpenAuthor;
  final Future<bool> Function(String url) onOpenLink;

  /// Opens this comment on osu.ppy.sh, where voting and replying happen:
  /// those endpoints need the `lazer` OAuth scope that only the official
  /// client gets, so a third-party app cannot vote or post.
  final VoidCallback? onOpenOnSite;
  final bool repliesExpanded;

  /// Null when the comment has no replies.
  final VoidCallback? onToggleReplies;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String name =
        author?.username ?? comment.legacyName ?? context.t.commentsUnknownUser;
    final Widget avatar = UiAvatar.small(
      name: name,
      image: AppMedia.image(context, author?.avatarUri),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: UiSpace.md,
        children: <Widget>[
          Semantics(
            button: onOpenAuthor != null,
            label: name,
            excludeSemantics: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onOpenAuthor,
              child: avatar,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.xs,
              children: <Widget>[
                Row(
                  spacing: UiSpace.sm,
                  children: <Widget>[
                    Flexible(
                      child: InkWell(
                        onTap: onOpenAuthor,
                        child: UiText.titleSmall(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: onOpenAuthor == null ? null : colors.primary,
                        ),
                      ),
                    ),
                    if (comment.pinned)
                      Tooltip(
                        message: context.t.commentsPinned,
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: colors.tertiary,
                        ),
                      ),
                    UiText.bodySmall(
                      relativeTime(context, comment.createdAt),
                      secondary: true,
                    ),
                    if (comment.editedAt != null)
                      UiText.bodySmall(
                        context.t.commentsEdited,
                        secondary: true,
                      ),
                  ],
                ),
                if (comment.messageHtml case final String html)
                  SelectionArea(
                    child: HtmlWidget(
                      html,
                      baseUrl: Uri.https('osu.ppy.sh'),
                      onTapUrl: onOpenLink,
                      textStyle: theme.textTheme.bodyMedium,
                    ),
                  )
                else
                  UiText.bodyMedium(context.t.commentsDeleted, secondary: true),
                Wrap(
                  spacing: UiSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    _VotePill(votes: comment.votes, onPressed: onOpenOnSite),
                    if (onOpenOnSite != null)
                      _Action(
                        icon: Icons.reply_rounded,
                        label: context.t.commentsReply,
                        onPressed: onOpenOnSite!,
                      ),
                    if (onToggleReplies != null)
                      _Action(
                        icon: repliesExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        label: repliesExpanded
                            ? context.t.commentsHideReplies
                            : context.t.commentsReplies(comment.repliesCount),
                        onPressed: onToggleReplies!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vote count as a small pill. Tapping it opens the comment on the site,
/// the only place a third-party user can vote (see [CommentTile]).
final class _VotePill extends StatelessWidget {
  const _VotePill({required this.votes, this.onPressed});
  final int votes;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool liked = votes > 0;
    final Color ink = liked ? colors.primary : colors.onSurfaceVariant;
    return Tooltip(
      message: context.t.commentsVoteOnSite,
      child: Semantics(
        button: onPressed != null,
        label: context.t.commentsVotes(votes),
        excludeSemantics: true,
        child: Material(
          color: liked
              ? colors.primaryContainer.withValues(alpha: .55)
              : colors.surfaceContainerHighest,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiSpace.sm + 2,
                vertical: UiSpace.xs + 1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: UiSpace.xs,
                children: <Widget>[
                  Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 15,
                    color: ink,
                  ),
                  UiText.labelMedium(
                    NumberFormat.decimalPattern(context.t.localeName)
                        .format(votes),
                    color: ink,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiet text action under a comment.
final class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    style: TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
  );
}
