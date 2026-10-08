import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/audio/widgets/audio_track_player.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// The map of the day as a poster: the cover fills the card, the title sits
/// on it over a dark fade, glass chips name the day and the time left, and
/// the preview plays from the corner. Below: difficulty, mods, players.
/// Display only; the caller owns taps.
final class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    required this.challenge,
    this.onTap,
    this.now,
    this.showDate = false,
    super.key,
  });
  final DailyChallenge challenge;
  final VoidCallback? onTap;

  /// For tests; defaults to the current time.
  final DateTime? now;

  /// A finished day: the chip reads its date instead of "Map of the day"
  /// (the date is too long for the app bar).
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String locale = context.t.localeName;
    final Duration? left = challenge.endsAt?.difference(
      (now ?? DateTime.now()).toUtc(),
    );
    final String label = switch (challenge.startsAt) {
      final DateTime day when showDate => DateFormat.yMMMMd(
        locale,
      ).format(day.toLocal()),
      _ => context.t.dailyTitle,
    };
    return UiSurface.card(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                UiCover(
                  image: AppMedia.image(
                    context,
                    challenge.metadata?.coverUri ??
                        challenge.metadata?.bannerUri,
                  ),
                ),
                // Dark fade so the title reads on any cover.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: <double>[0, 0.35, 1],
                      colors: <Color>[
                        Color(0x66000000),
                        Color(0x00000000),
                        Color(0xD9000000),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: UiSpace.md,
                  left: UiSpace.md,
                  right: UiSpace.md,
                  child: Row(
                    children: <Widget>[
                      _GlassChip(icon: Icons.today_rounded, label: label),
                      const Spacer(),
                      if (left != null && !left.isNegative && !showDate)
                        _GlassChip(
                          icon: Icons.timer_outlined,
                          label: context.t.dailyRemaining(
                            context.t.profileDuration(
                              left.inHours,
                              left.inMinutes % 60,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Title and artist, then the preview on its own line: the
                // player grows to a full-width timeline while it plays, so
                // it needs the card's width (as a Row child it had none and
                // could neither expand nor be paused).
                Positioned(
                  left: UiSpace.lg,
                  right: UiSpace.lg,
                  bottom: UiSpace.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: UiSpace.sm,
                    children: <Widget>[
                      UiText.titleLarge(
                        challenge.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white,
                      ),
                      if (challenge.artist.isNotEmpty)
                        UiText.bodyMedium(
                          challenge.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white70,
                        ),
                      if (challenge.metadata?.preview case final track?)
                        AudioTrackPlayer.overlay(
                          key: ValueKey<Uri>(track.uri),
                          track: track,
                          controller: DepsScope.of(
                            context,
                          ).audioPlaybackController,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(UiSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.md,
              children: <Widget>[
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
                    // Long difficulty names take a second line, not "…".
                    Expanded(
                      child: UiText.bodyMedium(
                        challenge.version,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: UiSpace.md,
                  children: <Widget>[
                    Expanded(
                      child: OsuMods(
                        mods: challenge.requiredMods,
                        emptyLabel: context.t.scoresNoMods,
                      ),
                    ),
                    if (challenge.participantCount case final int count)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: UiSpace.xs,
                        children: <Widget>[
                          Icon(
                            Icons.group_outlined,
                            size: 18,
                            color: colors.onSurfaceVariant,
                          ),
                          UiText.labelLarge(
                            context.t.dailyParticipants(count),
                            secondary: true,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip on the cover: dark glass, light text, chamfered like the controls.
final class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const ShapeDecoration(
      color: Color(0x8C000000),
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UiSpace.sm),
          bottomRight: Radius.circular(UiSpace.sm),
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpace.sm + 2,
        vertical: UiSpace.xs + 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: UiSpace.xs,
        children: <Widget>[
          Icon(icon, size: 16, color: Colors.white),
          UiText.labelLarge(label, color: Colors.white),
        ],
      ),
    ),
  );
}
