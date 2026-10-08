import 'package:flutter/material.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// osu! mod categories with the colours osu!lazer uses for them
/// (`OsuColour.ForModType`).
enum OsuModType {
  reduction(Color(0xFFB2FF66)),
  increase(Color(0xFFFF6666)),
  conversion(Color(0xFF8C66FF)),
  automation(Color(0xFF66CCFF)),
  fun(Color(0xFFFF66AB)),
  system(Color(0xFFFFCC22));

  const OsuModType(this.colour);
  final Color colour;
}

/// Display data for one mod acronym. Names are osu!'s proper names and
/// stay in English, like the acronyms (API content, not UI copy).
@immutable
final class OsuModInfo {
  const OsuModInfo(this.name, this.type, this.icon);
  final String name;
  final OsuModType type;

  /// File in `assets/icon_mods/` (official osu-resources glyph), or null.
  final String? icon;

  static OsuModInfo? of(String acronym) => _mods[acronym.toUpperCase()];

  static const Map<String, OsuModInfo> _mods = <String, OsuModInfo>{
    // Difficulty reduction
    'EZ': OsuModInfo('Easy', OsuModType.reduction, 'easy'),
    'NF': OsuModInfo('No Fail', OsuModType.reduction, 'no-fail'),
    'HT': OsuModInfo('Half Time', OsuModType.reduction, 'half-time'),
    'DC': OsuModInfo('Daycore', OsuModType.reduction, 'daycore'),
    'NR': OsuModInfo('No Release', OsuModType.reduction, 'no-release'),
    // Difficulty increase
    'HR': OsuModInfo('Hard Rock', OsuModType.increase, 'hard-rock'),
    'SD': OsuModInfo('Sudden Death', OsuModType.increase, 'sudden-death'),
    'PF': OsuModInfo('Perfect', OsuModType.increase, 'perfect'),
    'DT': OsuModInfo('Double Time', OsuModType.increase, 'double-time'),
    'NC': OsuModInfo('Nightcore', OsuModType.increase, 'nightcore'),
    'HD': OsuModInfo('Hidden', OsuModType.increase, 'hidden'),
    'FI': OsuModInfo('Fade In', OsuModType.increase, 'fade-in'),
    'CO': OsuModInfo('Cover', OsuModType.increase, 'cover'),
    'FL': OsuModInfo('Flashlight', OsuModType.increase, 'flashlight'),
    'BL': OsuModInfo('Blinds', OsuModType.increase, 'blinds'),
    'ST': OsuModInfo('Strict Tracking', OsuModType.increase, 'strict-tracking'),
    'AC': OsuModInfo(
      'Accuracy Challenge',
      OsuModType.increase,
      'accuracy-challenge',
    ),
    'TC': OsuModInfo('Traceable', OsuModType.increase, 'traceable'),
    // Conversion
    'TP': OsuModInfo(
      'Target Practice',
      OsuModType.conversion,
      'target-practice',
    ),
    'DA': OsuModInfo(
      'Difficulty Adjust',
      OsuModType.conversion,
      'difficulty-adjust',
    ),
    'CL': OsuModInfo('Classic', OsuModType.conversion, 'classic'),
    'RD': OsuModInfo('Random', OsuModType.conversion, 'random'),
    'MR': OsuModInfo('Mirror', OsuModType.conversion, 'mirror'),
    'AL': OsuModInfo('Alternate', OsuModType.conversion, 'alternate'),
    'SG': OsuModInfo('Single Tap', OsuModType.conversion, 'single-tap'),
    'IN': OsuModInfo('Invert', OsuModType.conversion, 'invert'),
    'CS': OsuModInfo('Constant Speed', OsuModType.conversion, 'constant-speed'),
    'HO': OsuModInfo('Hold Off', OsuModType.conversion, 'hold-off'),
    'DS': OsuModInfo('Dual Stages', OsuModType.conversion, 'dual-stages'),
    'SW': OsuModInfo('Swap', OsuModType.conversion, 'swap'),
    'FF': OsuModInfo(
      'Floating Fruits',
      OsuModType.conversion,
      'floating-fruits',
    ),
    'SR': OsuModInfo(
      'Simplified Rhythm',
      OsuModType.conversion,
      'simplified-rhythm',
    ),
    '1K': OsuModInfo('One Key', OsuModType.conversion, 'one-key'),
    '2K': OsuModInfo('Two Keys', OsuModType.conversion, 'two-keys'),
    '3K': OsuModInfo('Three Keys', OsuModType.conversion, 'three-keys'),
    '4K': OsuModInfo('Four Keys', OsuModType.conversion, 'four-keys'),
    '5K': OsuModInfo('Five Keys', OsuModType.conversion, 'five-keys'),
    '6K': OsuModInfo('Six Keys', OsuModType.conversion, 'six-keys'),
    '7K': OsuModInfo('Seven Keys', OsuModType.conversion, 'seven-keys'),
    '8K': OsuModInfo('Eight Keys', OsuModType.conversion, 'eight-keys'),
    '9K': OsuModInfo('Nine Keys', OsuModType.conversion, 'nine-keys'),
    '10K': OsuModInfo('Ten Keys', OsuModType.conversion, 'ten-keys'),
    // Automation
    'AT': OsuModInfo('Autoplay', OsuModType.automation, 'autoplay'),
    'CN': OsuModInfo('Cinema', OsuModType.automation, 'cinema'),
    'RX': OsuModInfo('Relax', OsuModType.automation, 'relax'),
    'AP': OsuModInfo('Autopilot', OsuModType.automation, 'autopilot'),
    'SO': OsuModInfo('Spun Out', OsuModType.automation, 'spun-out'),
    // Fun
    'TR': OsuModInfo('Transform', OsuModType.fun, 'transform'),
    'WG': OsuModInfo('Wiggle', OsuModType.fun, 'wiggle'),
    'SI': OsuModInfo('Spin In', OsuModType.fun, 'spin-in'),
    'GR': OsuModInfo('Grow', OsuModType.fun, 'grow'),
    'DF': OsuModInfo('Deflate', OsuModType.fun, 'deflate'),
    'WU': OsuModInfo('Wind Up', OsuModType.fun, 'wind-up'),
    'WD': OsuModInfo('Wind Down', OsuModType.fun, 'wind-down'),
    'BR': OsuModInfo('Barrel Roll', OsuModType.fun, 'barrel-roll'),
    'AD': OsuModInfo(
      'Approach Different',
      OsuModType.fun,
      'approach-different',
    ),
    'MU': OsuModInfo('Muted', OsuModType.fun, 'muted'),
    'NS': OsuModInfo('No Scope', OsuModType.fun, 'no-scope'),
    'MG': OsuModInfo('Magnetised', OsuModType.fun, 'magnetised'),
    'RP': OsuModInfo('Repel', OsuModType.fun, 'repel'),
    'AS': OsuModInfo('Adaptive Speed', OsuModType.fun, 'adaptive-speed'),
    'FR': OsuModInfo('Freeze Frame', OsuModType.fun, 'freeze-frame'),
    'BU': OsuModInfo('Bubbles', OsuModType.fun, 'bubbles'),
    'SY': OsuModInfo('Synesthesia', OsuModType.fun, 'synesthesia'),
    'DP': OsuModInfo('Depth', OsuModType.fun, 'depth'),
    'BM': OsuModInfo('Bloom', OsuModType.fun, 'bloom'),
    'MF': OsuModInfo('Moving Fast', OsuModType.fun, 'moving-fast'),
    // System
    'TD': OsuModInfo('Touch Device', OsuModType.system, 'touch-device'),
    'SV2': OsuModInfo('Score V2', OsuModType.system, 'score-v2'),
  };
}

