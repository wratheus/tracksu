import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/avatar_bands.dart';
import 'package:tracksu/src/rankings/country_stats/domain/country_ranking.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Country row on the same grid as player and team rows: the bundled flag
/// in place of the avatar, rank + name + PP on top, active players below.
final class CountryRankingCard extends StatelessWidget {
  const CountryRankingCard({
    required this.entry,
    required this.name,
    required this.onTap,
    super.key,
  });
  final CountryRankingEntry entry;

  /// Localized name; the code until names have loaded.
  final String name;

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
    return UiSurface.card(
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
            Expanded(
              child: UiText.titleMedium(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: NumberFormat.decimalPatternDigits(
                      locale: locale,
                      decimalDigits: 0,
                    ).format(entry.performance),
                  ),
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
        bottom: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: UiText.bodySmall(
            context.t.rankingsCountryPlayers(entry.activeUsers),
            secondary: true,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
