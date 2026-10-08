import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// The search tab's field, at the bottom of the screen above the keyboard
/// (iOS 26 search tab). Glass in the chamfered shape of segmented controls
/// and the back button; plain input with a hint and a clear button.
final class UiSearchBar extends StatelessWidget {
  const UiSearchBar({
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

  static const double height = 48;

  static const BeveledRectangleBorder _shape = BeveledRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(UiSpace.md),
      bottomRight: Radius.circular(UiSpace.md),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool solid = MediaQuery.highContrastOf(context);
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: solid ? 1 : 0.9),
      shape: _shape,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            SizedBox.square(
              dimension: height,
              child: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
            ),
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
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (BuildContext context, TextEditingValue value, _) =>
                  value.text.isEmpty
                  ? const SizedBox(width: UiSpace.md)
                  : IconButton(
                      tooltip: clearLabel,
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
