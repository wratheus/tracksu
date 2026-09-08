import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

@immutable
final class UiSegment<T extends Object> {
  const UiSegment({
    required this.value,
    required this.label,
    required this.icon,
  });
  final T value;
  final String label;
  final Widget icon;
}

/// A controlled, single-row choice. Drag previews locally and commits once on
/// release; only the caller may update domain state or start a request.
final class UiSegmentedControl<T extends Object> extends StatefulWidget {
  UiSegmentedControl({
    required List<UiSegment<T>> segments,
    required this.selected,
    required this.onChanged,
    super.key,
  }) : segments = List<UiSegment<T>>.unmodifiable(segments),
       assert(segments.length >= 2),
       assert(
         segments.map((UiSegment<T> segment) => segment.value).toSet().length ==
             segments.length,
       ),
       assert(
         segments.any((UiSegment<T> segment) => segment.value == selected),
       );

  final List<UiSegment<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;

  @override
  State<UiSegmentedControl<T>> createState() => _UiSegmentedControlState<T>();
}

final class _UiSegmentedControlState<T extends Object>
    extends State<UiSegmentedControl<T>> {
  int? _dragIndex;
  int? _pressedIndex;
  int? _focusedIndex;

  void _preview(double x, double width, TextDirection direction) {
    final int physical = (x / width * widget.segments.length).floor().clamp(
      0,
      widget.segments.length - 1,
    );
    final int index = direction == TextDirection.rtl
        ? widget.segments.length - 1 - physical
        : physical;
    if (_dragIndex != index) setState(() => _dragIndex = index);
  }

  void _commit(int index) {
    final T value = widget.segments[index].value;
    if (value != widget.selected) widget.onChanged?.call(value);
  }

  @override
  void didUpdateWidget(covariant UiSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onChanged == null ||
        oldWidget.selected != widget.selected ||
        oldWidget.segments.length != widget.segments.length) {
      _dragIndex = null;
      _pressedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextDirection direction = Directionality.of(context);
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelMedium;
    final bool enabled = widget.onChanged != null;
    final int selectedIndex = widget.segments.indexWhere(
      (UiSegment<T> segment) => segment.value == widget.selected,
    );
    final int activeIndex = _dragIndex ?? selectedIndex;
    const BeveledRectangleBorder shape = BeveledRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(UiShape.control),
        bottomRight: Radius.circular(UiShape.control),
      ),
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double cellWidth = constraints.maxWidth / widget.segments.length;
        // Preserve text scaling, but never wrap the control into another row.
        // At narrow widths icons retain full tooltips and semantic labels.
        final bool showLabels = widget.segments.every((UiSegment<T> segment) {
          final TextPainter painter = TextPainter(
            text: TextSpan(text: segment.label, style: labelStyle),
            textDirection: direction,
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          final bool fits = painter.width <= cellWidth - UiSpace.md;
          painter.dispose();
          return fits;
        });
        return GestureDetector(
          onHorizontalDragStart: !enabled
              ? null
              : (DragStartDetails details) => _preview(
                  details.localPosition.dx,
                  constraints.maxWidth,
                  direction,
                ),
          onHorizontalDragUpdate: !enabled
              ? null
              : (DragUpdateDetails details) => _preview(
                  details.localPosition.dx,
                  constraints.maxWidth,
                  direction,
                ),
          onHorizontalDragCancel: !enabled
              ? null
              : () => setState(() => _dragIndex = null),
          onHorizontalDragEnd: !enabled
              ? null
              : (_) {
                  final int? index = _dragIndex;
                  setState(() => _dragIndex = null);
                  if (index != null) _commit(index);
                },
          child: _SegmentGlass(
            shape: shape,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: AnimatedAlign(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    alignment: AlignmentDirectional(
                      -1 + 2 * activeIndex / (widget.segments.length - 1),
                      0,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 1 / widget.segments.length,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              Color.alphaBlend(
                                colors.onSurface.withValues(alpha: 0.08),
                                enabled
                                    ? colors.primaryContainer
                                    : colors.surfaceContainer,
                              ),
                              (enabled
                                      ? colors.primaryContainer
                                      : colors.surfaceContainer)
                                  .withValues(alpha: 0.82),
                            ],
                          ),
                          shape: shape.copyWith(
                            side: BorderSide(
                              color: colors.onSurface.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    for (int index = 0; index < widget.segments.length; index++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: selectedIndex == index,
                          enabled: enabled,
                          inMutuallyExclusiveGroup: true,
                          label: widget.segments[index].label,
                          child: Tooltip(
                            message: widget.segments[index].label,
                            excludeFromSemantics: true,
                            child: InkWell(
                              customBorder: shape,
                              splashFactory: NoSplash.splashFactory,
                              overlayColor: const WidgetStatePropertyAll<Color>(
                                Colors.transparent,
                              ),
                              onFocusChange: (bool focused) => setState(() {
                                _focusedIndex = focused ? index : null;
                              }),
                              onHighlightChanged: (bool pressed) =>
                                  setState(() {
                                    _pressedIndex = pressed ? index : null;
                                  }),
                              onTap: !enabled ? null : () => _commit(index),
                              child: AnimatedContainer(
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 100),
                                decoration: ShapeDecoration(
                                  shape: shape.copyWith(
                                    side: _focusedIndex == index
                                        ? BorderSide(
                                            color: colors.primary,
                                            width: 2,
                                          )
                                        : BorderSide.none,
                                  ),
                                  color: _pressedIndex == index
                                      ? colors.onSurface.withValues(alpha: 0.09)
                                      : Colors.transparent,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 48,
                                  minWidth: 48,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: UiSpace.sm,
                                    horizontal: UiSpace.xs,
                                  ),
                                  child: ExcludeSemantics(
                                    child: IconTheme(
                                      data: IconThemeData(
                                        color: !enabled
                                            ? colors.onSurfaceVariant
                                            : activeIndex == index
                                            ? colors.onPrimaryContainer
                                            : colors.onSurfaceVariant,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: UiSpace.xs,
                                        children: <Widget>[
                                          widget.segments[index].icon,
                                          if (showLabels)
                                            Text(
                                              widget.segments[index].label,
                                              style: labelStyle?.copyWith(
                                                color:
                                                    activeIndex == index &&
                                                        enabled
                                                    ? colors.onPrimaryContainer
                                                    : colors.onSurfaceVariant,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One bounded blur, not one filter per segment. Ink never paints the thumb.
final class _SegmentGlass extends StatelessWidget {
  const _SegmentGlass({required this.shape, required this.child});
  final ShapeBorder shape;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool solid = MediaQuery.highContrastOf(context);
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        enabled: !solid,
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: colors.surfaceContainerHighest.withValues(
            alpha: solid ? 1 : 0.72,
          ),
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: shape,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colors.onSurface.withValues(alpha: 0.08),
                  colors.onSurface.withValues(alpha: 0.01),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
