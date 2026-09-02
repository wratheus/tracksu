import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/widgets/entry_card.dart';

final class RankingsSection extends StatelessWidget {
  const RankingsSection({super.key});

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
                context.t.rankingsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              BlocSelector<RankingsBloc, RankingsState, RankingsType>(
                selector: (RankingsState state) => state.type,
                builder: (BuildContext context, RankingsType selected) => Wrap(
                  spacing: 10,
                  children: <Widget>[
                    for (final RankingsType type in RankingsType.values)
                      ChoiceChip(
                        selected: type == selected,
                        label: Text(
                          '${type.mode} · ${type.sort == "performance" ? "PP" : context.t.rankingsScore}',
                        ),
                        onSelected: (_) => context.read<RankingsBloc>().add(
                          RankingsTypeSelected(type),
                        ),
                      ),
                  ],
                ),
              ),
              BlocSelector<RankingsBloc, RankingsState, bool>(
                selector: (RankingsState state) =>
                    state is RankingsInitialState ||
                    state is RankingsLoadingState ||
                    (state is RankingsLoadedState && state.operation != null),
                builder: (BuildContext context, bool busy) => TextButton.icon(
                  onPressed: busy
                      ? null
                      : () => context.read<RankingsBloc>().add(
                          const RankingsRefreshRequested(),
                        ),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.t.rankingsRefresh),
                ),
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
              if (state.items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(context.t.rankingsEmpty),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                sliver: SliverList.builder(
                  itemCount: state.items.length,
                  itemBuilder: (_, int index) => RankingEntryCard(
                    key: ValueKey<int>(state.items[index].id),
                    entry: state.items[index],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: switch (state) {
                    RankingsLoadedState(
                      operation: RankingsOperation.loadMore,
                    ) =>
                      const _RankingsProgress(),
                    RankingsLoadedState(
                      failure: final RankingsFailureKind failure,
                    ) =>
                      _RankingsError(
                        failure: failure,
                        failedOperation: state.failedOperation,
                        hasContent: state.items.isNotEmpty,
                      ),
                    _ when state.nextPage != null => Center(
                      child: TextButton(
                        onPressed: state.operation != null
                            ? null
                            : () => context.read<RankingsBloc>().add(
                                const RankingsMoreRequested(),
                              ),
                        child: Text(context.t.rankingsLoadMore),
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
    padding: const EdgeInsets.all(20),
    child: Column(
      spacing: 10,
      children: <Widget>[
        const CircularProgressIndicator(),
        Text(context.t.rankingsLoading),
      ],
    ),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      spacing: 10,
      children: <Widget>[
        if (hasContent) Text(context.t.rankingsKeepingContent),
        Text(switch (failure) {
          RankingsFailureKind.cancelled => context.t.rankingsCancelled,
          RankingsFailureKind.notFound => context.t.rankingsNotFound,
          RankingsFailureKind.accessDenied => context.t.rankingsAccessDenied,
          RankingsFailureKind.rateLimited => context.t.profileRateLimited,
          RankingsFailureKind.connection => context.t.profileConnectionFailed,
          RankingsFailureKind.invalidResponse =>
            context.t.rankingsInvalidResponse,
          RankingsFailureKind.unavailable => context.t.rankingsUnavailable,
        }, textAlign: TextAlign.center),
        TextButton(
          onPressed: () => context.read<RankingsBloc>().add(
            failedOperation == RankingsOperation.loadMore
                ? const RankingsMoreRequested()
                : const RankingsRefreshRequested(),
          ),
          child: Text(context.t.retry),
        ),
      ],
    ),
  );
}
