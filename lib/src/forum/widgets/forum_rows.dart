import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/relative_time.dart';
import 'package:tracksu/src/forum/domain/forum.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Error title for any forum read.
String forumFailureTitle(BuildContext context, ForumFailureKind kind) =>
    switch (kind) {
      ForumFailureKind.notFound => context.t.forumNotFound,
      ForumFailureKind.rateLimited => context.t.profileRateLimited,
      ForumFailureKind.connection => context.t.profileConnectionFailed,
      _ => context.t.forumFailed,
    };

/// One topic card: markers, title, then replies · views · last activity.
final class ForumTopicCard extends StatelessWidget {
  const ForumTopicCard({required this.topic, required this.onTap, super.key});
  final ForumTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String meta = <String>[
      context.t.forumReplies(topic.replies),
      context.t.forumViews(topic.views),
      relativeTime(context, topic.updatedAt),
    ].join(' · ');
    final List<(IconData, String)> markers = <(IconData, String)>[
      if (topic.type == ForumTopicType.announcement)
        (Icons.campaign_outlined, context.t.forumAnnouncement)
      else if (topic.type == ForumTopicType.sticky)
        (Icons.push_pin_outlined, context.t.forumPinned),
      if (topic.isLocked) (Icons.lock_outline_rounded, context.t.forumLocked),
    ];
    return UiSurface.card(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpace.lg,
        vertical: UiSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: UiSpace.xs,
        children: <Widget>[
          if (markers.isNotEmpty)
            Wrap(
              spacing: UiSpace.md,
              children: <Widget>[
                for (final (IconData icon, String label) in markers)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: UiSpace.xs,
                    children: <Widget>[
                      Icon(icon, size: 16, color: colors.tertiary),
                      UiText.labelMedium(label, color: colors.tertiary),
                    ],
                  ),
              ],
            ),
          UiText.titleSmall(
            topic.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          UiText.bodySmall(meta, secondary: true),
        ],
      ),
    );
  }
}
