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
      // Where we are, not what: a past day's date sits on its card.
      title: UiText.titleLarge(
        context.t.dailyTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
                        UiSliverReveal(
                          sliver: _Content(
                            challenge: challenge,
                            state: state,
                            past: past,
                          ),
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
                DailyChallengeCard(challenge: challenge, showDate: past),
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
                UiText.titleMedium(
                  past
                      ? context.t.dailyLeaderboardFinal
                      : context.t.dailyLeaderboard,
                ),
              ],
            ),
          ),
        ),
        if (scores.isEmpty)
          SliverToBoxAdapter(
            child: UiContentState.empty(title: context.t.rankingsEmpty),
          )
        else
          // The day's winners stand on a podium; the rest follow as rows.
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              UiSpace.lg,
              0,
              UiSpace.lg,
              UiSpace.md,
            ),
            sliver: SliverToBoxAdapter(
              child: _Podium(
                scores: scores.take(3).toList(growable: false),
                onOpen: (DailyChallengeScore score) =>
                    DepsScope.of(context).appRouter.openProfile(
                      context,
                      ProfileParams(
                        user: ProfileUserId(score.userId),
                        ruleset: challenge.ruleset,
                      ),
                    ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
          sliver: UiSliverCardList(
            itemCount: scores.length > 3 ? scores.length - 3 : 0,
            itemBuilder: (BuildContext context, int index) {
              final DailyChallengeScore score = scores[index + 3];
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

/// Top three as a podium: second · first · third, the winner raised, each
/// with a metal accent (gold, silver, bronze), avatar, name and score.
final class _Podium extends StatelessWidget {
  const _Podium({required this.scores, required this.onOpen});
  final List<DailyChallengeScore> scores;
  final ValueChanged<DailyChallengeScore> onOpen;

  static const List<Color> _metals = <Color>[
    Color(0xFFE8B84A),
    Color(0xFFB9C3CE),
    Color(0xFFD08A5C),
  ];
  static const List<double> _steps = <double>[64, 44, 30];

  @override
  Widget build(BuildContext context) {
    final List<int> order = <int>[
      if (scores.length > 1) 1,
      0,
      if (scores.length > 2) 2,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: UiSpace.sm,
      children: <Widget>[
        for (final int index in order)
          Expanded(
            child: _Step(
              score: scores[index],
              metal: _metals[index],
              step: _steps[index],
              winner: index == 0,
              onTap: () => onOpen(scores[index]),
            ),
          ),
      ],
    );
  }
}

final class _Step extends StatelessWidget {
  const _Step({
    required this.score,
    required this.metal,
    required this.step,
    required this.winner,
    required this.onTap,
  });
  final DailyChallengeScore score;
  final Color metal;
  final double step;
  final bool winner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String locale = context.t.localeName;
    final double avatar = winner ? 72 : 56;
    return Semantics(
      button: true,
      label: '#${score.position} ${score.username}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiShape.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: UiSpace.xs,
          children: <Widget>[
            if (winner)
              Icon(Icons.emoji_events_rounded, color: metal, size: 22),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UiShape.card),
                ),
                color: metal,
              ),
              child: SizedBox.square(
                dimension: avatar,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(UiShape.card - 3),
                  child: UiImage(
                    image: score.avatarUri == null
                        ? null
                        : AppMedia.image(context, score.avatarUri),
                    width: avatar,
                    height: avatar,
                  ),
                ),
              ),
            ),
            UiText.titleSmall(
              score.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            UiText.labelMedium(
              LocalizedCount(score.totalScore, locale: locale).compact,
              color: metal,
            ),
            // The step: chamfered block with the place number.
            Container(
              height: step,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(UiSpace.sm),
                    topRight: Radius.circular(UiSpace.sm),
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    metal.withValues(alpha: 0.55),
                    metal.withValues(alpha: 0.12),
                  ],
                ),
              ),
              child: UiText.titleLarge(
                '${score.position}',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
