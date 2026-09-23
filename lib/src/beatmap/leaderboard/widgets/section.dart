import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/widgets/score_card.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/beatmap/leaderboard/bloc/bloc.dart';
import 'package:tracksu/src/beatmap/widgets/failure.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({this.coverUri, this.preview, super.key});
  final AudioTrack? preview;
  final Uri? coverUri;
  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            UiSpace.lg,
            UiSpace.xl,
            UiSpace.lg,
            UiSpace.sm,
          ),
          child: UiText.titleLarge(context.t.beatmapLeaderboard),
        ),
      ),
      BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (BuildContext context, LeaderboardState state) {
          void refresh() => context.read<LeaderboardBloc>().add(
            const LeaderboardLoadRequested(),
          );
          return switch (state) {
            LeaderboardLoadingState() => SliverToBoxAdapter(
              child: UiPageSkeleton.list(label: context.t.scoresLoading),
            ),
            LeaderboardErrorState(:final failure) => SliverToBoxAdapter(
              child: BeatmapFailureView(failure: failure, onRetry: refresh),
            ),
            LeaderboardLoadedState() => SliverMainAxisGroup(
              slivers: <Widget>[
                if (state.refreshing)
                  const SliverToBoxAdapter(child: LinearProgressIndicator()),
                SliverToBoxAdapter(
                  child: UiButton.text(
                    onPressed: state.refreshing ? null : refresh,
                    label: context.t.beatmapRefreshLeaderboard,
                  ),
                ),
                if (state.failure != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(UiSpace.lg),
                      child: UiNotice(
                        message: context.t.profileShowingPreviousData,
                        tone: UiNoticeTone.warning,
                        actionLabel: context.t.retry,
                        onAction: refresh,
                      ),
                    ),
                  ),
                if (state.entries.isEmpty)
                  SliverToBoxAdapter(
                    child: UiContentState.empty(
                      title: context.t.beatmapNoScores,
                    ),
                  ),
                UiSliverCardList(
                  itemCount: state.entries.length,
                  itemBuilder: (BuildContext context, int index) => Padding(
                    key: ValueKey<int>(state.entries[index].score.id),
                    padding: const EdgeInsets.fromLTRB(
                      UiSpace.lg,
                      0,
                      UiSpace.lg,
                      0,
                    ),
                    child: OsuScoreCard(
                      coverUri: coverUri,
                      preview: preview,
                      playerAvatar: state.entries[index].avatarUri,
                      playerFlags:
                          state.entries[index].countryCode == null &&
                              state.entries[index].team == null
                          ? null
                          : OsuPlayerFlags(
                              countryCode: state.entries[index].countryCode,
                              team: state.entries[index].team,
                            ),
                      score: state.entries[index].score,
                      onOpenPlayer: () =>
                          DepsScope.of(context).appRouter.openProfile(
                            context,
                            ProfileParams(
                              user: ProfileUserId(
                                state.entries[index].score.userId,
                              ),
                              ruleset: state.entries[index].score.ruleset,
                            ),
                          ),
                      playerLabel: context.t.beatmapLeaderboardPlayer(
                        index + 1,
                        state.entries[index].username ??
                            context.t.beatmapPlayerId(
                              state.entries[index].score.userId,
                            ),
                      ),
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
