import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_colors.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

export 'package:tracksu/src/_shared/ui/osu_mods.dart';

/// Asset paths stay in the host. Unknown/missing codes have a visible fallback.
final class OsuCountryFlag extends StatelessWidget {
  const OsuCountryFlag({required this.code, required this.label, super.key});
  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    final String normalized = code.trim().toUpperCase();
    return _OsuFlag(
      image: RegExp(r'^[A-Z]{2}$').hasMatch(normalized)
          ? AssetImage('assets/icon_country_flags/$normalized.png')
          : null,
      label: label,
      icon: Icons.outlined_flag,
    );
  }
}

/// Country and team flags share geometry; absent team data adds no placeholder.
/// By default flags are centered in their line. With [bottomAligned] the
/// visible flags sit on the line's bottom edge (a grid baseline such as an
/// avatar's bottom) while the team's 44 px target grows upward only.
final class OsuPlayerFlags extends StatelessWidget {
  const OsuPlayerFlags({
    this.countryCode,
    this.countryLabel,
    this.team,
    this.onTeamTap,
    this.bottomAligned = false,
    super.key,
  });
  final String? countryCode;
  final String? countryLabel;
  final ProfileTeam? team;
  final VoidCallback? onTeamTap;
  final bool bottomAligned;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: bottomAligned
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.center,
    // A start-aligned team flag has no inner margin, so the gap is explicit.
    spacing: bottomAligned ? UiSpace.sm : UiSpace.xs,
    children: <Widget>[
      if (countryCode case final String code)
        OsuCountryFlag(
          code: code,
          label: countryLabel ?? context.t.profileCountry(code),
        ),
      if (team case final ProfileTeam affiliation)
        OsuTeamFlag(
          team: affiliation,
          onTap: onTeamTap,
          alignment: bottomAligned
              ? AlignmentDirectional.bottomStart
              : AlignmentDirectional.center,
        ),
    ],
  );
}

final class OsuTeamFlag extends StatelessWidget {
  const OsuTeamFlag({
    required this.team,
    this.onTap,
    this.alignment = AlignmentDirectional.center,
    super.key,
  });
  final ProfileTeam team;
  final VoidCallback? onTap;

  /// Where the visible flag sits inside its 44 px hit target.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final Widget flag = _OsuFlag(
      image: team.flagUri == null
          ? null
          : AppMedia.image(context, team.flagUri),
      label: team.name,
      icon: Icons.groups_outlined,
    );
    if (onTap == null) return flag;
    return Semantics(
      button: true,
      label: team.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiSpace.xs),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Align(
            alignment: alignment,
            widthFactor: 1,
            heightFactor: 1,
            child: ExcludeSemantics(child: flag),
          ),
        ),
      ),
    );
  }
}

final class _OsuFlag extends StatelessWidget {
  const _OsuFlag({
    required this.image,
    required this.label,
    required this.icon,
  });
  final ImageProvider? image;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(UiSpace.xs),
      child: UiImage(
        image: image,
        width: 30,
        height: 20,
        semanticLabel: label,
        fallback: Icon(icon, size: 16),
      ),
    ),
  );
}

final class OsuRulesetIcon extends StatelessWidget {
  const OsuRulesetIcon({required this.ruleset, super.key});
  final ProfileRuleset ruleset;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/icon_game_mods/mode_${ruleset.apiValue}.png',
    width: 24,
    height: 24,
    cacheWidth: (24 * MediaQuery.devicePixelRatioOf(context)).ceil(),
    color:
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface,
    semanticLabel: OsuRulesetSelector.label(context, ruleset),
    errorBuilder: (_, _, _) => Icon(
      Icons.sports_esports_outlined,
      size: 24,
      semanticLabel: OsuRulesetSelector.label(context, ruleset),
    ),
  );
}

