import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/segmented_control.dart';

/// Shared page chrome. Features own the title, actions and tab controller.
/// Keeping tabs in the bottom slot leaves each page's scroll view independent.
///
/// The toolbar row has the same height and baseline on every screen, with or
/// without the back control: [bottom] always gets exactly its declared
/// height, so a bottom that is taller than declared can never squeeze the
/// toolbar (Material shrinks the toolbar first and shifts its items up).
final class UiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UiAppBar({
    required this.title,
    this.actions,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
    super.key,
  });
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;

  /// Space around a segmented control in [bottom]; the same on every screen
  /// so tab rows do not move between pages.
  static const EdgeInsets rowPadding = EdgeInsets.fromLTRB(
    UiSpace.lg,
    UiSpace.sm,
    UiSpace.lg,
    UiSpace.xs,
  );

  /// Height of one [rowPadding] row with a labelled [UiSegmentedControl] at
  /// the current text scale. Bottoms are sized from this, not literals.
  static double segmentedRowHeight(BuildContext context) =>
      rowPadding.vertical + UiSegmentedControl.heightOf(context);

  // Back control: its visible box lines up with the page content (16 pt).
  static const double _leadingInset = UiSpace.lg - UiBackButton._inset;
  static const double _leadingWidth = _leadingInset + UiShape.minTarget;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    final bool canPop = route?.impliesAppBarDismissal ?? false;
    final bool close = route is PageRoute<Object?> && route.fullscreenDialog;
    return AppBar(
      automaticallyImplyLeading: false,
      leading: canPop
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: _leadingInset),
              child: UiBackButton(close: close),
            )
          : null,
      leadingWidth: _leadingWidth,
      titleSpacing: canPop ? UiSpace.sm : NavigationToolbar.kMiddleSpacing,
      title: title,
      actions: actions,
      bottom: bottom == null ? null : _PinnedBottom(bottom!),
      toolbarHeight: toolbarHeight,
      centerTitle: false,
    );
  }
}

/// Gives the bottom exactly its declared height (overflow shows up in debug
/// instead of moving the toolbar).
final class _PinnedBottom extends StatelessWidget
    implements PreferredSizeWidget {
  const _PinnedBottom(this.child);
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: preferredSize.height, child: child);
}

/// Compact back (or close) control: the chamfered glass shape of
/// [UiSegmentedControl] at 36 pt, inside a 48 pt touch target. Pops the
/// current route unless [onPressed] is given; the system back gesture is
/// unaffected.
final class UiBackButton extends StatelessWidget {
  const UiBackButton({this.close = false, this.onPressed, super.key});
  final bool close;
  final VoidCallback? onPressed;

  static const double size = 36;
  static const double _inset = (UiShape.minTarget - size) / 2;
  static const BeveledRectangleBorder _shape = BeveledRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(UiSpace.sm),
      bottomRight: Radius.circular(UiSpace.sm),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final MaterialLocalizations l10n = MaterialLocalizations.of(context);
    final bool solid = MediaQuery.highContrastOf(context);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final String label = close
        ? l10n.closeButtonTooltip
        : l10n.backButtonTooltip;
    void pop() {
      if (onPressed case final VoidCallback press) {
        press();
      } else {
        unawaited(Navigator.maybePop(context));
      }
    }

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: GestureDetector(
          // The margin around the box still counts as the target.
          behavior: HitTestBehavior.opaque,
          onTap: pop,
          child: SizedBox.square(
            dimension: UiShape.minTarget,
            child: Center(
              child: Material(
                color: colors.surfaceContainerHighest.withValues(
                  alpha: solid ? 1 : 0.72,
                ),
                shape: _shape.copyWith(
                  side: BorderSide(
                    color: colors.onSurface.withValues(alpha: 0.12),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: _shape,
                  onTap: pop,
                  child: SizedBox.square(
                    dimension: size,
                    child: Icon(
                      close
                          ? Icons.close_rounded
                          : rtl
                          ? Icons.chevron_right_rounded
                          : Icons.chevron_left_rounded,
                      size: 24,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
