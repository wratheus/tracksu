import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

@immutable
final class UiGaugeBand {
  const UiGaugeBand({
    required this.start,
    required this.end,
    required this.label,
    required this.color,
  });
  final double start;
  final double end;
  final String label;
  final Color color;
}

/// Accuracy progress plus a separate reference scale. Never derives the grade:
/// callers supply authoritative grade/thresholds and accessible explanations.
final class UiGradeGauge extends StatelessWidget {
  const UiGradeGauge({
    required this.accuracy,
    required this.accuracyLabel,
    required this.grade,
    required this.bands,
    required this.semanticLabel,
    super.key,
  });
  final double accuracy;
  final String accuracyLabel;
  final String grade;
  final List<UiGaugeBand> bands;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool largeText = MediaQuery.textScalerOf(context).scale(14) > 18;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double diameter = math.min(constraints.maxWidth, 320);
        final bool inlineLabels = !largeText && diameter >= 280;
        return Semantics(
          label: semanticLabel,
          excludeSemantics: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: UiSpace.sm,
            children: <Widget>[
              SizedBox.square(
                dimension: diameter,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(UiSpace.xl),
                        child: CustomPaint(
                          painter: _GaugePainter(
                            accuracy: accuracy.isFinite
                                ? accuracy.clamp(0, 1)
                                : 0,
                            bands: bands,
                            track: colors.surfaceContainerHighest,
                            accent: colors.secondary,
                            endColor:
                                Theme.of(context)
                                    .extension<UiStatusColors>()
                                    ?.success ??
                                colors.tertiary,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(64),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              UiText.displaySmall(
                                grade,
                                color: colors.secondary,
                              ),
                              UiText.titleMedium(accuracyLabel),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (inlineLabels)
                      for (int i = 0; i < bands.length; i++)
                        _bandLabel(bands[i], diameter, i == bands.length - 1),
                  ],
                ),
              ),
              if (!inlineLabels)
                Wrap(
                  spacing: UiSpace.md,
                  runSpacing: UiSpace.sm,
                  children: <Widget>[
                    for (final UiGaugeBand band in bands)
                      UiText.labelLarge(band.label, color: band.color),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _bandLabel(UiGaugeBand band, double diameter, bool last) {
    final double fraction = last
        ? 1
        : band.start +
              (band.end - band.start) * (band.start >= 0.9 ? 0.25 : 0.5);
    final double angle = -math.pi / 2 + fraction * math.pi * 2;
    final double radius = diameter / 2 - 12;
    return Positioned(
      left: diameter / 2 + math.cos(angle) * radius - 16,
      top: diameter / 2 + math.sin(angle) * radius - 10,
      width: 32,
      child: UiText.labelSmall(
        band.label,
        color: band.color,
        textAlign: TextAlign.center,
      ),
    );
  }
}

final class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.accuracy,
    required this.bands,
    required this.track,
    required this.accent,
    required this.endColor,
  });
  final double accuracy;
  final List<UiGaugeBand> bands;
  final Color track;
  final Color accent;
  final Color endColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.shortestSide * 0.09;
    final Rect rect = (Offset.zero & size).deflate(width / 2);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = track;
    canvas.drawOval(rect, paint);
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[accent, endColor],
    ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, accuracy * math.pi * 2, false, paint);
    paint
      ..shader = null
      ..strokeWidth = 3;
    final Rect scale = rect.deflate(width * 0.85);
    for (final UiGaugeBand band in bands) {
      final double sweep = (band.end - band.start) * math.pi * 2;
      if (sweep <= 0) continue;
      final double gap = math.min(0.025, sweep * 0.15);
      paint.color = band.color;
      canvas.drawArc(
        scale,
        -math.pi / 2 + band.start * math.pi * 2 + gap / 2,
        sweep - gap,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.accuracy != accuracy ||
      oldDelegate.track != track ||
      oldDelegate.accent != accent ||
      oldDelegate.endColor != endColor ||
      oldDelegate.bands != bands;
}
