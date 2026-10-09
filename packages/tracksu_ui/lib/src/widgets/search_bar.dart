import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// The search tab's field, floating at the bottom over the results, right
/// above the keyboard (iOS 26 search tab placement). Drawn like the app's
/// other controls — the chamfered shape of the pickers and option rows, a
/// tonal fill with a faint top sheen and a hairline edge that takes the
/// accent while focused — without a backdrop filter, so it costs nothing
/// while the keyboard moves it. A clear button shows while there is text.
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

  /// Space the floating bar takes at the bottom of the screen, for content
  /// to scroll clear of it.
  static const double area = height + UiSpace.sm + UiSpace.md;

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
    // One line box of exactly the font size, so the glyphs sit in the
    // optical middle of the capsule (the theme's 1.5 line height pushed
    // them off centre).
    final TextStyle style = (theme.textTheme.bodyLarge ?? const TextStyle())
        .copyWith(height: 1.2, color: colors.onSurface);
    const StrutStyle strut = StrutStyle(height: 1.2, forceStrutHeight: true);
    final Duration duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return SizedBox(
      height: UiSearchBar.height,
      child: ListenableBuilder(
        listenable: _focus,
        builder: (BuildContext context, Widget? child) =>
            _Field(focused: _focus.hasFocus, duration: duration, child: child!),
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
                child: Center(
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
                    strutStyle: strut,
                    cursorColor: colors.primary,
                    cursorHeight: 20,
                    // The capsule is the field: no theme fill or outline.
                    decoration: InputDecoration(
                      isCollapsed: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: widget.hint,
                      hintMaxLines: 1,
                      hintStyle: style.copyWith(color: colors.onSurfaceVariant),
                    ),
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
      ),
    );
  }
}

/// The field's surface: chamfered like `UiOptionRow` and the category
/// picker, tonal fill with a faint sheen, a soft shadow that lifts it off the
/// results, and an edge that eases to the accent on focus. Plain paint only.
final class _Field extends StatelessWidget {
  const _Field({
    required this.focused,
    required this.duration,
    required this.child,
  });
  final bool focused;
  final Duration duration;
  final Widget child;

  static const BeveledRectangleBorder _shape = BeveledRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(UiShape.control),
      bottomRight: Radius.circular(UiShape.control),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool contrast = MediaQuery.highContrastOf(context);
    final Color edge = focused
        ? colors.primary.withValues(alpha: contrast ? 1 : .55)
        : colors.onSurface.withValues(alpha: contrast ? .5 : .1);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: edge),
      duration: duration,
      curve: Curves.easeOut,
      builder: (BuildContext context, Color? side, Widget? child) =>
          DecoratedBox(
            decoration: ShapeDecoration(
              shape: _shape.copyWith(
                side: BorderSide(color: side ?? edge, width: focused ? 1.5 : 1),
              ),
              color: colors.surfaceContainerHighest,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color.alphaBlend(
                    colors.onSurface.withValues(alpha: .05),
                    colors.surfaceContainerHighest,
                  ),
                  colors.surfaceContainerHighest,
                ],
              ),
              shadows: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: .28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
      child: child,
    );
  }
}
