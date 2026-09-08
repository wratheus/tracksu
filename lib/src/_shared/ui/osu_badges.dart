import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Asset paths stay in the host. Unknown/missing codes have a visible fallback.
final class OsuCountryFlag extends StatelessWidget {
  const OsuCountryFlag({required this.code, required this.label, super.key});
  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    final String normalized = code.trim().toUpperCase();
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiSpace.xs),
      child: UiImage(
        image: RegExp(r'^[A-Z]{2}$').hasMatch(normalized)
            ? AssetImage('assets/icon_country_flags/$normalized.png')
            : null,
        width: 28,
        height: 20,
        semanticLabel: label,
        fallbackIcon: Icons.outlined_flag,
      ),
    );
  }
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

/// Acronyms are API content, not translated UI. Unknown future mods remain visible.
final class OsuMods extends StatelessWidget {
  const OsuMods({required this.mods, required this.emptyLabel, super.key});
  final List<String> mods;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: UiSpace.xs,
    runSpacing: UiSpace.xs,
    children: mods.isEmpty
        ? <Widget>[UiBadge.neutral(emptyLabel)]
        : mods
              .map((String mod) => UiBadge.neutral(mod))
              .toList(growable: false),
  );
}
