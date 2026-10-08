import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// Search in the app bar: [UiSearchPill] on every screen opens search, and
/// the search screen's own bar holds [UiAppBarSearchField]. Both share one
/// glass shape (the chamfer of segmented controls and the back button) and
/// one hero, so the pill grows into the field when search opens.
abstract final class UiAppBarSearch {
  static const Object heroTag = 'ui-app-bar-search';

  /// Visible height; the touch target stays 48 pt.
  static const double height = 36;

  static const BeveledRectangleBorder shape = BeveledRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(UiSpace.sm),
      bottomRight: Radius.circular(UiSpace.sm),
    ),
  );

  static Widget _hero(Widget child) => Hero(
    tag: heroTag,
    // The flight shows the bare glass; a live text field never flies.
    flightShuttleBuilder: (_, Animation<double> animation, _, _, _) =>
        const _Glass(child: _Icon()),
    child: child,
  );
}

/// Opens search. On a root tab it reads "🔍 Search"; on a pushed page it is
/// icon only, so long titles keep their room.
final class UiSearchPill extends StatelessWidget {
  const UiSearchPill({
    required this.label,
    required this.onPressed,
    this.compact,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;

  /// Null: compact when the page has a back control.
  final bool? compact;

  @override
  Widget build(BuildContext context) {
    final bool iconOnly =
        compact ?? (ModalRoute.of(context)?.impliesAppBarDismissal ?? false);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: UiShape.minTarget,
            minHeight: UiShape.minTarget,
          ),
          child: Center(
            child: UiAppBarSearch._hero(
              _Glass(
                onTap: onPressed,
                child: iconOnly
                    ? const _Icon()
                    : Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: UiSpace.md,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const _Icon(),
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
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

/// The search screen's field, in the toolbar where the title would be.
/// Plain text input in the glass shape: hint instead of a floating label,
/// clear button while there is text.
final class UiAppBarSearchField extends StatelessWidget {
  const UiAppBarSearchField({
    required this.controller,
    required this.hint,
    required this.clearLabel,
    this.onSubmitted,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });
  final TextEditingController controller;
  final String hint;
  final String clearLabel;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return UiAppBarSearch._hero(
      _Glass(
        child: Row(
          children: <Widget>[
            const _Icon(),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                onSubmitted: onSubmitted,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                maxLines: 1,
                style: theme.textTheme.bodyLarge,
                // The glass is the field: no theme fill or focus outline.
                decoration: InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: hint,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (BuildContext context, TextEditingValue value, _) =>
                  value.text.isEmpty
                  ? const SizedBox(width: UiSpace.sm)
                  : IconButton(
                      tooltip: clearLabel,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: UiAppBarSearch.height,
                        height: UiAppBarSearch.height,
                      ),
                      iconSize: 18,
                      onPressed: () {
                        controller.clear();
                        onChanged?.call('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Icon extends StatelessWidget {
  const _Icon();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: UiAppBarSearch.height,
    child: Icon(
      Icons.search_rounded,
      size: 20,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}

/// The shared glass body; [onTap] makes it a button.
final class _Glass extends StatelessWidget {
  const _Glass({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool solid = MediaQuery.highContrastOf(context);
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: solid ? 1 : 0.72),
      // Fill only, no outline: quiet next to the plain action icons.
      shape: UiAppBarSearch.shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: UiAppBarSearch.shape,
        onTap: onTap,
        child: SizedBox(height: UiAppBarSearch.height, child: child),
      ),
    );
  }
}
