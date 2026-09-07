import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/content_state.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

@immutable
final class UiChartPoint {
  const UiChartPoint({
    required this.x,
    required this.value,
    required this.label,
    required this.valueLabel,
  });
  final double x;
  final double value;

  /// Caller formats dates, units and numbers in its locale.
  final String label;
  final String valueLabel;
}

enum _ChartStyle { line, bars }

/// One ordered, finite series. No smoothing that invents peaks between samples.
final class UiChart extends StatefulWidget {
  UiChart.line({
    required this.title,
    required List<UiChartPoint> points,
    required this.emptyLabel,
    this.lowerIsBetter = false,
    this.onPointSelected,
    super.key,
  }) : points = _validate(points, bars: false),
       _style = _ChartStyle.line;
  UiChart.bars({
    required this.title,
    required List<UiChartPoint> points,
    required this.emptyLabel,
    this.onPointSelected,
    super.key,
  }) : points = _validate(points, bars: true),
       lowerIsBetter = false,
       _style = _ChartStyle.bars;
  final String title;
  final List<UiChartPoint> points;
  final String emptyLabel;
  final bool lowerIsBetter;
  final ValueChanged<UiChartPoint>? onPointSelected;
  final _ChartStyle _style;

  static List<UiChartPoint> _validate(
    List<UiChartPoint> points, {
    required bool bars,
  }) {
    double? previousX;
    for (final UiChartPoint point in points) {
      if (!point.x.isFinite ||
          !point.value.isFinite ||
          (bars && point.value < 0) ||
          (previousX != null && point.x <= previousX)) {
        throw ArgumentError(
          'Chart points need finite values and strictly increasing x; bars must be non-negative.',
        );
      }
      previousX = point.x;
    }
    if (points.isNotEmpty) {
      final Iterable<double> values = points.map(
        (UiChartPoint point) => point.value,
      );
      final double min = values.reduce((double a, double b) => a < b ? a : b);
      final double max = values.reduce((double a, double b) => a > b ? a : b);
      if (!(max - min).isFinite || !(points.last.x - points.first.x).isFinite) {
        throw ArgumentError('Chart range must be finite.');
      }
    }
    return List<UiChartPoint>.unmodifiable(points);
  }

  @override
  State<UiChart> createState() => _UiChartState();
}

