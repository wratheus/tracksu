import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/_shared/events/widgets/osu_event_row.dart';
import 'package:tracksu/src/_shared/ui/category_picker.dart';
import 'package:tracksu/src/events/bloc/events_bloc.dart';
import 'package:tracksu/src/events/data/events_repository.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Global osu! feed as slivers: player name, action, time; older events
/// load at the end.
final class OsuEventsSlivers extends StatelessWidget {
  const OsuEventsSlivers({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OsuEventsBloc, OsuEventsState>(
        builder: (BuildContext context, OsuEventsState state) {
          final items = state.visible;
          final Widget filter = SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                UiSpace.lg,
                UiSpace.lg,
                UiSpace.lg,
                0,
              ),
              child: OsuCategoryPicker<OsuEventFilter>(
                title: context.t.eventsFilter,
                selected: state.filter,
                groups: const <OsuCategoryGroup<OsuEventFilter>>[
                  OsuCategoryGroup<OsuEventFilter>(
                    options: OsuEventFilter.values,
                  ),
                ],
                icon: (OsuEventFilter filter) => switch (filter) {
                  OsuEventFilter.all => Icons.bolt_rounded,
                  OsuEventFilter.ranks => Icons.emoji_events_outlined,
                  OsuEventFilter.medals => Icons.military_tech_outlined,
                  OsuEventFilter.beatmaps => Icons.library_music_outlined,
                  OsuEventFilter.supporters => Icons.favorite_border_rounded,
                },
                label: (BuildContext context, OsuEventFilter filter) =>
                    switch (filter) {
                      OsuEventFilter.all => context.t.eventsAll,
                      OsuEventFilter.ranks => context.t.eventsRanks,
                      OsuEventFilter.medals => context.t.eventsMedals,
                      OsuEventFilter.beatmaps => context.t.eventsBeatmaps,
                      OsuEventFilter.supporters => context.t.eventsSupporters,
                    },
                onSelected: (OsuEventFilter filter) => context
                    .read<OsuEventsBloc>()
                    .add(OsuEventsFilterSelected(filter)),
              ),
            ),
          );
          if (items == null) {
            return SliverMainAxisGroup(
              slivers: <Widget>[
                filter,
                SliverToBoxAdapter(
                  child: state.failure == null
                      ? UiPageSkeleton.list(label: context.t.eventsLoading)
                      : _Failure(state.failure!),
                ),
              ],
            );
          }
          // A rare group may be absent from the newest page: the auto-load
          // at the end stays visible and keeps fetching older events.
          return SliverMainAxisGroup(
            slivers: <Widget>[
              filter,
              if (state.failure case final OsuEventsFailureKind failure
                  when state.failedOperation == OsuEventsOperation.refresh)
                SliverToBoxAdapter(child: _Failure(failure, keeping: true)),
              if (items.isEmpty && state.cursor == null)
                SliverToBoxAdapter(
                  child: UiContentState.empty(title: context.t.eventsEmpty),
                )
              else if (items.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(UiSpace.lg),
                  sliver: SliverToBoxAdapter(
                    child: UiSurface.card(
                      padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                      child: Column(
                        children: <Widget>[
                          for (int i = 0; i < items.length; i++) ...<Widget>[
                            if (i > 0) const Divider(height: 1, indent: 64),
                            OsuEventRow(
                              key: ValueKey<int>(items[i].id),
                              event: items[i],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              if (state.operation == OsuEventsOperation.loadMore)
                SliverToBoxAdapter(
                  child: UiContentState.loading(title: context.t.eventsLoading),
                )
              else if (state.failure case final OsuEventsFailureKind failure
                  when state.failedOperation == OsuEventsOperation.loadMore)
                SliverToBoxAdapter(
                  child: _Failure(failure, keeping: true, more: true),
                )
              else if (state.cursor case final String cursor
                  when state.operation == null)
                UiSliverAutoLoad(
                  pageKey: cursor,
                  label: context.t.eventsLoading,
                  onLoad: () => context.read<OsuEventsBloc>().add(
                    const OsuEventsMoreRequested(),
                  ),
                ),
            ],
          );
        },
      );
}

final class _Failure extends StatelessWidget {
  const _Failure(this.failure, {this.keeping = false, this.more = false});
  final OsuEventsFailureKind failure;
  final bool keeping;
  final bool more;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      OsuEventsFailureKind.rateLimited => context.t.profileRateLimited,
      OsuEventsFailureKind.connection => context.t.profileConnectionFailed,
      _ => context.t.eventsFailed,
    },
    message: keeping ? context.t.newsKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () => context.read<OsuEventsBloc>().add(
      more ? const OsuEventsMoreRequested() : const OsuEventsRefreshRequested(),
    ),
  );
}
