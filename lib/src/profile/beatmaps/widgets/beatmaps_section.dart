import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/beatmaps/bloc/bloc.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_repository.dart';
import 'package:tracksu/src/profile/beatmaps/widgets/beatmap_card.dart';

final class ProfileBeatmapsSection extends StatelessWidget {
  const ProfileBeatmapsSection({super.key});

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
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
                      spacing: 10,
                      children: <Widget>[
                        for (final ProfileBeatmapsType type
                            in ProfileBeatmapsType.values)
                          ChoiceChip(
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
                builder: (BuildContext context, bool busy) => TextButton.icon(
                  onPressed: busy
                      ? null
                      : () => context.read<ProfileBeatmapsBloc>().add(
                          const ProfileBeatmapsRefreshRequested(),
                        ),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.t.beatmapsRefresh),
                ),
              ),
            ],
          ),
        ),
      ),
      BlocBuilder<ProfileBeatmapsBloc, ProfileBeatmapsState>(
        builder: (BuildContext context, ProfileBeatmapsState state) =>
            switch (state) {
              ProfileBeatmapsInitialState() || ProfileBeatmapsLoadingState() =>
                const SliverToBoxAdapter(child: _BeatmapsProgress()),
              ProfileBeatmapsFailureState(:final failure) => SliverToBoxAdapter(
                child: _BeatmapsError(failure: failure),
              ),
              ProfileBeatmapsLoadedState() => SliverMainAxisGroup(
                slivers: <Widget>[
                  if (state.operation == ProfileBeatmapsOperation.refresh)
                    const SliverToBoxAdapter(child: _BeatmapsProgress()),
                  if (state.items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(context.t.beatmapsEmpty),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    sliver: SliverList.builder(
                      itemCount: state.items.length,
                      itemBuilder: (_, int index) => ProfileBeatmapCard(
                        key: ValueKey<int>(state.items[index].id),
                        beatmap: state.items[index],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
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
                        _ when state.nextOffset != null => Center(
                          child: TextButton(
                            onPressed: state.operation != null
                                ? null
                                : () => context.read<ProfileBeatmapsBloc>().add(
                                    const ProfileBeatmapsMoreRequested(),
                                  ),
                            child: Text(context.t.beatmapsLoadMore),
                          ),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      spacing: 10,
      children: <Widget>[
        const CircularProgressIndicator(),
        Text(context.t.beatmapsLoading),
      ],
    ),
  );
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      spacing: 10,
      children: <Widget>[
        if (hasContent) Text(context.t.beatmapsKeepingContent),
        Text(switch (failure) {
          ProfileBeatmapsFailureKind.cancelled => context.t.beatmapsCancelled,
          ProfileBeatmapsFailureKind.notFound => context.t.beatmapsNotFound,
          ProfileBeatmapsFailureKind.accessDenied =>
            context.t.beatmapsAccessDenied,
          ProfileBeatmapsFailureKind.rateLimited =>
            context.t.profileRateLimited,
          ProfileBeatmapsFailureKind.connection =>
            context.t.profileConnectionFailed,
          ProfileBeatmapsFailureKind.invalidResponse =>
            context.t.beatmapsInvalidResponse,
          ProfileBeatmapsFailureKind.unavailable =>
            context.t.beatmapsUnavailable,
        }, textAlign: TextAlign.center),
        TextButton(
          onPressed: () => context.read<ProfileBeatmapsBloc>().add(
            failedOperation == ProfileBeatmapsOperation.loadMore
                ? const ProfileBeatmapsMoreRequested()
                : const ProfileBeatmapsRefreshRequested(),
          ),
          child: Text(context.t.retry),
        ),
      ],
    ),
  );
}
