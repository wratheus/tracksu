import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/glass.dart';

/// The search tab's field, floating at the bottom over the results, right
/// above the keyboard (iOS 26 search tab, Liquid Glass): a frosted capsule
/// the content blurs through, a light rim brighter at the top, the icon,
/// hint and text centred on one line, a clear button while there is text and
/// an accent rim while focused.
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

  static const double height = 50;

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
      child: UiGlass.surface(
        child: ListenableBuilder(
          listenable: _focus,
          builder: (BuildContext context, Widget? child) => CustomPaint(
            foregroundPainter: _Rim(
              focused: _focus.hasFocus,
              accent: colors.primary,
              light: theme.brightness == Brightness.light,
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
                        hintStyle: style.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.controller,
                  builder:
                      (BuildContext context, TextEditingValue value, _) =>
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
      ),
    );
  }
}

/// Specular rim: light catches the top edge and fades towards the bottom;
/// focused, the rim takes the accent.
final class _Rim extends CustomPainter {
  const _Rim({
    required this.focused,
    required this.accent,
    required this.light,
  });
  final bool focused;
  final Color accent;
  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect capsule = RRect.fromRectAndRadius(
      rect.deflate(0.75),
      Radius.circular(size.height / 2),
    );
    final Color top = focused
        ? accent.withValues(alpha: 0.9)
        : (light ? Colors.white : Colors.white.withValues(alpha: 0.55));
    final Color bottom = focused
        ? accent.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: light ? 0.25 : 0.06);
    canvas.drawRRect(
      capsule,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[top, bottom],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_Rim old) =>
      old.focused != focused || old.accent != accent || old.light != light;
}
