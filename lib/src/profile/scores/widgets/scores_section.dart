import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_shared/ui/category_picker.dart';
import 'package:tracksu/src/_shared/ui/page_activity.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/scores/bloc/bloc.dart';
import 'package:tracksu/src/profile/scores/domain/scores_query.dart';
import 'package:tracksu/src/profile/scores/domain/scores_repository.dart';
import 'package:tracksu/src/_shared/scores/widgets/score_card.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class ProfileScoresSection extends StatelessWidget {
  const ProfileScoresSection({super.key});

  static bool _busy(ProfileScoresState state) =>
      state is ProfileScoresInitialState ||
      state is ProfileScoresLoadingState ||
      (state is ProfileScoresLoadedState && state.operation != null);

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          // The tab already says "Scores"; one compact line of controls.
          child: BlocBuilder<ProfileScoresBloc, ProfileScoresState>(
            buildWhen: (ProfileScoresState a, ProfileScoresState b) =>
                a.type != b.type || _busy(a) != _busy(b),
            builder: (BuildContext context, ProfileScoresState state) =>
                // Pull-to-refresh and the app-bar line replace a refresh
                // button and an in-list loader.
                PageActivityReporter(
                  busy:
                      state is ProfileScoresLoadedState &&
                      state.operation == ProfileScoresOperation.refresh,
                  child: PageRefreshTarget(
                    onRefresh: () {
                      final ProfileScoresBloc bloc = context
                          .read<ProfileScoresBloc>();
                      if (!_busy(bloc.state)) {
                        bloc.add(const ProfileScoresRefreshRequested());
                      }
                    },
                    child: OsuCategoryPicker<ProfileScoresType>(
                      title: context.t.scoresCategory,
                      selected: state.type,
                      groups: const <OsuCategoryGroup<ProfileScoresType>>[
                        OsuCategoryGroup<ProfileScoresType>(
                          options: ProfileScoresType.values,
                        ),
                      ],
                      icon: (ProfileScoresType type) => switch (type) {
                        ProfileScoresType.best => Icons.emoji_events_outlined,
                        ProfileScoresType.recent => Icons.history,
                      },
                      label: (BuildContext context, ProfileScoresType type) =>
                          switch (type) {
                            ProfileScoresType.best => context.t.scoresBest,
                            ProfileScoresType.recent => context.t.scoresRecent,
                          },
                      onSelected: (ProfileScoresType type) => context
                          .read<ProfileScoresBloc>()
                          .add(ProfileScoresTypeSelected(type)),
                    ),
                  ),
                ),
          ),
        ),
      ),
      BlocBuilder<ProfileScoresBloc, ProfileScoresState>(
        builder: (BuildContext context, ProfileScoresState state) =>
            switch (state) {
              ProfileScoresInitialState() ||
              ProfileScoresLoadingState() => SliverToBoxAdapter(
                child: UiPageSkeleton.list(label: context.t.scoresLoading),
              ),
              ProfileScoresFailureState(:final failure) => SliverToBoxAdapter(
                child: _ScoresError(failure: failure),
              ),
              ProfileScoresLoadedState() => SliverMainAxisGroup(
                slivers: <Widget>[
                  if (state.items.isEmpty)
                    SliverToBoxAdapter(
                      child: UiContentState.empty(title: context.t.scoresEmpty),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                    sliver: UiSliverCardList(
                      itemCount: state.items.length,
                      itemBuilder: (_, int index) => OsuScoreCard(
                        key: ValueKey<int>(state.items[index].id),
                        score: state.items[index],
                        onTap: () => unawaited(
                          DepsScope.of(context).appRouter.openBeatmap(
                            context,
                            BeatmapDifficultyParams(
                              state.items[index].beatmapId,
                              ruleset: state.items[index].ruleset,
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
                      label: context.t.scoresLoading,
                      onLoad: () => context.read<ProfileScoresBloc>().add(
                        const ProfileScoresMoreRequested(),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: UiSpace.xl),
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
  Widget build(BuildContext context) =>
      UiContentState.loading(title: context.t.scoresLoading);
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
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      ProfileScoresFailureKind.cancelled => context.t.scoresCancelled,
      ProfileScoresFailureKind.notFound => context.t.scoresNotFound,
      ProfileScoresFailureKind.accessDenied => context.t.scoresAccessDenied,
      ProfileScoresFailureKind.rateLimited => context.t.profileRateLimited,
      ProfileScoresFailureKind.connection => context.t.profileConnectionFailed,
      ProfileScoresFailureKind.invalidResponse =>
        context.t.scoresInvalidResponse,
      ProfileScoresFailureKind.unavailable => context.t.scoresUnavailable,
    },
    message: hasContent ? context.t.scoresKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () => context.read<ProfileScoresBloc>().add(
      failedOperation == ProfileScoresOperation.loadMore
          ? const ProfileScoresMoreRequested()
          : const ProfileScoresRefreshRequested(),
    ),
  );
}
