import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// One option in a sheet (a choice list, a category picker, a plain list of
/// facts): a chamfered card in the shape of the segmented controls, the icon
/// in its own tinted chip, the label, and — when selected — the accent fill
/// of the segmented thumb with a check. [onTap] null makes it a static row.
final class UiOptionRow extends StatelessWidget {
  const UiOptionRow({
    required this.label,
    this.icon,
    this.subtitle,
    this.selected = false,
    this.onTap,
    super.key,
  });
  final String label;
  final IconData? icon;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  static const BeveledRectangleBorder shape = BeveledRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(UiShape.control),
      bottomRight: Radius.circular(UiShape.control),
    ),
  );

  static const BeveledRectangleBorder _chip = BeveledRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(UiSpace.sm),
      bottomRight: Radius.circular(UiSpace.sm),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color foreground = selected
        ? colors.onPrimaryContainer
        : colors.onSurface;
    return Semantics(
      button: onTap != null,
      selected: onTap != null && selected,
      inMutuallyExclusiveGroup: onTap != null,
      label: subtitle == null ? label : '$label, $subtitle',
      excludeSemantics: true,
      child: Material(
        shape: shape.copyWith(
          side: BorderSide(
            color: selected
                ? colors.primary.withValues(alpha: 0.45)
                : colors.onSurface.withValues(alpha: 0.06),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        color: colors.surfaceContainerHigh,
        child: Ink(
          decoration: selected
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color.alphaBlend(
                        colors.onSurface.withValues(alpha: 0.08),
                        colors.primaryContainer,
                      ),
                      colors.primaryContainer.withValues(alpha: 0.82),
                    ],
                  ),
                )
              : null,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: UiShape.minTarget + 8,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiSpace.md,
                  vertical: UiSpace.sm,
                ),
                child: Row(
                  spacing: UiSpace.md,
                  children: <Widget>[
                    if (icon case final IconData glyph)
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: _chip,
                          color: (selected ? foreground : colors.primary)
                              .withValues(alpha: 0.14),
                        ),
                        child: SizedBox.square(
                          dimension: 36,
                          child: Icon(
                            glyph,
                            size: 20,
                            color: selected ? foreground : colors.primary,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: foreground,
                            ),
                          ),
                          if (subtitle case final String text)
                            Text(
                              text,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: selected
                                    ? foreground.withValues(alpha: 0.8)
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (selected && onTap != null)
                      Icon(Icons.check_rounded, color: foreground),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
