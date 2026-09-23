import 'package:flutter/material.dart';
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
        final bool narrow =
            box.maxWidth < 330 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        final ColorScheme colors = Theme.of(context).colorScheme;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: UiSpace.md,
          children: <Widget>[
            UiAvatar.medium(name: username, image: avatar),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: UiSpace.xs,
                children: <Widget>[
                  Row(
                    spacing: UiSpace.sm,
                    children: <Widget>[
                      Flexible(
                        child: UiText.titleMedium(
                          position,
                          color: colors.tertiary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!narrow)
                        Expanded(
                          child: UiText.titleMedium(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  if (narrow)
                    UiText.titleMedium(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  OsuPlayerFlags(
                    countryCode: country,
                    team: team,
                    onTeamTap: onTeamTap,
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: box.maxWidth * 0.34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  UiText.titleLarge(
                    value,
                    color: colors.primary,
                    textAlign: TextAlign.end,
                  ),
                  UiText.labelSmall(
                    valueLabel,
                    secondary: true,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
