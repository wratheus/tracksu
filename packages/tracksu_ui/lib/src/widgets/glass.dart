import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Frosted glass for controls that float over content or artwork.
///
/// [UiGlass] (media tone) is a dark veil for artwork — white content stays
/// readable on any cover. [UiGlass.surface] follows the theme: a light veil
/// over light pages, a smoky one over dark pages, with a soft lift shadow.
/// No glow and no colour wash — the backdrop provides the colour.
final class UiGlass extends StatelessWidget {
  const UiGlass({
    required this.child,
    this.shape = const StadiumBorder(),
    super.key,
  }) : _surface = false;

  const UiGlass.surface({
    required this.child,
    this.shape = const StadiumBorder(),
    super.key,
  }) : _surface = true;

  final Widget child;
  final OutlinedBorder shape;
  final bool _surface;

  /// Foreground for content on the media tone.
  static const Color onGlass = Colors.white;

  /// Foreground for content on [UiGlass.surface] in the current theme.
  static Color onSurfaceGlass(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  @override
  Widget build(BuildContext context) {
    final bool light =
        _surface && Theme.of(context).brightness == Brightness.light;
    final List<Color> veil = !_surface
        ? <Color>[
            Colors.black.withValues(alpha: .20),
            Colors.black.withValues(alpha: .40),
          ]
        : light
        ? <Color>[
            Colors.white.withValues(alpha: .78),
            Colors.white.withValues(alpha: .58),
          ]
        : <Color>[
            Colors.white.withValues(alpha: .14),
            Colors.white.withValues(alpha: .07),
          ];
    final Color edge = !_surface
        ? Colors.white.withValues(alpha: .22)
        : light
        ? Colors.black.withValues(alpha: .08)
        : Colors.white.withValues(alpha: .16);
    final Widget glass = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: shape.copyWith(side: BorderSide(color: edge)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: veil,
            ),
          ),
          child: child,
        ),
      ),
    );
    if (!_surface) return glass;
    // A soft, wide shadow lifts the control off the page without a halo.
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        shadows: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: light ? .10 : .30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: glass,
    );
  }
}
