import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/beatmap/bloc/bloc.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';
import 'package:tracksu/src/beatmap/leaderboard/main.dart';
import 'package:tracksu/src/beatmap/widgets/failure.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

final class BeatmapScreen extends StatelessWidget {
  const BeatmapScreen({required this.params, super.key});
  final BeatmapParams params;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t.beatmapTitle)),
    body: SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          BlocBuilder<BeatmapBloc, BeatmapState>(
            builder: (BuildContext context, BeatmapState state) {
              void refresh() =>
                  context.read<BeatmapBloc>().add(const BeatmapLoadRequested());
              return switch (state) {
                BeatmapLoadingState() => const SliverToBoxAdapter(
                  child: LinearProgressIndicator(),
                ),
                BeatmapErrorState(:final failure) => SliverToBoxAdapter(
                  child: BeatmapFailureView(failure: failure, onRetry: refresh),
                ),
                BeatmapLoadedState() => SliverMainAxisGroup(
                  slivers: <Widget>[
                    if (state.refreshing)
                      const SliverToBoxAdapter(
                        child: LinearProgressIndicator(),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: <Widget>[
                            Text(
                              state.details.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(state.details.artist),
                            Text(
                              context.t.beatmapCreator(state.details.creator),
                            ),
                            TextButton(
                              onPressed: state.refreshing ? null : refresh,
                              child: Text(context.t.beatmapRefresh),
                            ),
                            Text(context.t.beatmapDifficulties),
                          ],
                        ),
                      ),
                    ),
                    if (state.failure case final failure?)
                      SliverToBoxAdapter(
                        child: BeatmapFailureView(
                          failure: failure,
                          onRetry: refresh,
                        ),
                      ),
                    if (state.details.difficulties.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(context.t.beatmapNoDifficulties),
                        ),
                      ),
                    SliverList.builder(
                      itemCount: state.details.difficulties.length,
                      itemBuilder: (BuildContext context, int index) {
                        final BeatmapDifficulty difficulty =
                            state.details.difficulties[index];
                        return ListTile(
                          key: ValueKey<int>(difficulty.id),
                          selected: difficulty.id == state.selectedId,
                          title: Text(difficulty.name),
                          subtitle: Text(
                            context.t.beatmapDifficultyInfo(
                              difficulty.ruleset.apiValue,
                              difficulty.stars,
                              difficulty.lengthSeconds,
                            ),
                          ),
                          trailing: difficulty.id == state.selectedId
                              ? const Icon(Icons.check)
                              : null,
                          onTap: state.refreshing
                              ? null
                              : () => context.read<BeatmapBloc>().add(
                                  BeatmapSelected(difficulty.id),
                                ),
                        );
                      },
                    ),
                    if (state.selectedId case final int id)
                      _LeaderboardForSelection(
                        key: ValueKey<int>(id),
                        params: params,
                        state: state,
                        id: id,
                      ),
                  ],
                ),
              };
            },
          ),
        ],
      ),
    ),
  );
}

final class _LeaderboardForSelection extends StatelessWidget {
  const _LeaderboardForSelection({
    required this.params,
    required this.state,
    required this.id,
    super.key,
  });
  final BeatmapParams params;
  final BeatmapLoadedState state;
  final int id;
  @override
  Widget build(BuildContext context) {
    final BeatmapDifficulty difficulty = state.details.difficulties.firstWhere(
      (BeatmapDifficulty d) => d.id == id,
    );
    final ProfileRuleset ruleset = switch (params) {
      BeatmapDifficultyParams(:final ruleset) when params.id == id =>
        ruleset ?? difficulty.ruleset,
      _ => difficulty.ruleset,
    };
    return LeaderboardMain(
      key: ValueKey<(int, ProfileRuleset)>((id, ruleset)),
      query: LeaderboardQuery(beatmapId: id, ruleset: ruleset),
    );
  }
}
