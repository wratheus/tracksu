import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// The app's on/off control: a chamfered track (the shape of segmented
/// controls) with a chamfered thumb that slides and settles with a short
/// overshoot; the track fills with the accent when on. 48 pt target.
final class UiSwitch extends StatelessWidget {
  const UiSwitch({
    required this.value,
    required this.onChanged,
    this.semanticsLabel,
    super.key,
  });
  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;
  final String? semanticsLabel;

  static const double width = 52;
  static const double height = 30;
  static const double _thumb = 22;
  static const double _inset = (height - _thumb) / 2;

  static BeveledRectangleBorder _shape(double cut) => BeveledRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(cut),
      bottomRight: Radius.circular(cut),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool enabled = onChanged != null;
    final Duration duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);
    return Semantics(
      toggled: value,
      enabled: enabled,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: !enabled
            ? null
            : () {
                _haptic();
                onChanged!(!value);
              },
        child: SizedBox(
          width: UiShape.minTarget + UiSpace.xs,
          height: UiShape.minTarget,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.45,
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: width,
                height: height,
                decoration: ShapeDecoration(
                  shape: _shape(UiSpace.sm).copyWith(
                    side: BorderSide(
                      color: value
                          ? colors.primary.withValues(alpha: 0.6)
                          : colors.onSurface.withValues(alpha: 0.16),
                    ),
                  ),
                  color: value
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                ),
                child: AnimatedAlign(
                  duration: duration,
                  curve: Curves.easeOutBack,
                  alignment: value
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.all(_inset),
                    child: AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      width: _thumb,
                      height: _thumb,
                      decoration: ShapeDecoration(
                        shape: _shape(UiSpace.xs + 2),
                        color: value ? colors.primary : colors.outline,
                        shadows: <BoxShadow>[
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: duration,
                        child: Icon(
                          value ? Icons.check_rounded : Icons.close_rounded,
                          key: ValueKey<bool>(value),
                          size: 14,
                          color: value
                              ? colors.onPrimary
                              : colors.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _haptic() {
    // A light tick, as native switches give; failures are irrelevant.
    HapticFeedback.selectionClick().ignore();
  }
}
