import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/_shared/ui/osu_colors.dart';
import 'package:tracksu/src/_shared/ui/page_activity.dart';
import 'package:tracksu/src/_shared/ui/relative_time.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/profile/activity/bloc/bloc.dart';
import 'package:tracksu/src/profile/activity/domain/activity.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Profile "Activity" tab: the player's recent events as on osu.ppy.sh
/// (ranks, medals, beatmap uploads, supporter, name changes). Pull to
/// refresh; older events load at the end, up to the API's 100.
final class ProfileActivitySection extends StatelessWidget {
  const ProfileActivitySection({required this.userId, super.key});
  final int userId;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfileActivityBloc, ProfileActivityState>(
        builder: (BuildContext context, ProfileActivityState state) =>
            PageActivityReporter(
              busy:
                  state is ProfileActivityLoadedState &&
                  state.operation == ProfileActivityOperation.refresh,
              child: PageRefreshTarget(
                onRefresh: () => context.read<ProfileActivityBloc>().add(
                  const ProfileActivityRefreshRequested(),
                ),
                child: _body(context, state),
              ),
            ),
      );

  Widget _body(BuildContext context, ProfileActivityState state) =>
      switch (state) {
        ProfileActivityInitialState() || ProfileActivityLoadingState() =>
          SliverToBoxAdapter(
            child: UiPageSkeleton.list(label: context.t.activityLoading),
          ),
        ProfileActivityFailureState() => SliverToBoxAdapter(
          child: _Failure(
            onRetry: () => context.read<ProfileActivityBloc>().add(
              const ProfileActivityRefreshRequested(),
            ),
          ),
        ),
        final ProfileActivityLoadedState loaded => SliverMainAxisGroup(
          slivers: <Widget>[
            if (loaded.items.isEmpty)
              SliverToBoxAdapter(
                child: UiContentState.empty(title: context.t.activityEmpty),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(UiSpace.lg),
                sliver: SliverToBoxAdapter(
                  child: UiSurface.card(
                    padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                    child: Column(
                      children: <Widget>[
                        for (int i = 0; i < loaded.items.length; i++) ...<Widget>[
                          if (i > 0) const Divider(height: 1, indent: 64),
                          _ActivityRow(item: loaded.items[i], userId: userId),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            if (loaded.nextOffset != null &&
                loaded.operation == null &&
                loaded.failure == null)
              UiSliverAutoLoad(
                pageKey: loaded.nextOffset!,
                label: context.t.activityLoading,
                onLoad: () => context.read<ProfileActivityBloc>().add(
                  const ProfileActivityMoreRequested(),
                ),
              ),
            if (loaded.operation == ProfileActivityOperation.loadMore)
              SliverToBoxAdapter(
                child: UiContentState.loading(title: context.t.activityLoading),
              ),
            if (loaded.failure != null)
              SliverToBoxAdapter(
                child: _Failure(
                  onRetry: () => context.read<ProfileActivityBloc>().add(
                    loaded.failedOperation == ProfileActivityOperation.loadMore
                        ? const ProfileActivityMoreRequested()
                        : const ProfileActivityRefreshRequested(),
                  ),
                ),
              ),
          ],
        ),
      };
}

final class _Failure extends StatelessWidget {
  const _Failure({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: context.t.activityFailed,
    actionLabel: context.t.retry,
    onAction: onRetry,
  );
}

final class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item, required this.userId});
  final ProfileActivity item;
  final int userId;

  String _text(BuildContext context) {
    final String title = item.title ?? '—';
    return switch (item.kind) {
      ProfileActivityKind.rank => context.t.activityRank(item.rank ?? 0, title),
      ProfileActivityKind.rankLost => context.t.activityRankLost(title),
      ProfileActivityKind.achievement => context.t.activityMedal(
        item.medalName ?? '—',
      ),
      ProfileActivityKind.beatmapPlaycount => context.t.activityPlaycount(
        title,
        item.count ?? 0,
      ),
      ProfileActivityKind.beatmapsetApprove => context.t.activityApproved(
        title,
        item.approval ?? 'other',
      ),
      ProfileActivityKind.beatmapsetUpload => context.t.activityUpload(title),
      ProfileActivityKind.beatmapsetUpdate => context.t.activityUpdate(title),
      ProfileActivityKind.beatmapsetRevive => context.t.activityRevive(title),
      ProfileActivityKind.beatmapsetDelete => context.t.activityDelete(title),
      ProfileActivityKind.userSupportFirst => context.t.activitySupportFirst,
      ProfileActivityKind.userSupportAgain => context.t.activitySupportAgain,
      ProfileActivityKind.userSupportGift => context.t.activitySupportGift,
      ProfileActivityKind.usernameChange => context.t.activityUsernameChange(
        item.previousUsername ?? '—',
        item.username ?? '—',
      ),
    };
  }

  VoidCallback? _onTap(BuildContext context) {
    final router = DepsScope.of(context).appRouter;
    switch (item.kind) {
      case ProfileActivityKind.rank ||
          ProfileActivityKind.rankLost ||
          ProfileActivityKind.beatmapPlaycount:
        final int? id = item.beatmapId;
        if (id == null) return null;
        return () => unawaited(
          router.openBeatmap(
            context,
            BeatmapDifficultyParams(id, ruleset: item.ruleset),
          ),
        );
      case ProfileActivityKind.beatmapsetApprove ||
          ProfileActivityKind.beatmapsetUpload ||
          ProfileActivityKind.beatmapsetUpdate ||
          ProfileActivityKind.beatmapsetRevive:
        final int? id = item.beatmapsetId;
        if (id == null) return null;
        return () =>
            unawaited(router.openBeatmap(context, BeatmapsetParams(id)));
      case ProfileActivityKind.achievement:
        return () => unawaited(router.openMedals(context, userId));
      case ProfileActivityKind.beatmapsetDelete ||
          ProfileActivityKind.userSupportFirst ||
          ProfileActivityKind.userSupportAgain ||
          ProfileActivityKind.userSupportGift ||
          ProfileActivityKind.usernameChange:
        return null;
    }
  }

  Widget _leading(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    if (item.kind == ProfileActivityKind.rank && item.grade != null) {
      return OsuGradeBadge(grade: item.grade!, height: 22);
    }
    if (item.kind == ProfileActivityKind.achievement &&
        item.medalIcon != null) {
      return UiImage(
        image: AppMedia.image(context, item.medalIcon),
        width: 36,
        height: 36,
        fit: BoxFit.contain,
      );
    }
    final (IconData icon, Color tint) = switch (item.kind) {
      ProfileActivityKind.rankLost => (
        Icons.trending_down_rounded,
        colors.error,
      ),
      ProfileActivityKind.beatmapPlaycount => (
        Icons.play_circle_outline_rounded,
        colors.primary,
      ),
      ProfileActivityKind.beatmapsetApprove => (
        Icons.verified_outlined,
        colors.tertiary,
      ),
      ProfileActivityKind.beatmapsetUpload ||
      ProfileActivityKind.beatmapsetUpdate ||
      ProfileActivityKind.beatmapsetRevive => (
        Icons.library_music_outlined,
        colors.primary,
      ),
      ProfileActivityKind.beatmapsetDelete => (
        Icons.delete_outline_rounded,
        colors.onSurfaceVariant,
      ),
      ProfileActivityKind.userSupportFirst ||
      ProfileActivityKind.userSupportAgain ||
      ProfileActivityKind.userSupportGift => (
        Icons.favorite_rounded,
        OsuColors.pink,
      ),
      ProfileActivityKind.usernameChange => (
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
