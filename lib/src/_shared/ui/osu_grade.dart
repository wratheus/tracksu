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
    'XH' || 'SH' => const <Color>[Color(0xFFFFFFFF), Color(0xFFAADFF0)],
    'X' || 'S' => const <Color>[Color(0xFFFFE7A8), Color(0xFFFFB800)],
    'A' => const <Color>[Color(0xFF275227), Color(0xFF275227)],
    'B' => const <Color>[Color(0xFF553A2B), Color(0xFF553A2B)],
    'C' => const <Color>[Color(0xFF473625), Color(0xFF473625)],
    'D' => const <Color>[Color(0xFF512525), Color(0xFF512525)],
    _ => const <Color>[Color(0xFFCC3333), Color(0xFFCC3333)],
  };

  @override
  Widget build(BuildContext context) => Semantics(
    label: label ?? semanticLabel(context, grade),
    excludeSemantics: true,
    child: SizedBox(
      width: height * 2,
      height: height,
      child: CustomPaint(
        painter: _GradePainter(
          grade: _normal(grade),
          letter: letter(grade),
          background: _background(grade),
          letterColours: _letterColours(grade),
        ),
      ),
    ),
  );
}

/// Draws the badge in proportions measured from the osu! website grades
/// (32×16): capitals take 55 % of the height, centred slightly above the
/// middle, wide letters with a dark copy one sixteenth lower for S/SS. The
/// artwork itself is not used (osu-web is AGPL); shapes and font are ours.
final class _GradePainter extends CustomPainter {
  const _GradePainter({
    required this.grade,
    required this.letter,
    required this.background,
    required this.letterColours,
  });

  final String grade;
  final String letter;
  final Color background;
  final List<Color> letterColours;

  /// Exo 2 capital height in em (OS/2 sCapHeight 690 / 1000 units).
  static const double _capHeight = .69;

  bool get _shadowed => switch (grade) {
    'X' || 'XH' || 'S' || 'SH' || 'F' => true,
    _ => false,
  };

  static Color _shade(Color colour, double delta) {
    final HSLColor hsl = HSLColor.fromColor(colour);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;
    final RRect pill = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(h / 2),
    );
    canvas.save();
    canvas.clipRRect(pill);
    canvas.drawRect(Offset.zero & size, Paint()..color = _shade(background, -.04));
    void triangle(double cx, double top, double side, Color colour) {
      final double half = side / 1.732;
      canvas.drawPath(
        Path()
          ..moveTo(cx, top)
          ..lineTo(cx + half, top + side)
          ..lineTo(cx - half, top + side)
          ..close(),
        Paint()..color = colour,
      );
    }

    // lazer-style triangles: one large in the grade colour, three darker.
    triangle(w * .52, -h * .55, h * 1.9, background);
    triangle(w * .88, h * .15, h * .7, _shade(background, -.06));
    triangle(w * .2, -h * .2, h * .45, _shade(background, -.08));
    triangle(w * .3, h * .78, h * .45, _shade(background, -.08));
    canvas.restore();

    final double fontSize = h * .55 / _capHeight;
    final double spacing = fontSize * .04;
    TextPainter layout(Paint? foreground, Color? colour) => TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontFamily: 'Exo 2',
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontVariations: const <FontVariation>[FontVariation.weight(600)],
          letterSpacing: spacing,
          color: colour,
          foreground: foreground,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      maxLines: 1,
    )..layout();

    final TextPainter probe = layout(null, const Color(0xFF000000));
    final double baseline = probe.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    final double capTop = baseline - fontSize * _capHeight;
    // Capitals centred at 48 % of the height, as on the website.
    final double top = h * .48 - (capTop + fontSize * _capHeight / 2);
    final double inkWidth = probe.width - spacing;
    final Paint fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: letterColours,
      ).createShader(
        Rect.fromLTRB(0, capTop - h * .08, probe.width, capTop + h * .79),
      );

    canvas.save();
    canvas.translate(w / 2, top);
    // Wide letters like the website's grade font.
    canvas.scale(1.4, 1);
    final Offset origin = Offset(-inkWidth / 2, 0);
    if (_shadowed) {
      final TextPainter shadow = layout(
        null,
        _shade(background, -.32).withValues(alpha: .5),
      );
      shadow.paint(canvas, origin.translate(0, h / 16));
      shadow.dispose();
    }
    final TextPainter face = layout(fill, null);
    face.paint(canvas, origin);
    face.dispose();
    probe.dispose();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GradePainter old) =>
      old.grade != grade ||
      old.letter != letter ||
      old.background != background;
}
