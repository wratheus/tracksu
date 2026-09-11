import 'package:flutter/material.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Display-only profile composition; the caller owns mapping, locale and routes.
final class OsuPlayerCard extends StatelessWidget {
  const OsuPlayerCard.compact({
    required this.username,
    required this.countryCode,
    required this.countryLabel,
    this.avatar,
    this.rankLabel,
    this.performanceLabel,
    this.statusLabel,
    this.onTap,
    this.team,
    super.key,
  }) : _profile = false,
       nameAction = null,
       featuredMetric = null,
       cover = null,
       metrics = const <UiMetric>[];
  const OsuPlayerCard.profile({
    required this.username,
    required this.countryCode,
    required this.countryLabel,
    this.avatar,
    this.cover,
    this.rankLabel,
    this.performanceLabel,
    this.statusLabel,
    this.metrics = const <UiMetric>[],
    this.nameAction,
    this.team,
    this.featuredMetric,
    this.onTap,
    super.key,
  }) : _profile = true;
  final String username;
  final String countryCode;
  final String countryLabel;
  final ImageProvider? avatar;
  final ImageProvider? cover;
  final String? rankLabel;
  final String? performanceLabel;
  final String? statusLabel;
  final List<UiMetric> metrics;
  final Widget? nameAction;
  final ProfileTeam? team;
  final UiMetric? featuredMetric;
  final VoidCallback? onTap;
  final bool _profile;

  @override
  Widget build(BuildContext context) => UiSurface.card(
    onTap: onTap,
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_profile && cover != null) UiCover(image: cover, aspectRatio: 3),
        Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.lg,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: UiSpace.md,
                children: <Widget>[
                  if (_profile)
                    UiAvatar.large(name: username, image: avatar)
                  else
                    UiAvatar.medium(name: username, image: avatar),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: UiSpace.sm,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: UiText.titleLarge(username)),
                            if (nameAction case final Widget action) action,
                          ],
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: UiSpace.sm,
                          runSpacing: UiSpace.xs,
                          children: <Widget>[
                            OsuPlayerFlags(
                              countryCode: countryCode,
                              countryLabel: countryLabel,
                              team: team,
                            ),
                            if (statusLabel != null)
                              UiText.bodySmall(statusLabel!, secondary: true),
                          ],
                        ),
                        if (rankLabel != null) UiText.bodyMedium(rankLabel!),
                        if (performanceLabel != null)
                          UiText.titleMedium(
                            performanceLabel!,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (metrics.isNotEmpty || featuredMetric != null) ...<Widget>[
                const Divider(height: 1),
                if (featuredMetric case final UiMetric metric) metric,
                UiMetricGroup(children: metrics),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
