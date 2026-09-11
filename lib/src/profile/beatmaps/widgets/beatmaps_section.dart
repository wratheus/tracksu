import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/beatmaps/bloc/bloc.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_repository.dart';
import 'package:tracksu/src/profile/beatmaps/widgets/beatmap_card.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class ProfileBeatmapsSection extends StatelessWidget {
  const ProfileBeatmapsSection({super.key});

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UiSpace.md,
            children: <Widget>[
              Text(
                context.t.beatmapsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              BlocSelector<
                ProfileBeatmapsBloc,
                ProfileBeatmapsState,
                ProfileBeatmapsType
              >(
                selector: (ProfileBeatmapsState state) => state.type,
                builder: (BuildContext context, ProfileBeatmapsType selected) =>
                    Wrap(
                      spacing: UiSpace.md,
                      runSpacing: UiSpace.sm,
                      children: <Widget>[
                        for (final ProfileBeatmapsType type
                            in ProfileBeatmapsType.values)
                          ChoiceChip(
                            avatar: Icon(switch (type) {
                              ProfileBeatmapsType.mostPlayed =>
                                Icons.play_circle_outline,
                              ProfileBeatmapsType.favourite =>
                                Icons.favorite_outline,
                              ProfileBeatmapsType.ranked =>
                                Icons.verified_outlined,
                              ProfileBeatmapsType.pending =>
                                Icons.hourglass_empty,
                              ProfileBeatmapsType.graveyard =>
                                Icons.archive_outlined,
                              ProfileBeatmapsType.loved => Icons.favorite,
                              ProfileBeatmapsType.guest => Icons.group_outlined,
                              ProfileBeatmapsType.nominated =>
                                Icons.workspace_premium_outlined,
                            }),
                            selected: type == selected,
                            label: Text(switch (type) {
                              ProfileBeatmapsType.mostPlayed =>
                                context.t.beatmapsMostPlayed,
                              ProfileBeatmapsType.favourite =>
                                context.t.beatmapsFavourite,
                              ProfileBeatmapsType.ranked =>
                                context.t.beatmapsRanked,
                              ProfileBeatmapsType.pending =>
                                context.t.beatmapsPending,
                              ProfileBeatmapsType.graveyard =>
                                context.t.beatmapsGraveyard,
                              ProfileBeatmapsType.loved =>
                                context.t.beatmapsLoved,
                              ProfileBeatmapsType.guest =>
                                context.t.beatmapsGuest,
                              ProfileBeatmapsType.nominated =>
                                context.t.beatmapsNominated,
                            }),
                            onSelected: (_) => context
                                .read<ProfileBeatmapsBloc>()
                                .add(ProfileBeatmapsTypeSelected(type)),
                          ),
                      ],
                    ),
              ),
              BlocSelector<ProfileBeatmapsBloc, ProfileBeatmapsState, bool>(
                selector: (ProfileBeatmapsState state) =>
                    state is ProfileBeatmapsInitialState ||
                    state is ProfileBeatmapsLoadingState ||
                    (state is ProfileBeatmapsLoadedState &&
                        state.operation != null),
                builder: (BuildContext context, bool busy) => UiButton.text(
                  onPressed: busy
                      ? null
                      : () => context.read<ProfileBeatmapsBloc>().add(
                          const ProfileBeatmapsRefreshRequested(),
                        ),
                  icon: Icons.refresh,
                  label: context.t.beatmapsRefresh,
                ),
              ),
            ],
          ),
        ),
      ),
      BlocBuilder<ProfileBeatmapsBloc, ProfileBeatmapsState>(
        builder: (BuildContext context, ProfileBeatmapsState state) =>
            switch (state) {
              ProfileBeatmapsInitialState() ||
              ProfileBeatmapsLoadingState() => SliverToBoxAdapter(
                child: UiPageSkeleton.list(label: context.t.beatmapsLoading),
              ),
              ProfileBeatmapsFailureState(:final failure) => SliverToBoxAdapter(
                child: _BeatmapsError(failure: failure),
              ),
              ProfileBeatmapsLoadedState() => SliverMainAxisGroup(
                slivers: <Widget>[
                  if (state.operation == ProfileBeatmapsOperation.refresh)
                    const SliverToBoxAdapter(child: _BeatmapsProgress()),
                  if (state.items.isEmpty)
                    SliverToBoxAdapter(
                      child: UiContentState.empty(
                        title: context.t.beatmapsEmpty,
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                    sliver: UiSliverCardList(
                      itemCount: state.items.length,
                      itemBuilder: (_, int index) => ProfileBeatmapCard(
                        key: ValueKey<int>(state.items[index].id),
                        beatmap: state.items[index],
                        onTap: () => unawaited(
                          DepsScope.of(context).appRouter.openBeatmap(
                            context,
                            state.items[index].isBeatmapset
                                ? BeatmapsetParams(state.items[index].id)
                                : BeatmapDifficultyParams(
                                    state.items[index].id,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (state.nextOffset != null &&
                      state.operation == null &&
                      state.failure == null)
                    UiSliverAutoLoad(
                      pageKey: (state.type, state.nextOffset),
                      label: context.t.beatmapsLoading,
                      onLoad: () => context.read<ProfileBeatmapsBloc>().add(
                        const ProfileBeatmapsMoreRequested(),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: UiSpace.xl),
                      child: switch (state) {
                        ProfileBeatmapsLoadedState(
                          operation: ProfileBeatmapsOperation.loadMore,
                        ) =>
                          const _BeatmapsProgress(),
                        ProfileBeatmapsLoadedState(
                          failure: final ProfileBeatmapsFailureKind failure,
                        ) =>
                          _BeatmapsError(
                            failure: failure,
                            failedOperation: state.failedOperation,
                            hasContent: state.items.isNotEmpty,
                          ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ],
              ),
            },
      ),
    ],
  );
}

final class _BeatmapsProgress extends StatelessWidget {
  const _BeatmapsProgress();

  @override
  Widget build(BuildContext context) =>
      UiContentState.loading(title: context.t.beatmapsLoading);
}

final class _BeatmapsError extends StatelessWidget {
  const _BeatmapsError({
    required this.failure,
    this.failedOperation,
    this.hasContent = false,
  });
  final ProfileBeatmapsFailureKind failure;
  final ProfileBeatmapsOperation? failedOperation;
  final bool hasContent;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      ProfileBeatmapsFailureKind.cancelled => context.t.beatmapsCancelled,
      ProfileBeatmapsFailureKind.notFound => context.t.beatmapsNotFound,
      ProfileBeatmapsFailureKind.accessDenied => context.t.beatmapsAccessDenied,
      ProfileBeatmapsFailureKind.rateLimited => context.t.profileRateLimited,
      ProfileBeatmapsFailureKind.connection =>
        context.t.profileConnectionFailed,
      ProfileBeatmapsFailureKind.invalidResponse =>
        context.t.beatmapsInvalidResponse,
      ProfileBeatmapsFailureKind.unavailable => context.t.beatmapsUnavailable,
    },
    message: hasContent ? context.t.beatmapsKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () => context.read<ProfileBeatmapsBloc>().add(
      failedOperation == ProfileBeatmapsOperation.loadMore
          ? const ProfileBeatmapsMoreRequested()
          : const ProfileBeatmapsRefreshRequested(),
    ),
  );
}
