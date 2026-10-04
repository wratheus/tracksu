import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localized_count.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/ui/avatar_bands.dart';
import 'package:tracksu/src/rankings/teams/domain/team_ranking.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Team row on the same avatar grid as player rows: the 2:1 team flag in
/// place of the avatar, rank + name + value on its top edge, tag and
/// member count on its bottom edge.
final class TeamRankingCard extends StatelessWidget {
  const TeamRankingCard({
    required this.entry,
    required this.performance,
    required this.onTap,
    super.key,
  });
  final TeamRankingEntry entry;
  final bool performance;
  final VoidCallback? onTap;

  static const double _flagWidth = 96;
  static const double _flagHeight = 48;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String locale = context.t.localeName;
    final LocalizedCount score = LocalizedCount(
      entry.rankedScore,
      locale: locale,
    );
    final String value = performance
        ? NumberFormat.decimalPatternDigits(
            locale: locale,
            decimalDigits: 0,
          ).format(entry.performance)
        : score.compact;
    final Widget card = UiSurface.card(
        onTap: onTap,
        padding: const EdgeInsets.all(UiSpace.md),
        child: OsuAvatarBands(
          avatar: ClipRRect(
            borderRadius: BorderRadius.circular(UiSpace.sm),
            child: UiImage(
              image: entry.team.flagUri == null
                  ? null
                  : AppMedia.image(context, entry.team.flagUri),
              width: _flagWidth,
              height: _flagHeight,
              semanticLabel: entry.team.name,
              fallbackIcon: Icons.groups_outlined,
            ),
          ),
          top: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: UiSpace.sm,
            children: <Widget>[
              UiText.titleMedium(
                '#${NumberFormat.decimalPattern(locale).format(entry.position)}',
                color: colors.tertiary,
                maxLines: 1,
              ),
              Expanded(child: UiText.titleMedium(entry.team.name, maxLines: 1)),
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: value),
                    // Only PP carries a unit; a score needs no caption.
                    if (performance)
                      TextSpan(
                        text: ' PP',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          ),
          bottom: Row(
            spacing: UiSpace.sm,
            children: <Widget>[
              UiBadge.neutral(entry.team.shortName),
              Flexible(
                child: UiText.bodySmall(
                  context.t.teamMembers(entry.memberCount),
                  secondary: true,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
    return performance
        ? card
        : Tooltip(
            message: '${context.t.profileRankedScoreLabel}: ${score.exact}',
            child: card,
          );
  }
}
