import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/_shared/ui/osu_colors.dart';
import 'package:tracksu/src/_shared/ui/relative_time.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// One osu! event as on the website: grade, medal or icon, the action text
/// and its time. In a player's profile ([medalsOf] set) the player is
/// implied; in the global feed the player's name leads the row.
final class OsuEventRow extends StatelessWidget {
  const OsuEventRow({required this.event, this.medalsOf, super.key});
  final OsuEvent event;

  /// Profile owner: medal events open their medals page and the name is
  /// omitted. Null in the global feed.
  final int? medalsOf;

  OsuEvent get item => event;
  bool get _global => medalsOf == null;

  String _text(BuildContext context) {
    final String title = item.title ?? '—';
    return switch (item.kind) {
      OsuEventKind.rank => context.t.activityRank(item.rank ?? 0, title),
      OsuEventKind.rankLost => context.t.activityRankLost(title),
      OsuEventKind.achievement => context.t.activityMedal(
        item.medalName ?? '—',
      ),
      OsuEventKind.beatmapPlaycount => context.t.activityPlaycount(
        title,
        item.count ?? 0,
      ),
      OsuEventKind.beatmapsetApprove => context.t.activityApproved(
        title,
        item.approval ?? 'other',
      ),
      OsuEventKind.beatmapsetUpload => context.t.activityUpload(title),
      OsuEventKind.beatmapsetUpdate => context.t.activityUpdate(title),
      OsuEventKind.beatmapsetRevive => context.t.activityRevive(title),
      OsuEventKind.beatmapsetDelete => context.t.activityDelete(title),
      OsuEventKind.userSupportFirst => context.t.activitySupportFirst,
      OsuEventKind.userSupportAgain => context.t.activitySupportAgain,
      OsuEventKind.userSupportGift => context.t.activitySupportGift,
      OsuEventKind.usernameChange => context.t.activityUsernameChange(
        item.previousUsername ?? '—',
        item.username ?? '—',
      ),
    };
  }

  VoidCallback? _onTap(BuildContext context) {
    final router = DepsScope.of(context).appRouter;
    switch (item.kind) {
      case OsuEventKind.rank ||
          OsuEventKind.rankLost ||
          OsuEventKind.beatmapPlaycount:
        final int? id = item.beatmapId;
        if (id == null) return null;
        return () => unawaited(
          router.openBeatmap(
            context,
            BeatmapDifficultyParams(id, ruleset: item.ruleset),
          ),
        );
      case OsuEventKind.beatmapsetApprove ||
          OsuEventKind.beatmapsetUpload ||
          OsuEventKind.beatmapsetUpdate ||
          OsuEventKind.beatmapsetRevive:
        final int? id = item.beatmapsetId;
        if (id == null) return null;
        return () =>
            unawaited(router.openBeatmap(context, BeatmapsetParams(id)));
      case OsuEventKind.achievement when medalsOf != null:
        return () => unawaited(router.openMedals(context, medalsOf!));
      case OsuEventKind.achievement ||
          OsuEventKind.userSupportFirst ||
          OsuEventKind.userSupportAgain ||
          OsuEventKind.userSupportGift ||
          OsuEventKind.usernameChange:
        final int? user = item.userId;
        if (!_global || user == null) return null;
        return () => unawaited(
          router.openProfile(
            context,
            ProfileParams(
              user: ProfileUserId(user),
              ruleset: item.ruleset ?? ProfileRuleset.osu,
            ),
          ),
        );
      case OsuEventKind.beatmapsetDelete:
        return null;
    }
  }

  Widget _leading(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    if (item.kind == OsuEventKind.rank && item.grade != null) {
      return OsuGradeBadge(grade: item.grade!, height: 22);
    }
    if (item.kind == OsuEventKind.achievement &&
        item.medalIcon != null) {
      return UiImage(
        image: AppMedia.image(context, item.medalIcon),
        width: 36,
        height: 36,
        fit: BoxFit.contain,
      );
    }
    final (IconData icon, Color tint) = switch (item.kind) {
      OsuEventKind.rankLost => (
        Icons.trending_down_rounded,
        colors.error,
      ),
      OsuEventKind.beatmapPlaycount => (
        Icons.play_circle_outline_rounded,
        colors.primary,
      ),
      OsuEventKind.beatmapsetApprove => (
        Icons.verified_outlined,
        colors.tertiary,
      ),
      OsuEventKind.beatmapsetUpload ||
      OsuEventKind.beatmapsetUpdate ||
      OsuEventKind.beatmapsetRevive => (
        Icons.library_music_outlined,
        colors.primary,
      ),
      OsuEventKind.beatmapsetDelete => (
        Icons.delete_outline_rounded,
        colors.onSurfaceVariant,
      ),
      OsuEventKind.userSupportFirst ||
      OsuEventKind.userSupportAgain ||
      OsuEventKind.userSupportGift => (
        Icons.favorite_rounded,
        OsuColors.pink,
      ),
      OsuEventKind.usernameChange => (
        Icons.badge_outlined,
        colors.secondary,
      ),
      _ => (Icons.emoji_events_outlined, colors.primary),
    };
    return Icon(icon, color: tint, size: 24);
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onTap = _onTap(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpace.md,
          vertical: UiSpace.sm,
        ),
        child: Row(
          spacing: UiSpace.md,
          children: <Widget>[
            SizedBox(width: 44, child: Center(child: _leading(context))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: <Widget>[
                  if (_global && item.username != null)
                    UiText.labelLarge(item.username!),
                  UiText.bodyMedium(
                    _text(context),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    spacing: UiSpace.xs,
                    children: <Widget>[
                      if (item.ruleset case final ruleset?)
                        SizedBox.square(
                          dimension: 14,
                          child: OsuRulesetIcon(ruleset: ruleset),
                        ),
                      UiText.bodySmall(
                        relativeTime(context, item.createdAt),
                        secondary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
