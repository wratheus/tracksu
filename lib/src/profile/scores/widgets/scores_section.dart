import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/scores/bloc/bloc.dart';
import 'package:tracksu/src/profile/scores/domain/scores_query.dart';
import 'package:tracksu/src/profile/scores/domain/scores_repository.dart';
import 'package:tracksu/src/profile/scores/widgets/score_card.dart';

final class ProfileScoresSection extends StatelessWidget {
  const ProfileScoresSection({super.key});

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
                context.t.scoresTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              BlocSelector<
                ProfileScoresBloc,
                ProfileScoresState,
                ProfileScoresType
              >(
                selector: (ProfileScoresState state) => state.type,
                builder: (BuildContext context, ProfileScoresType selected) =>
                    Wrap(
                      spacing: 10,
                      children: <Widget>[
                        for (final ProfileScoresType type
                            in ProfileScoresType.values)
                          ChoiceChip(
                            selected: type == selected,
                            label: Text(switch (type) {
                              ProfileScoresType.best => context.t.scoresBest,
                              ProfileScoresType.recent =>
                                context.t.scoresRecent,
                            }),
                            onSelected: (_) => context
                                .read<ProfileScoresBloc>()
                                .add(ProfileScoresTypeSelected(type)),
                          ),
                      ],
                    ),
              ),
              BlocSelector<ProfileScoresBloc, ProfileScoresState, bool>(
                selector: (ProfileScoresState state) =>
                    state is ProfileScoresInitialState ||
                    state is ProfileScoresLoadingState ||
                    (state is ProfileScoresLoadedState &&
                        state.operation != null),
                builder: (BuildContext context, bool busy) => TextButton.icon(
                  onPressed: busy
                      ? null
                      : () => context.read<ProfileScoresBloc>().add(
                          const ProfileScoresRefreshRequested(),
                        ),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.t.scoresRefresh),
                ),
              ),
            ],
          ),
        ),
      ),
      BlocBuilder<ProfileScoresBloc, ProfileScoresState>(
        builder: (BuildContext context, ProfileScoresState state) =>
            switch (state) {
              ProfileScoresInitialState() || ProfileScoresLoadingState() =>
                const SliverToBoxAdapter(child: _ScoresProgress()),
              ProfileScoresFailureState(:final failure) => SliverToBoxAdapter(
                child: _ScoresError(failure: failure),
              ),
              ProfileScoresLoadedState() => SliverMainAxisGroup(
                slivers: <Widget>[
                  if (state.operation == ProfileScoresOperation.refresh)
                    const SliverToBoxAdapter(child: _ScoresProgress()),
                  if (state.items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(context.t.scoresEmpty),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    sliver: SliverList.builder(
                      itemCount: state.items.length,
                      itemBuilder: (_, int index) => ProfileScoreCard(
                        key: ValueKey<int>(state.items[index].id),
                        score: state.items[index],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: switch (state) {
                        ProfileScoresLoadedState(
                          operation: ProfileScoresOperation.loadMore,
                        ) =>
                          const _ScoresProgress(),
                        ProfileScoresLoadedState(
                          failure: final ProfileScoresFailureKind failure,
                        ) =>
                          _ScoresError(
                            failure: failure,
                            failedOperation: state.failedOperation,
                            hasContent: state.items.isNotEmpty,
                          ),
                        _ when state.nextOffset != null => Center(
                          child: TextButton(
                            onPressed: state.operation != null
                                ? null
                                : () => context.read<ProfileScoresBloc>().add(
                                    const ProfileScoresMoreRequested(),
                                  ),
                            child: Text(context.t.scoresLoadMore),
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

final class _ScoresProgress extends StatelessWidget {
  const _ScoresProgress();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      spacing: 10,
      children: <Widget>[
        const CircularProgressIndicator(),
        Text(context.t.scoresLoading),
      ],
    ),
  );
}

final class _ScoresError extends StatelessWidget {
  const _ScoresError({
    required this.failure,
    this.failedOperation,
    this.hasContent = false,
  });
  final ProfileScoresFailureKind failure;
  final ProfileScoresOperation? failedOperation;
  final bool hasContent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      spacing: 10,
      children: <Widget>[
        if (hasContent) Text(context.t.scoresKeepingContent),
        Text(switch (failure) {
          ProfileScoresFailureKind.cancelled => context.t.scoresCancelled,
          ProfileScoresFailureKind.notFound => context.t.scoresNotFound,
          ProfileScoresFailureKind.accessDenied => context.t.scoresAccessDenied,
          ProfileScoresFailureKind.rateLimited => context.t.profileRateLimited,
          ProfileScoresFailureKind.connection =>
            context.t.profileConnectionFailed,
          ProfileScoresFailureKind.invalidResponse =>
            context.t.scoresInvalidResponse,
          ProfileScoresFailureKind.unavailable => context.t.scoresUnavailable,
        }, textAlign: TextAlign.center),
        TextButton(
          onPressed: () => context.read<ProfileScoresBloc>().add(
            failedOperation == ProfileScoresOperation.loadMore
                ? const ProfileScoresMoreRequested()
                : const ProfileScoresRefreshRequested(),
          ),
          child: Text(context.t.retry),
        ),
      ],
    ),
  );
}
