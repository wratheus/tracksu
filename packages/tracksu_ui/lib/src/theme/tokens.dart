import 'package:flutter/material.dart';

abstract final class UiSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class UiShape {
  static const double control = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double minTarget = 48;
}

/// Status roles, not osu! score grades. All pairs support text on container.
@immutable
final class UiStatusColors extends ThemeExtension<UiStatusColors> {
  const UiStatusColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;

  @override
  UiStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
  }) => UiStatusColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
  );

  @override
  UiStatusColors lerp(covariant UiStatusColors? other, double t) {
    if (other == null) return this;
    return UiStatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}
