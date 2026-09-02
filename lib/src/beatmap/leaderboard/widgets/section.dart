import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/widgets/score_card.dart';
import 'package:tracksu/src/beatmap/leaderboard/bloc/bloc.dart';
import 'package:tracksu/src/beatmap/widgets/failure.dart';

final class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({super.key});
  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            context.t.beatmapLeaderboard,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (BuildContext context, LeaderboardState state) {
          void refresh() => context.read<LeaderboardBloc>().add(
            const LeaderboardLoadRequested(),
          );
          return switch (state) {
            LeaderboardLoadingState() => const SliverToBoxAdapter(
              child: LinearProgressIndicator(),
            ),
            LeaderboardErrorState(:final failure) => SliverToBoxAdapter(
              child: BeatmapFailureView(failure: failure, onRetry: refresh),
            ),
            LeaderboardLoadedState() => SliverMainAxisGroup(
              slivers: <Widget>[
                if (state.refreshing)
                  const SliverToBoxAdapter(child: LinearProgressIndicator()),
                SliverToBoxAdapter(
                  child: TextButton(
                    onPressed: state.refreshing ? null : refresh,
                    child: Text(context.t.beatmapRefreshLeaderboard),
                  ),
                ),
                if (state.failure case final failure?)
                  SliverToBoxAdapter(
                    child: BeatmapFailureView(
                      failure: failure,
                      onRetry: refresh,
                    ),
                  ),
                if (state.entries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(context.t.beatmapNoScores),
                    ),
                  ),
                SliverList.builder(
                  itemCount: state.entries.length,
                  itemBuilder: (BuildContext context, int index) => Padding(
                    key: ValueKey<int>(state.entries[index].score.id),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.t.beatmapLeaderboardPlayer(
                            index + 1,
                            state.entries[index].username ??
                                context.t.beatmapPlayerId(
                                  state.entries[index].score.userId,
                                ),
                          ),
                        ),
                        OsuScoreCard(score: state.entries[index].score),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          };
        },
      ),
    ],
  );
}
