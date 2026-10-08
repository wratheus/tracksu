import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/events/widgets/osu_event_row.dart';
import 'package:tracksu/src/_shared/ui/page_activity.dart';
import 'package:tracksu/src/profile/activity/bloc/bloc.dart';
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
        ProfileActivityInitialState() ||
        ProfileActivityLoadingState() => SliverToBoxAdapter(
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
                        for (
                          int i = 0;
                          i < loaded.items.length;
                          i++
                        ) ...<Widget>[
                          if (i > 0) const Divider(height: 1, indent: 64),
                          OsuEventRow(event: loaded.items[i], medalsOf: userId),
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
