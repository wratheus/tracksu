import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_colors.dart';

/// Score grade drawn like osu!lazer's `DrawableRank` (ppy/osu, MIT):
/// a 2:1 pill in the grade colour with soft triangles, and the letter in the
/// in-game colours — gold for S/SS, silver for the Hidden/Flashlight variants
/// (SH/XH), dark tinted letters for A–D, red F on grey for failed plays.
///
/// API `rank` values: XH, X, SH, S, A, B, C, D, F (SS/SSH are accepted too).
final class OsuGradeBadge extends StatelessWidget {
  const OsuGradeBadge({
    required this.grade,
    this.label,
    this.height = 24,
    super.key,
  });

  final String grade;

  /// Screen-reader text; defaults to "Grade: SS" / "Grade: Silver S".
  final String? label;

  /// Width is always twice the height, as in lazer.
  final double height;

  /// The letter players see: X/XH → SS, SH → S.
  static String letter(String grade) => switch (_normal(grade)) {
    'X' || 'XH' => 'SS',
    'SH' => 'S',
    final String other => other,
  };

  static bool isSilver(String grade) =>
      _normal(grade) == 'XH' || _normal(grade) == 'SH';

  /// Spoken form for accessibility, e.g. "Grade: Silver SS".
  static String semanticLabel(BuildContext context, String grade) =>
      context.t.scoresGrade(
        isSilver(grade)
            ? context.t.gradeSilver(letter(grade))
            : letter(grade),
      );

  static String _normal(String grade) => switch (grade.trim().toUpperCase()) {
    'SS' => 'X',
    'SSH' => 'XH',
    final String other => other,
  };

  static Color _background(String grade) =>
      _normal(grade) == 'F' ? const Color(0xFF3F3F3F) : OsuColors.forRank(grade);

  /// `DrawableRank.GetRankLetterColour`: gradients top → bottom.
  static List<Color> _letterColours(String grade) => switch (_normal(grade)) {
    'XH' || 'SH' => const <Color>[Color(0xFFFFFFFF), Color(0xFFAFDFF0)],
    'X' || 'S' => const <Color>[Color(0xFFFFE7A8), Color(0xFFFFB800)],
    'A' => const <Color>[Color(0xFF275227), Color(0xFF275227)],
    'B' => const <Color>[Color(0xFF553A2B), Color(0xFF553A2B)],
    'C' => const <Color>[Color(0xFF473625), Color(0xFF473625)],
    'D' => const <Color>[Color(0xFF512525), Color(0xFF512525)],
    _ => const <Color>[Color(0xFFCC3333), Color(0xFFCC3333)],
  };

  @override
  Widget build(BuildContext context) {
    final Color background = _background(grade);
    final List<Color> letterColours = _letterColours(grade);
    final String text = letter(grade);
    final double fontSize = height * .74;
    return Semantics(
      label: label ?? semanticLabel(context, grade),
      excludeSemantics: true,
      child: SizedBox(
        width: height * 2,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: CustomPaint(
            painter: _GradeTrianglesPainter(
              background: background,
              seed: _normal(grade).hashCode,
            ),
            child: Center(
              child: Text(
                text,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontFamily: 'Exo 2',
                  fontSize: fontSize,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  // Exo 2 is a variable font: weight comes from the axis.
                  fontVariations: const <FontVariation>[FontVariation.weight(900)],
                  letterSpacing: -height * .04,
                  // Gradient over the glyph box only; shadows keep their
                  // own colour (a ShaderMask would tint them too).
                  foreground: Paint()
                    ..shader = LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: letterColours,
                    ).createShader(Rect.fromLTWH(0, 0, height * 2, fontSize)),
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.black.withValues(alpha: .3),
                      offset: Offset(0, height * .06),
                      blurRadius: height * .08,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// lazer's `Triangles` background frozen in place: a few triangles a shade
/// darker or lighter than the grade colour. Deterministic per grade so lists
/// do not shimmer on rebuild.
final class _GradeTrianglesPainter extends CustomPainter {
  const _GradeTrianglesPainter({required this.background, required this.seed});
  final Color background;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final HSLColor base = HSLColor.fromColor(background);
    final Color dark = base
        .withLightness((base.lightness - .06).clamp(0, 1))
        .toColor();
    final Color light = base
        .withLightness((base.lightness + .06).clamp(0, 1))
        .toColor();
    final math.Random random = math.Random(seed);
    final Paint paint = Paint();
    for (int i = 0; i < 9; i++) {
      final double side = size.height * (.35 + random.nextDouble() * .7);
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * (size.height + side) - side / 2;
      paint.color = (random.nextBool() ? dark : light).withValues(alpha: .7);
      canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x - side * .58, y + side)
          ..lineTo(x + side * .58, y + side)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GradeTrianglesPainter old) =>
      old.background != background || old.seed != seed;
}
