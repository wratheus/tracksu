import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/daily/bloc/bloc.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu/src/daily/widgets/challenge_card.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Home block for today's map. Reads [DailyChallengeBloc] from above.
/// Missing challenge renders nothing; a failure is a quiet notice with
/// retry, so the home page never turns into an error screen because of it.
final class DailyChallengeHomeSection extends StatelessWidget {
  const DailyChallengeHomeSection({required this.onOpen, super.key});

  /// Null while another page is being opened from home.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DailyChallengeBloc, DailyChallengeState>(
        builder: (BuildContext context, DailyChallengeState state) =>
            AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : UiMotion.reveal,
              switchInCurve: UiMotion.revealCurve,
              child: switch (state) {
                DailyChallengeLoading() => Semantics(
                  key: const ValueKey<String>('loading'),
                  label: context.t.dailyTitle,
                  child: const UiSkeleton.block(height: 220),
                ),
                DailyChallengeFailed() => UiNotice(
                  key: const ValueKey<String>('failed'),
                  message: context.t.dailyFailed,
                  tone: UiNoticeTone.warning,
                  actionLabel: context.t.retry,
                  onAction: () => context.read<DailyChallengeBloc>().add(
                    const DailyChallengeRequested(),
                  ),
                ),
                DailyChallengeLoaded(challenge: null) => const SizedBox.shrink(
                  key: ValueKey<String>('none'),
                ),
                DailyChallengeLoaded(
                  challenge: final DailyChallenge challenge,
                ) =>
                  DailyChallengeCard(
                    key: ValueKey<int>(challenge.roomId),
                    challenge: challenge,
                    onTap: onOpen,
                  ),
              },
            ),
      );
}
