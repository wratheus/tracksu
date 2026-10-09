import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// Rows inside one card, built lazily: a long feed in a single surface
/// without laying out every row up front (a `Column` in a card builds all of
/// them, which stalls the first frame of a page). Looks like [UiSurface.card]
/// with dividers between rows; each row keeps its own ink.
final class UiSliverCard extends StatelessWidget {
  const UiSliverCard({
    required this.itemCount,
    required this.itemBuilder,
    this.dividerIndent = 0,
    super.key,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Leading inset of the dividers, e.g. to start them after an icon column.
  final double dividerIndent;

  static const double _inset = UiSpace.xs;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ShapeBorder shape =
        theme.cardTheme.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiShape.card),
        );
    // Ink of the first and last rows follows the card's rounded corners.
    final Radius corner = Radius.circular(
      math.max(0, UiShape.card - _inset),
    );
    return DecoratedSliver(
      decoration: ShapeDecoration(
        shape: shape,
        color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: _inset),
        sliver: SliverList.separated(
          itemCount: itemCount,
          separatorBuilder: (_, _) =>
              Divider(height: 1, indent: dividerIndent),
          itemBuilder: (BuildContext context, int index) => Material(
            type: MaterialType.transparency,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? corner : Radius.zero,
                bottom: index == itemCount - 1 ? corner : Radius.zero,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: itemBuilder(context, index),
          ),
        ),
      ),
    );
  }
}
