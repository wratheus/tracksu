import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localized_count.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/avatar_bands.dart';
import 'package:tracksu/src/rankings/country_stats/domain/country_ranking.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Country row on the same grid as player and team rows: the bundled flag
/// in place of the avatar. Top: rank and the localized name, which may take
/// two lines in a smaller face (long names like "United States of America"
/// stay readable). Bottom: active players and the value with its unit.
final class CountryRankingCard extends StatelessWidget {
  const CountryRankingCard({
    required this.entry,
    required this.name,
    required this.performance,
    required this.onTap,
    super.key,
  });
  final CountryRankingEntry entry;

  /// Localized name; the code until names have loaded.
  final String name;

  /// Show PP (true) or ranked score. osu! orders countries by PP either way.
  final bool performance;

  /// Opens the player table of this country.
  final VoidCallback? onTap;

  static const double _flagWidth = 72;
  static const double _flagHeight = 48;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String locale = context.t.localeName;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final LocalizedCount score = LocalizedCount(
      entry.rankedScore,
      locale: locale,
    );
    final TextStyle? nameStyle = theme.textTheme.titleSmall?.copyWith(
      height: 1.2,
    );
    final Widget card = UiSurface.card(
      onTap: onTap,
      padding: const EdgeInsets.all(UiSpace.md),
      child: OsuAvatarBands(
        avatar: ClipRRect(
          borderRadius: BorderRadius.circular(UiSpace.sm),
          child: Image.asset(
            'assets/icon_country_flags/${entry.country.value}.png',
            width: _flagWidth,
            height: _flagHeight,
            fit: BoxFit.cover,
            cacheWidth: (_flagWidth * dpr).ceil(),
            semanticLabel: name,
            errorBuilder: (_, _, _) => SizedBox(
              width: _flagWidth,
              height: _flagHeight,
              child: Icon(Icons.public, color: colors.onSurfaceVariant),
            ),
          ),
        ),
        top: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text:
                    '#${NumberFormat.decimalPattern(locale).format(entry.position)}  ',
                style: nameStyle?.copyWith(color: colors.tertiary),
              ),
              TextSpan(text: name),
            ],
          ),
          style: nameStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: UiSpace.sm,
          children: <Widget>[
            Expanded(
              child: UiText.bodySmall(
                context.t.rankingsCountryPlayers(entry.activeUsers),
                secondary: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: performance
                        ? NumberFormat.decimalPatternDigits(
                            locale: locale,
                            decimalDigits: 0,
                          ).format(entry.performance)
                        : score.compact,
                  ),
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
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
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
