import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Frosted glass for controls that float over content or artwork (player,
/// scroll-to-top). Dark tint with a light hairline: white content on it stays
/// readable over bright and dark backgrounds, in both themes. No glow, no
/// colour wash — the backdrop provides the colour.
final class UiGlass extends StatelessWidget {
  const UiGlass({
    required this.child,
    this.shape = const StadiumBorder(),
    super.key,
  });

  final Widget child;
  final OutlinedBorder shape;

  /// Foreground colour for icons and text placed on glass.
  static const Color onGlass = Colors.white;

  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: ShapeBorderClipper(shape: shape),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape.copyWith(
            side: BorderSide(color: Colors.white.withValues(alpha: .22)),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.black.withValues(alpha: .20),
              Colors.black.withValues(alpha: .40),
            ],
          ),
        ),
        child: child,
      ),
    ),
  );
}
