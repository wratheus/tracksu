import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    show HtmlWidget;
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
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
    this.repliesExpanded = false,
    this.onToggleReplies,
    super.key,
  });
  final Comment comment;
  final CommentAuthor? author;
  final VoidCallback? onOpenAuthor;
  final Future<bool> Function(String url) onOpenLink;
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
                      commentTime(context, comment.createdAt),
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
                  UiText.bodyMedium(
                    context.t.commentsDeleted,
                    secondary: true,
                  ),
                Row(
                  spacing: UiSpace.lg,
                  children: <Widget>[
                    Semantics(
                      label: context.t.commentsVotes(comment.votes),
                      excludeSemantics: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: UiSpace.xs,
                        children: <Widget>[
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            size: 16,
                            color: colors.onSurfaceVariant,
                          ),
                          UiText.labelMedium(
                            NumberFormat.decimalPattern(
                              context.t.localeName,
                            ).format(comment.votes),
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    if (onToggleReplies != null)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: UiSpace.sm,
                          ),
                        ),
                        onPressed: onToggleReplies,
                        icon: Icon(
                          repliesExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 18,
                        ),
                        label: Text(
                          repliesExpanded
                              ? context.t.commentsHideReplies
                              : context.t.commentsReplies(comment.repliesCount),
                        ),
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

/// "5 min ago" up to a week, then the date.
String commentTime(BuildContext context, DateTime at, {DateTime? now}) {
  final Duration age = (now ?? DateTime.now()).toUtc().difference(at);
  if (age.inMinutes < 1) return context.t.commentsJustNow;
  if (age.inHours < 1) return context.t.commentsMinutesAgo(age.inMinutes);
  if (age.inDays < 1) return context.t.commentsHoursAgo(age.inHours);
  if (age.inDays < 7) return context.t.commentsDaysAgo(age.inDays);
  return DateFormat.yMMMd(context.t.localeName).format(at.toLocal());
}
