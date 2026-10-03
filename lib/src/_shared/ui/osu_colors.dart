import 'package:flutter/material.dart';

/// osu! game colours, not theme roles: players read 300/100/50/miss and grades
/// by these hues. Values follow osu!lazer `OsuColour.ForHitResult` and
/// `OsuColour.ForRank` (ppy/osu, osu.Game/Graphics/OsuColour.cs).
abstract final class OsuColors {
  /// osu! brand pink (supporter tag on osu.ppy.sh).
  static const Color pink = Color(0xFFFF66AB);
  static const Color pinkLight = Color(0xFFFF9BCB);

  // Hit results.
  static const Color perfect = Color(0xFF88DDFF); // MAX / geki
  static const Color great = Color(0xFF66CCFF); // 300
  static const Color good = Color(0xFFB3D944); // 200 (mania)
  static const Color ok = Color(0xFF88B300); // 100 / 150
  static const Color meh = Color(0xFFFFCC22); // 50
  static const Color miss = Color(0xFFED1121);
  static const Color tick = Color(0xFF66CCFF);
  static const Color tickMiss = Color(0xFFFF8E5D);

  // Grades.
  static const Color rankSS = Color(0xFFDE31AE);
  static const Color rankS = Color(0xFF02B5C3);
  static const Color rankA = Color(0xFF88DA20);
  static const Color rankB = Color(0xFFE3B130);
  static const Color rankC = Color(0xFFFF8E5D);
  static const Color rankD = Color(0xFFFF5A5A);

  /// API `rank` values: XH/X (SS, silver or not), SH/S, A, B, C, D, F.
  static Color forRank(String rank) => switch (rank.toUpperCase()) {
    'XH' || 'X' || 'SS' || 'SSH' => rankSS,
    'SH' || 'S' => rankS,
    'A' => rankA,
    'B' => rankB,
    'C' => rankC,
    _ => rankD,
  };

  /// Game hues are tuned for dark backgrounds; on a light surface text needs
  /// a darker shade of the same hue to stay readable.
  static Color text(BuildContext context, Color color) =>
      Theme.of(context).brightness == Brightness.dark
      ? color
      : Color.lerp(color, Colors.black, .4)!;

  // Star rating spectrum used by osu-web (`getDiffColour`): stops in stars.
  static const List<double> _starStops = <double>[
    0.1, 1.25, 2, 2.5, 3.3, 4.2, 4.9, 5.8, 6.7, 7.7, 9,
  ];
  static const List<Color> _starColors = <Color>[
    Color(0xFF4290FB),
    Color(0xFF4FC0FF),
    Color(0xFF4FFFD5),
    Color(0xFF7CFF4F),
    Color(0xFFF6F05C),
    Color(0xFFFF8068),
    Color(0xFFFF4E6F),
    Color(0xFFC645B8),
    Color(0xFF6563DE),
    Color(0xFF18158E),
    Color(0xFF000000),
  ];

  /// Difficulty colour for a star rating, interpolated between osu-web stops.
  static Color forStars(double stars) {
    if (!stars.isFinite || stars <= _starStops.first) return _starColors.first;
    for (int i = 1; i < _starStops.length; i++) {
      if (stars <= _starStops[i]) {
        final double t =
            (stars - _starStops[i - 1]) / (_starStops[i] - _starStops[i - 1]);
        return Color.lerp(_starColors[i - 1], _starColors[i], t)!;
      }
    }
    return _starColors.last;
  }

  /// Text on a [forStars] background: osu-web switches to gold on dark stops.
  static Color onStars(double stars) =>
      stars >= 6.5 ? const Color(0xFFFFD966) : const Color(0xBF000000);
}
