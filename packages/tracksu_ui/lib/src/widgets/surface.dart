import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// A quiet shared surface; feature cards remain in the application.
final class UiSurface extends StatelessWidget {
  const UiSurface({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: onTap == null
        ? Padding(padding: padding, child: child)
        : InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
  );
}
