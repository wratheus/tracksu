import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/ui/avatar_bands.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Dense ranking geometry shared by performance and spotlight lists.
final class OsuRankingRow extends StatelessWidget {
  const OsuRankingRow({
    required this.username,
    required this.position,
    required this.value,
    required this.valueLabel,
    required this.country,
    this.avatar,
    this.team,
    this.onTap,
    this.onTeamTap,
    super.key,
  });
  final String username;
  final String position;
  final String value;
  final String valueLabel;
  final String country;
  final ImageProvider? avatar;
  final ProfileTeam? team;
  final VoidCallback? onTap;
  final VoidCallback? onTeamTap;

  @override
  Widget build(BuildContext context) => UiSurface.card(
    onTap: onTap,
    padding: const EdgeInsets.all(UiSpace.md),
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final ColorScheme colors = Theme.of(context).colorScheme;
        final bool narrow =
            box.maxWidth < 330 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        final Widget rank = UiText.titleMedium(
          position,
          color: colors.tertiary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
        final Widget name = UiText.titleMedium(
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
        final Widget flags = OsuPlayerFlags(
          countryCode: country,
          team: team,
          onTeamTap: onTeamTap,
        );
        final Widget metric = UiText.titleLarge(
          value,
          color: colors.primary,
          textAlign: TextAlign.end,
        );
        final Widget label = UiText.labelMedium(
          valueLabel,
          color: colors.primary,
          textAlign: TextAlign.end,
        );
        if (narrow) {
          // Keep player identity readable when long localized labels or enlarged
          // text leave too little width for three columns.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.sm,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: UiSpace.md,
                children: <Widget>[
                  UiAvatar.medium(name: username, image: avatar),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: UiSpace.xs,
                      children: <Widget>[rank, name, flags],
                    ),
                  ),
                ],
              ),
              metric,
              label,
            ],
          );
        }
        final BoxConstraints metricWidth = BoxConstraints(
          maxWidth: box.maxWidth * .34,
        );
        // Two bands on the avatar grid. Top: rank and name on the left, the
        // value with its unit in the top-right corner. Bottom: flags.
        return OsuAvatarBands(
          avatar: UiAvatar.row(name: username, image: avatar),
          top: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: UiSpace.sm,
            children: <Widget>[
              // Not Flexible: a flex child here would split the free space
              // with the name and leave a gap before the value.
              rank,
              Expanded(child: name),
              ConstrainedBox(
                constraints: metricWidth,
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: value),
                      TextSpan(
                        text: ' $valueLabel',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: colors.primary),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottom: Align(
            alignment: AlignmentDirectional.bottomStart,
            child: OsuPlayerFlags(
              countryCode: country,
              team: team,
              onTeamTap: onTeamTap,
              bottomAligned: true,
            ),
          ),
        );
      },
    ),
  );
}
