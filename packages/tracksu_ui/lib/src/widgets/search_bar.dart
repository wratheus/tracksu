import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// The search tab's field, at the bottom of the screen above the keyboard
/// (iOS 26 search tab): a floating capsule with a soft shadow, the icon and
/// the text on one baseline, a clear button while there is text, and an
/// accent ring while focused.
final class UiSearchBar extends StatefulWidget {
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

  @override
  State<UiSearchBar> createState() => _UiSearchBarState();
}

final class _UiSearchBarState extends State<UiSearchBar> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextStyle? style = theme.textTheme.bodyLarge;
    final Duration duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 160);
    return ListenableBuilder(
      listenable: _focus,
      builder: (BuildContext context, Widget? child) => AnimatedContainer(
        duration: duration,
        height: UiSearchBar.height,
        decoration: ShapeDecoration(
          shape: StadiumBorder(
            side: BorderSide(
              color: _focus.hasFocus
                  ? colors.primary.withValues(alpha: 0.7)
                  : colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          color: colors.surfaceContainerHigh,
          shadows: <BoxShadow>[
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: UiSpace.lg,
          end: UiSpace.xs,
        ),
        child: Row(
          spacing: UiSpace.sm,
          children: <Widget>[
            Icon(
              Icons.search_rounded,
              size: 22,
              color: colors.onSurfaceVariant,
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                onSubmitted: widget.onSubmitted,
                onChanged: widget.onChanged,
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                autocorrect: false,
                maxLines: 1,
                style: style,
                cursorColor: colors.primary,
                // The capsule is the field: no theme fill or focus outline.
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: widget.hint,
                  hintMaxLines: 1,
                  hintStyle: style?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (BuildContext context, TextEditingValue value, _) =>
                  AnimatedSwitcher(
                    duration: duration,
                    child: value.text.isEmpty
                        ? const SizedBox(width: UiSpace.sm)
                        : IconButton(
                            key: const ValueKey<String>('clear'),
                            tooltip: widget.clearLabel,
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              widget.controller.clear();
                              widget.onChanged?.call('');
                            },
                            icon: Icon(
                              Icons.cancel_rounded,
                              size: 20,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