final class OsuRulesetSelector extends StatelessWidget {
  const OsuRulesetSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });
  final ProfileRuleset selected;
  final ValueChanged<ProfileRuleset>? onChanged;

  static String label(BuildContext context, ProfileRuleset ruleset) =>
      switch (ruleset) {
        ProfileRuleset.osu => context.t.rulesetOsu,
        ProfileRuleset.taiko => context.t.rulesetTaiko,
        ProfileRuleset.fruits => context.t.rulesetFruits,
        ProfileRuleset.mania => context.t.rulesetMania,
      };

  @override
  Widget build(BuildContext context) => UiSegmentedControl<ProfileRuleset>(
    selected: selected,
    onChanged: onChanged,
    segments: ProfileRuleset.values
        .map(
          (ProfileRuleset ruleset) => UiSegment<ProfileRuleset>(
            value: ruleset,
            icon: OsuRulesetIcon(ruleset: ruleset),
            label: label(context, ruleset),
          ),
        )
        .toList(growable: false),
  );
}

final class OsuGradeBadge extends StatelessWidget {
  const OsuGradeBadge({required this.grade, required this.label, super.key});
  final String grade;
  final String label;

  @override
  Widget build(BuildContext context) {
    final String value = grade.toUpperCase();
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (
      Color background,
      Color foreground,
      IconData? icon,
    ) = switch (value) {
      'X' || 'SS' => (colors.primary, colors.onPrimary, Icons.star_rounded),
      'XH' ||
      'SSH' => (colors.tertiary, colors.onTertiary, Icons.auto_awesome_rounded),
      'S' => (colors.secondary, colors.onSecondary, Icons.check_rounded),
      'SH' => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Icons.verified_rounded,
      ),
      'A' => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        Icons.keyboard_double_arrow_up_rounded,
      ),
      'B' => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
        Icons.remove_rounded,
      ),
      'C' || 'D' => (colors.errorContainer, colors.onErrorContainer, null),
      _ => (colors.surfaceContainerHighest, colors.onSurfaceVariant, null),
    };
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Transform.rotate(
        angle: -0.035,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(UiShape.control),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiSpace.sm,
                vertical: UiSpace.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: UiSpace.xs,
                children: <Widget>[
                  if (icon != null) Icon(icon, size: 16, color: foreground),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// osu!supporter tag as on osu.ppy.sh: a soft pink heart with a light top
/// and a faint glow. Tapping explains what it means in a small sheet.
final class OsuSupporterHeart extends StatelessWidget {
  const OsuSupporterHeart({this.size = 18, super.key});
  final double size;

  Future<void> _explain(BuildContext context) => UiModal.info(
    context,
    title: context.t.profileSupporter,
    message: context.t.profileSupporterInfo,
    closeLabel: context.t.actionGotIt,
  );

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.t.profileSupporter,
    child: Semantics(
      button: true,
      label: context.t.profileSupporter,
      excludeSemantics: true,
      child: InkResponse(
        onTap: () => _explain(context),
        radius: size,
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.xs),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: OsuColors.pink.withValues(alpha: .35),
                  blurRadius: size * .6,
                ),
              ],
            ),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[OsuColors.pinkLight, OsuColors.pink],
              ).createShader(bounds),
              child: Icon(
                Icons.favorite_rounded,
                size: size,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Presence dot + text: online in the success hue, offline neutral.
final class OsuPresence extends StatelessWidget {
  const OsuPresence({required this.online, required this.label, super.key});
  final bool online;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    // The status *content* colour: the container shade is too dark for a dot.
    final Color dot = online
        ? Theme.of(context).extension<UiStatusColors>()?.onSuccess ??
              colors.primary
        : colors.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: UiSpace.xs,
      children: <Widget>[
        ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 8),
          ),
        ),
        Flexible(child: UiText.bodySmall(label, secondary: true, maxLines: 1)),
      ],
    );
  }
}

/// Star rating pill in the osu-web difficulty colour.
final class OsuStarBadge extends StatelessWidget {
  const OsuStarBadge({required this.stars, required this.label, super.key});
  final double stars;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color foreground = OsuColors.onStars(stars);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OsuColors.forStars(stars),
        borderRadius: BorderRadius.circular(UiShape.control),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpace.sm,
          vertical: UiSpace.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: <Widget>[
            Icon(Icons.star_rounded, size: 16, color: foreground),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
