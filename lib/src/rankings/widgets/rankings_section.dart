import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/widgets/entry_card.dart';
import 'package:tracksu/src/rankings/widgets/filters.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class RankingsSection extends StatelessWidget {
  const RankingsSection({super.key});

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
              const RankingsFilters(),
              UiButton.text(
                onPressed: () =>
                    DepsScope.of(context).appRouter.openSpotlights(context),
                label: context.t.spotlightsTitle,
              ),
              BlocSelector<RankingsBloc, RankingsState, bool>(
                selector: (RankingsState state) =>
                    state is RankingsInitialState ||
                    state is RankingsLoadingState ||
                    (state is RankingsLoadedState && state.operation != null),
                builder: (BuildContext context, bool busy) => UiButton.text(
                  onPressed: busy
                      ? null
                      : () => context.read<RankingsBloc>().add(
                          const RankingsRefreshRequested(),
                        ),
                  icon: Icons.refresh,
                  label: context.t.rankingsRefresh,
                ),
              ),
              UiText.bodySmall(
                context.t.rankingsPositionNotice,
                secondary: true,
              ),
            ],
          ),
        ),
      ),
      BlocBuilder<RankingsBloc, RankingsState>(
        builder: (BuildContext context, RankingsState state) => switch (state) {
          RankingsInitialState() || RankingsLoadingState() =>
            const SliverToBoxAdapter(child: _RankingsProgress()),
          RankingsFailureState(:final failure) => SliverToBoxAdapter(
            child: _RankingsError(failure: failure),
          ),
          RankingsLoadedState() => SliverMainAxisGroup(
            slivers: <Widget>[
              if (state.operation == RankingsOperation.refresh)
                const SliverToBoxAdapter(child: _RankingsProgress()),
              if (state.failedOperation == RankingsOperation.refresh &&
                  state.failure != null)
                SliverToBoxAdapter(
                  child: _RankingsError(
                    failure: state.failure!,
                    failedOperation: state.failedOperation,
                    hasContent: state.items.isNotEmpty,
                  ),
                ),
              if (state.items.isEmpty)
                SliverToBoxAdapter(
                  child: UiContentState.empty(title: context.t.rankingsEmpty),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                sliver: UiSliverCardList(
                  itemCount: state.items.length,
                  itemBuilder: (_, int index) => RankingEntryCard(
                    key: ValueKey<int>(state.items[index].id),
                    entry: state.items[index],
                    type: state.type,
                    onOpen: () => DepsScope.of(context).appRouter.openProfile(
                      context,
                      ProfileParams(
                        user: ProfileUserId(state.items[index].id),
                        ruleset: state.type.ruleset,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.xl),
                  child: switch (state) {
                    RankingsLoadedState(
                      operation: RankingsOperation.loadMore,
                    ) =>
                      const _RankingsProgress(),
                    RankingsLoadedState(
                      failure: final RankingsFailureKind failure,
                      failedOperation: RankingsOperation.loadMore,
                    ) =>
                      _RankingsError(
                        failure: failure,
                        failedOperation: state.failedOperation,
                        hasContent: state.items.isNotEmpty,
                      ),
                    _ when state.failedOperation == RankingsOperation.refresh =>
                      const SizedBox.shrink(),
                    _ when state.nextPage != null => Center(
                      child: UiButton.secondary(
                        onPressed: state.operation != null
                            ? null
                            : () => context.read<RankingsBloc>().add(
                                const RankingsMoreRequested(),
                              ),
                        label: context.t.rankingsLoadMore,
                      ),
                    ),
                    _ when state.nextPage == null && state.items.isNotEmpty =>
                      Center(
                        child: UiText.bodySmall(
                          context.t.rankingsEnd,
                          secondary: true,
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

final class _RankingsProgress extends StatelessWidget {
  const _RankingsProgress();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(UiSpace.lg),
    child: UiLoading(label: context.t.rankingsLoading),
  );
}

final class _RankingsError extends StatelessWidget {
  const _RankingsError({
    required this.failure,
    this.failedOperation,
    this.hasContent = false,
  });
  final RankingsFailureKind failure;
  final RankingsOperation? failedOperation;
  final bool hasContent;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      RankingsFailureKind.cancelled => context.t.rankingsCancelled,
      RankingsFailureKind.notFound => context.t.rankingsNotFound,
      RankingsFailureKind.accessDenied => context.t.rankingsAccessDenied,
      RankingsFailureKind.rateLimited => context.t.profileRateLimited,
      RankingsFailureKind.connection => context.t.profileConnectionFailed,
      RankingsFailureKind.invalidResponse => context.t.rankingsInvalidResponse,
      RankingsFailureKind.unavailable => context.t.rankingsUnavailable,
    },
    message: hasContent ? context.t.rankingsKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () => context.read<RankingsBloc>().add(
      failedOperation == RankingsOperation.loadMore
          ? const RankingsMoreRequested()
          : const RankingsRefreshRequested(),
    ),
  );
}