final class _UiChartState extends State<UiChart> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.points.isEmpty ? 0 : widget.points.length - 1;
  }

  @override
  void didUpdateWidget(covariant UiChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Preserve the selected timestamp on refresh; otherwise select the latest.
    final double? oldX = oldWidget.points.isEmpty
        ? null
        : oldWidget.points[_selected].x;
    final int match = widget.points.indexWhere(
      (UiChartPoint point) => point.x == oldX,
    );
    _selected = match >= 0
        ? match
        : widget.points.isEmpty
        ? 0
        : widget.points.length - 1;
  }

  void _select(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
    widget.onPointSelected?.call(widget.points[index]);
  }

  void _selectAt(double x, double width) {
    final List<UiChartPoint> points = widget.points;
    if (width <= UiSpace.lg || points.isEmpty) return;
    final double position = ((x - UiSpace.sm) / (width - UiSpace.lg)).clamp(
      0,
      1,
    );
    if (widget._style == _ChartStyle.bars) {
      _select((position * points.length).floor().clamp(0, points.length - 1));
      return;
    }
    final double value =
        points.first.x + position * (points.last.x - points.first.x);
    int closest = 0;
    for (int i = 1; i < points.length; i++) {
      if ((points[i].x - value).abs() < (points[closest].x - value).abs()) {
        closest = i;
      }
    }
    _select(closest);
  }

  @override
  Widget build(BuildContext context) {
    final List<UiChartPoint> points = widget.points;
    if (points.isEmpty) return UiContentState.empty(title: widget.emptyLabel);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final UiChartPoint selected = points[_selected];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.sm,
      children: <Widget>[
        UiText.titleMedium(widget.title),
        Semantics(
          liveRegion: true,
          label: '${selected.label}, ${selected.valueLabel}',
          excludeSemantics: true,
          child: Wrap(
            spacing: UiSpace.md,
            runSpacing: UiSpace.xs,
            children: <Widget>[
              UiText.titleLarge(selected.valueLabel),
              UiText.bodyMedium(selected.label, secondary: true),
            ],
          ),
        ),
        // The slider exposes the same discrete samples to keyboard/TalkBack.
        ExcludeSemantics(
          child: SizedBox(
            height: 160,
            child: LayoutBuilder(
              builder: (_, BoxConstraints constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (TapDownDetails details) =>
                    _selectAt(details.localPosition.dx, constraints.maxWidth),
                onHorizontalDragUpdate: (DragUpdateDetails details) =>
                    _selectAt(details.localPosition.dx, constraints.maxWidth),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _ChartPainter(
                      points: points,
                      selected: _selected,
                      style: widget._style,
                      lowerIsBetter: widget.lowerIsBetter,
                      color: colors.primary,
                      gridColor: colors.outlineVariant,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          spacing: UiSpace.sm,
          children: <Widget>[
            Expanded(
              child: UiText.labelSmall(
                points.first.label,
                secondary: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: UiText.labelSmall(
                points.last.label,
                secondary: true,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (points.length > 1)
          Semantics(
            label: widget.title,
            child: Slider(
              value: _selected.toDouble(),
              max: (points.length - 1).toDouble(),
              divisions: points.length - 1,
              label: '${selected.label}: ${selected.valueLabel}',
              semanticFormatterCallback: (double value) {
                final UiChartPoint point = points[value.round()];
                return '${point.label}: ${point.valueLabel}';
              },
              onChanged: (double value) => _select(value.round()),
            ),
          ),
      ],
    );
  }
}

final class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.points,
    required this.selected,
    required this.style,
    required this.lowerIsBetter,
    required this.color,
    required this.gridColor,
  });
  final List<UiChartPoint> points;
  final int selected;
  final _ChartStyle style;
  final bool lowerIsBetter;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= UiSpace.lg || size.height <= UiSpace.lg) return;
    final Rect plot = Rect.fromLTWH(
      UiSpace.sm,
      UiSpace.sm,
      size.width - UiSpace.lg,
      size.height - UiSpace.lg,
    );
    double minimum = points.first.value;
    double maximum = minimum;
    for (final UiChartPoint point in points) {
      if (point.value < minimum) minimum = point.value;
      if (point.value > maximum) maximum = point.value;
    }
    if (style == _ChartStyle.bars) minimum = 0;
    final double range = maximum - minimum;
    final Paint grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int i = 0; i <= 2; i++) {
      final double y = plot.top + plot.height * i / 2;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
    }
    final List<Offset> positions = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final double fraction = range == 0
          ? (style == _ChartStyle.bars ? 0 : 0.5)
          : (points[i].value - minimum) / range;
      final double x = style == _ChartStyle.bars
          ? (i + 0.5) / points.length
          : points.length == 1
          ? 0.5
          : (points[i].x - points.first.x) / (points.last.x - points.first.x);
      positions.add(
        Offset(
          plot.left + x * plot.width,
          plot.top + (lowerIsBetter ? fraction : 1 - fraction) * plot.height,
        ),
      );
    }
    if (style == _ChartStyle.bars) {
      final double width = (plot.width / points.length * 0.65).clamp(1, 32);
      for (int i = 0; i < positions.length; i++) {
        final Offset point = positions[i];
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              point.dx - width / 2,
              point.dy,
              point.dx + width / 2,
              plot.bottom,
            ),
            const Radius.circular(3),
          ),
          Paint()
            ..color = i == selected ? color : color.withValues(alpha: 0.45),
        );
      }
    } else {
      final Path line = Path()..moveTo(positions.first.dx, positions.first.dy);
      for (final Offset point in positions.skip(1)) {
        line.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }
    final Offset focus = positions[selected];
    canvas.drawLine(
      Offset(focus.dx, plot.top),
      Offset(focus.dx, plot.bottom),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(focus, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      points != oldDelegate.points ||
      selected != oldDelegate.selected ||
      style != oldDelegate.style ||
      lowerIsBetter != oldDelegate.lowerIsBetter ||
      color != oldDelegate.color ||
      gridColor != oldDelegate.gridColor;
}
