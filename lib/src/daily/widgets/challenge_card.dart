import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/beatmaps/widgets/beatmap_cover.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Today's map: cover with preview, title, difficulty, ruleset, required
/// mods, time left and participants. Display only; the caller owns taps.
final class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    required this.challenge,
    this.onTap,
    this.now,
    super.key,
  });
  final DailyChallenge challenge;
  final VoidCallback? onTap;

  /// For tests; defaults to the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String locale = context.t.localeName;
    final Duration? left = challenge.endsAt?.difference(
      (now ?? DateTime.now()).toUtc(),
    );
    return UiSurface.card(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BeatmapCover(
            uri: challenge.metadata?.bannerUri ?? challenge.metadata?.coverUri,
            preview: challenge.metadata?.preview,
          ),
          Padding(
            padding: const EdgeInsets.all(UiSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.sm,
              children: <Widget>[
                Row(
                  spacing: UiSpace.sm,
                  children: <Widget>[
                    Icon(Icons.today_rounded, size: 18, color: colors.primary),
                    Expanded(
                      child: UiText.labelLarge(
                        context.t.dailyTitle,
                        color: colors.primary,
                      ),
                    ),
                    if (left != null && !left.isNegative)
                      UiText.bodySmall(
                        context.t.dailyRemaining(
                          context.t.profileDuration(
                            left.inHours,
                            left.inMinutes % 60,
                          ),
                        ),
                        secondary: true,
                      ),
                  ],
                ),
                UiText.titleLarge(challenge.title, maxLines: 2),
                if (challenge.artist.isNotEmpty)
                  UiText.bodyMedium(challenge.artist, secondary: true),
                Row(
                  spacing: UiSpace.sm,
                  children: <Widget>[
                    OsuRulesetIcon(ruleset: challenge.ruleset),
                    OsuStarBadge(
                      stars: challenge.stars,
                      label: NumberFormat.decimalPatternDigits(
                        locale: locale,
                        decimalDigits: 2,
                      ).format(challenge.stars),
                    ),
                    Expanded(
                      child: UiText.bodyMedium(challenge.version, maxLines: 1),
                    ),
                  ],
                ),
                OsuMods(
                  mods: challenge.requiredMods,
                  emptyLabel: context.t.scoresNoMods,
                ),
                if (challenge.participantCount case final int count)
                  UiText.bodySmall(
                    context.t.dailyParticipants(count),
                    secondary: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
