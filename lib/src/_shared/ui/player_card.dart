import 'package:flutter/material.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/_shared/ui/avatar_bands.dart';
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
    this.onTeamTap,
    this.supporter = false,
    this.online = false,
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
    this.onTeamTap,
    this.featuredMetric,
    this.onTap,
    this.supporter = false,
    this.online = false,
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
  final VoidCallback? onTeamTap;
  final UiMetric? featuredMetric;
  final VoidCallback? onTap;

  /// osu!supporter: a pink heart right after the username.
  final bool supporter;

  /// Colours the presence dot next to [statusLabel].
  final bool online;
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
              OsuAvatarBands(
                avatar: _profile
                    ? UiAvatar.hero(name: username, image: avatar)
                    : UiAvatar.row(name: username, image: avatar),
                top: _NameBlock(
                  username: username,
                  supporter: supporter,
                  action: nameAction,
                  lines: <Widget>[
                    if (rankLabel != null)
                      UiText.bodySmall(rankLabel!, secondary: true),
                    if (performanceLabel != null)
                      UiText.titleMedium(
                        performanceLabel!,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
                // Flags in the bottom-left corner, presence in the bottom-right.
                bottom: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: UiSpace.sm,
                  children: <Widget>[
                    OsuPlayerFlags(
                      countryCode: countryCode,
                      countryLabel: countryLabel,
                      team: team,
                      onTeamTap: onTeamTap,
                      bottomAligned: true,
                    ),
                    if (statusLabel case final String status)
                      Flexible(
                        child: OsuPresence(online: online, label: status),
                      ),
                  ],
                ),
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

/// Name on the avatar's top edge. Badges and the optional action sit in the
/// top-right corner: the supporter heart beside the action icon. The
/// action's 48 px target overhangs into the card padding instead of pushing
/// the text down.
final class _NameBlock extends StatelessWidget {
  const _NameBlock({
    required this.username,
    required this.supporter,
    required this.action,
    required this.lines,
  });
  final String username;
  final bool supporter;
  final Widget? action;
  final List<Widget> lines;

  // IconButton: 24 px glyph centered in a 48 px target.
  static const double _overhang = (UiShape.minTarget - 24) / 2;
  // OsuSupporterHeart(size: 20) with its xs padding.
  static const double _heart = 20 + 2 * UiSpace.xs;

  @override
  Widget build(BuildContext context) {
    final bool corner = supporter || action != null;
    final Widget text = Padding(
      padding: EdgeInsetsDirectional.only(
        end:
            (supporter ? _heart : 0) +
            (action == null ? 0 : 24 + UiSpace.sm) +
            (corner ? UiSpace.sm : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: UiSpace.xs,
        children: <Widget>[UiText.titleLarge(username, maxLines: 1), ...lines],
      ),
    );
    if (!corner) return text;
    final double inset = action == null ? -UiSpace.xs : -_overhang;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        text,
        PositionedDirectional(
          top: inset,
          end: inset,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (supporter) const OsuSupporterHeart(size: 20),
              if (action case final Widget button) button,
            ],
          ),
        ),
      ],
    );
  }
}
