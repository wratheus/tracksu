import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_core/l10n/localized_count.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/navigation/team_navigation.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/daily/bloc/bloc.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu/src/daily/widgets/challenge_card.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Today's challenge (or a past day) with its leaderboard. Pull to refresh;
/// progress is the app-bar line.
final class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({this.past = false, super.key});

  /// A finished day opened from the history: no link to the history.
  final bool past;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: UiAppBar(
      title: past
          ? BlocSelector<DailyChallengeBloc, DailyChallengeState, DateTime?>(
              selector: (DailyChallengeState state) => switch (state) {
                DailyChallengeLoaded(challenge: final DailyChallenge day) =>
                  day.startsAt,
                _ => null,
              },
              builder: (BuildContext context, DateTime? day) =>
                  UiText.titleLarge(
                    day == null
                        ? context.t.dailyTitle
                        : DateFormat.yMMMMd(context.t.localeName)
                              .format(day.toLocal()),
                  ),
            )
          : UiText.titleLarge(context.t.dailyTitle),
      actions: <Widget>[
        BlocSelector<DailyChallengeBloc, DailyChallengeState, DailyChallenge?>(
          selector: (DailyChallengeState state) => switch (state) {
            DailyChallengeLoaded(challenge: final DailyChallenge day) => day,
            _ => null,
          },
          builder: (BuildContext context, DailyChallenge? day) => AppBarActions(
            share: day == null ? null : ShareTarget.room(day.roomId, day.title),
          ),
        ),
      ],
      bottom: UiAppBarProgressSlot(
        child: BlocSelector<DailyChallengeBloc, DailyChallengeState, bool>(
          selector: (DailyChallengeState state) =>
              state is DailyChallengeLoaded && state.refreshing,
          builder: (BuildContext context, bool busy) => UiAppBarProgress(
            visible: busy,
            semanticsLabel: context.t.dailyTitle,
          ),
        ),
      ),
    ),
    body: UiScrollToTop(
      tooltip: context.t.scrollToTop,
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async => context.read<DailyChallengeBloc>().add(
            const DailyChallengeRequested(),
          ),
          child: CustomScrollView(
            primary: true,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              if (!past)
                SliverPadding(
                  padding: const EdgeInsets.all(UiSpace.lg),
                  sliver: SliverToBoxAdapter(
                    child: UiSurface.card(
                      padding: EdgeInsets.zero,
                      child: UiTile.navigation(
                        leading: const Icon(Icons.history_rounded),
                        title: context.t.dailyHistory,
                        subtitle: context.t.dailyHistoryDescription,
                        onTap: () =>
                            DepsScope.of(context).appRouter
                                .openDailyHistory(context),
                      ),
                    ),
                  ),
                ),
              BlocBuilder<DailyChallengeBloc, DailyChallengeState>(
                builder: (BuildContext context, DailyChallengeState state) =>
                    switch (state) {
                      DailyChallengeLoading() => SliverToBoxAdapter(
                        child: UiPageSkeleton.list(label: context.t.dailyTitle),
                      ),
                      DailyChallengeFailed() => SliverToBoxAdapter(
                        child: DailyChallengeError(
                          onRetry: () => context.read<DailyChallengeBloc>().add(
                            const DailyChallengeRequested(),
                          ),
                        ),
                      ),
                      DailyChallengeLoaded(challenge: null) =>
                        SliverToBoxAdapter(
                          child: UiContentState.empty(
                            title: past
                                ? context.t.dailyPastUnavailable
                                : context.t.dailyNone,
                          ),
                        ),
                      DailyChallengeLoaded(
                        challenge: final DailyChallenge challenge,
                      ) =>
                        _Content(
                          challenge: challenge,
                          state: state,
                          past: past,
                        ),
                    },
              ),
              UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
            ],
          ),
        ),
      ),
    ),
  );
}

final class _Content extends StatelessWidget {
  const _Content({
    required this.challenge,
    required this.state,
    required this.past,
  });
  final DailyChallenge challenge;
  final DailyChallengeLoaded state;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final List<DailyChallengeScore> scores =
        state.scores ?? const <DailyChallengeScore>[];
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(UiSpace.lg),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: UiSpace.md,
              children: <Widget>[
                DailyChallengeCard(challenge: challenge),
                UiButton.secondary(
                  label: context.t.dailyOpenMap,
                  icon: Icons.library_music_outlined,
                  onPressed: () => DepsScope.of(context).appRouter.openBeatmap(
                    context,
                    BeatmapDifficultyParams(
                      challenge.beatmapId,
                      ruleset: challenge.ruleset,
                    ),
                  ),
                ),
                if (state.failure != null)
                  UiNotice(
                    message: context.t.profileShowingPreviousData,
                    tone: UiNoticeTone.warning,
                  ),
                UiText.titleMedium(context.t.dailyLeaderboard),
              ],
            ),
          ),
        ),
        if (scores.isEmpty)
          SliverToBoxAdapter(
            child: UiContentState.empty(title: context.t.rankingsEmpty),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
          sliver: UiSliverCardList(
            itemCount: scores.length,
            itemBuilder: (BuildContext context, int index) {
              final DailyChallengeScore score = scores[index];
              final String locale = context.t.localeName;
              return TeamNavigation(
                key: ValueKey<int>(score.userId),
                teamId: score.team?.id,
                builder: (VoidCallback? openTeam) => OsuRankingRow(
                  username: score.username,
                  country: score.country,
                  team: score.team,
                  onTeamTap: openTeam,
                  avatar: score.avatarUri == null
                      ? null
                      : AppMedia.image(context, score.avatarUri),
                  position:
                      '#${NumberFormat.decimalPattern(locale).format(score.position)}',
                  value: LocalizedCount(
                    score.totalScore,
                    locale: locale,
                  ).compact,
                  valueLabel: NumberFormat.decimalPercentPattern(
                    locale: locale,
                    decimalDigits: 2,
                  ).format(score.accuracy),
                  onTap: () => DepsScope.of(context).appRouter.openProfile(
                    context,
                    ProfileParams(
                      user: ProfileUserId(score.userId),
                      ruleset: challenge.ruleset,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

final class DailyChallengeError extends StatelessWidget {
  const DailyChallengeError({required this.onRetry, super.key});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: context.t.dailyFailed,
    actionLabel: context.t.retry,
    onAction: onRetry,
  );
}
