import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

enum _BadgeTone { neutral, accent, positive, warning, negative }

/// A non-interactive label. Use themed ChoiceChip/FilterChip for selections.
final class UiBadge extends StatelessWidget {
  const UiBadge.neutral(this.label, {this.icon, super.key})
    : _tone = _BadgeTone.neutral;
  const UiBadge.accent(this.label, {this.icon, super.key})
    : _tone = _BadgeTone.accent;
  const UiBadge.positive(this.label, {this.icon, super.key})
    : _tone = _BadgeTone.positive;
  const UiBadge.warning(this.label, {this.icon, super.key})
    : _tone = _BadgeTone.warning;
  const UiBadge.negative(this.label, {this.icon, super.key})
    : _tone = _BadgeTone.negative;
  final String label;
  final IconData? icon;
  final _BadgeTone _tone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final UiStatusColors? status = theme.extension<UiStatusColors>();
    final (Color background, Color foreground) = switch (_tone) {
      _BadgeTone.neutral => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
      _BadgeTone.accent => (colors.primaryContainer, colors.onPrimaryContainer),
      _BadgeTone.positive => (
        status?.success ?? colors.secondaryContainer,
        status?.onSuccess ?? colors.onSecondaryContainer,
      ),
      _BadgeTone.warning => (
        status?.warning ?? colors.tertiaryContainer,
        status?.onWarning ?? colors.onTertiaryContainer,
      ),
      _BadgeTone.negative => (colors.errorContainer, colors.onErrorContainer),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(UiShape.control),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpace.sm,
          vertical: UiSpace.xs,
        ),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              if (icon != null)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: UiSpace.xs),
                    child: Icon(icon, size: 16, color: foreground),
                  ),
                ),
              TextSpan(text: label),
            ],
          ),
          style: theme.textTheme.labelMedium?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