/// The osu! mod icon: official rounded hexagon tinted with the mod type
/// colour and the dark glyph on top, as in osu!lazer. Unknown acronyms get a
/// neutral shape so future mods stay visible next to their name.
final class OsuModIcon extends StatelessWidget {
  const OsuModIcon({required this.acronym, this.height = 16, super.key});

  /// Shape used for "no mods".
  const OsuModIcon.none({this.height = 16, super.key}) : acronym = null;

  final String? acronym;
  final double height;

  // Official asset proportions: shape 135×100, glyph 120×84.
  static const double _shapeRatio = 135 / 100;
  static const double _glyphRatio = 120 / 84;

  @override
  Widget build(BuildContext context) {
    final OsuModInfo? info = acronym == null ? null : OsuModInfo.of(acronym!);
    final String? glyph = acronym == null ? 'no-mod' : info?.icon;
    final Color shape =
        info?.type.colour ?? Theme.of(context).colorScheme.outline;
    final Color ink = Color.lerp(shape, Colors.black, .78)!;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final double width = height * _shapeRatio;
    final double glyphHeight = height * .62;
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset(
              'assets/icon_mods/mod-icon.png',
              width: width,
              height: height,
              cacheWidth: (width * dpr).ceil(),
              color: shape,
              colorBlendMode: BlendMode.srcIn,
            ),
            if (glyph != null)
              Image.asset(
                'assets/icon_mods/$glyph.png',
                width: glyphHeight * _glyphRatio,
                height: glyphHeight,
                cacheWidth: (glyphHeight * _glyphRatio * dpr).ceil(),
                color: ink,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small mod chips: icon + acronym; the full name is the tooltip and the
/// accessibility label. Acronyms are API content, not translated UI.
final class OsuMods extends StatelessWidget {
  const OsuMods({required this.mods, required this.emptyLabel, super.key});
  final List<String> mods;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: UiSpace.xs,
    runSpacing: UiSpace.xs,
    children: mods.isEmpty
        ? <Widget>[_ModChip(icon: const OsuModIcon.none(), label: emptyLabel)]
        : <Widget>[
            for (final String mod in mods)
              Tooltip(
                message: OsuModInfo.of(mod)?.name ?? mod,
                child: Semantics(
                  label: OsuModInfo.of(mod)?.name ?? mod,
                  excludeSemantics: true,
                  child: _ModChip(
                    icon: OsuModIcon(acronym: mod),
                    label: mod.toUpperCase(),
                  ),
                ),
              ),
          ],
  );
}

final class _ModChip extends StatelessWidget {
  const _ModChip({required this.icon, required this.label});
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UiSpace.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(UiSpace.xs, 3, UiSpace.sm, 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: UiSpace.xs,
          children: <Widget>[
            icon,
            Text(
              label,
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
