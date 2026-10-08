import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/teams/bloc/bloc.dart';
import 'package:tracksu/src/rankings/teams/domain/team_ranking.dart';
import 'package:tracksu/src/rankings/teams/widgets/team_card.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Team ranking list. Ruleset and sort come from the shared filters above
/// it; refresh is pull-to-refresh, progress is the app-bar line.
final class TeamRankingsSection extends StatelessWidget {
  const TeamRankingsSection({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TeamRankingsBloc, TeamRankingsState>(
        builder: (BuildContext context, TeamRankingsState state) {
          final List<TeamRankingEntry>? items = state.items;
          if (items == null) {
            final RankingsFailureKind? failure = state.failure;
            return SliverToBoxAdapter(
              child: failure != null
                  ? _Error(failure: failure)
                  : UiPageSkeleton.list(label: context.t.rankingsTeams),
            );
          }
          return SliverMainAxisGroup(
            slivers: <Widget>[
              if (state.failure case final RankingsFailureKind failure
                  when state.failedOperation == TeamRankingsOperation.refresh)
                SliverToBoxAdapter(
                  child: _Error(failure: failure, keepingContent: true),
                ),
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: UiContentState.empty(title: context.t.rankingsEmpty),
                ),
              SliverPadding(
                key: const ValueKey<String>('team-rankings-list'),
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                sliver: UiSliverCardList(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) =>
                      TeamRankingCard(
                        key: ValueKey<int>(items[index].team.id),
                        entry: items[index],
                        performance: state.performance,
                        onTap: () =>
                            DepsScope.of(context).appRouter
                                .openTeam(context, items[index].team.id),
                      ),
                ),
              ),
              if (state.nextPage != null &&
                  state.operation == null &&
                  state.failure == null)
                UiSliverAutoLoad(
                  pageKey: (state.ruleset, state.performance, state.nextPage),
                  label: context.t.rankingsLoading,
                  onLoad: () => context.read<TeamRankingsBloc>().add(
                    const TeamRankingsMoreRequested(),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.xl),
                  child: switch (state) {
                    TeamRankingsState(
                      operation: TeamRankingsOperation.loadMore,
                    ) =>
                      Padding(
                        padding: const EdgeInsets.all(UiSpace.lg),
                        child: UiLoading(label: context.t.rankingsLoading),
                      ),
                    TeamRankingsState(
                      failure: final RankingsFailureKind failure,
                      failedOperation: TeamRankingsOperation.loadMore,
                    ) =>
                      _Error(failure: failure, more: true),
                    _ when state.nextPage == null && items.isNotEmpty => Center(
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
          );
        },
      );
}

final class _Error extends StatelessWidget {
  const _Error({
    required this.failure,
    this.keepingContent = false,
    this.more = false,
  });
  final RankingsFailureKind failure;
  final bool keepingContent;
  final bool more;

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
    message: keepingContent ? context.t.rankingsKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () => context.read<TeamRankingsBloc>().add(
      more
          ? const TeamRankingsMoreRequested()
          : const TeamRankingsRefreshRequested(),
    ),
  );
}
