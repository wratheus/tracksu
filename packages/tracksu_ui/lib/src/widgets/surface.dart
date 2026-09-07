import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

enum _SurfaceStyle { card, outlined, tonal, inset }

/// Shared surfaces, not containers for business models.
final class UiSurface extends StatelessWidget {
  const UiSurface({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    super.key,
  }) : _style = _SurfaceStyle.card;

  const UiSurface.card({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    super.key,
  }) : _style = _SurfaceStyle.card;

  const UiSurface.outlined({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    super.key,
  }) : _style = _SurfaceStyle.outlined;

  const UiSurface.tonal({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    super.key,
  }) : _style = _SurfaceStyle.tonal;

  const UiSurface.inset({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    super.key,
  }) : _style = _SurfaceStyle.inset;

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final _SurfaceStyle _style;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final ShapeBorder shape =
        theme.cardTheme.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiShape.card),
        );
    final Color? color = switch (_style) {
      _SurfaceStyle.card => null,
      _SurfaceStyle.outlined => colors.surface,
      _SurfaceStyle.tonal => colors.secondaryContainer,
      _SurfaceStyle.inset => colors.surfaceContainerLowest,
    };
    return Card(
      color: color,
      shape: _style == _SurfaceStyle.outlined && shape is OutlinedBorder
          ? shape.copyWith(side: BorderSide(color: colors.outlineVariant))
          : shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    );
  }
}
