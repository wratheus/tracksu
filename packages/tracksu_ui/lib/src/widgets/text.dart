import 'package:flutter/material.dart';

enum _TextPreset {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  metric,
}

/// Material presets with theme-owned sizing and optional presentation overrides.
final class UiText extends StatelessWidget {
  const UiText.displayLarge(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.displayLarge;

  const UiText.displayMedium(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.displayMedium;

  const UiText.displaySmall(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.displaySmall;

  const UiText.headlineLarge(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.headlineLarge;

  const UiText.headlineMedium(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.headlineMedium;

  const UiText.headlineSmall(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.headlineSmall;

  const UiText.titleLarge(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.titleLarge;

  const UiText.titleMedium(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.titleMedium;

  const UiText.titleSmall(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.titleSmall;

  const UiText.bodyLarge(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.bodyLarge;

  const UiText.bodyMedium(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.bodyMedium;

  const UiText.bodySmall(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.bodySmall;

  const UiText.labelLarge(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.labelLarge;

  const UiText.labelMedium(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.labelMedium;

  const UiText.labelSmall(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.labelSmall;

  const UiText.metric(
    this.data, {
    super.key,
    this.color,
    this.secondary = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : _preset = _TextPreset.metric;

  final String data;
  final _TextPreset _preset;
  final Color? color;
  final bool secondary;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? preset = switch (_preset) {
      _TextPreset.displayLarge => theme.textTheme.displayLarge,
      _TextPreset.displayMedium => theme.textTheme.displayMedium,
      _TextPreset.displaySmall => theme.textTheme.displaySmall,
      _TextPreset.headlineLarge => theme.textTheme.headlineLarge,
      _TextPreset.headlineMedium => theme.textTheme.headlineMedium,
      _TextPreset.headlineSmall => theme.textTheme.headlineSmall,
      _TextPreset.titleLarge => theme.textTheme.titleLarge,
      _TextPreset.titleMedium => theme.textTheme.titleMedium,
      _TextPreset.titleSmall => theme.textTheme.titleSmall,
      _TextPreset.bodyLarge => theme.textTheme.bodyLarge,
      _TextPreset.bodyMedium => theme.textTheme.bodyMedium,
      _TextPreset.bodySmall => theme.textTheme.bodySmall,
      _TextPreset.labelLarge => theme.textTheme.labelLarge,
      _TextPreset.labelMedium => theme.textTheme.labelMedium,
      _TextPreset.labelSmall => theme.textTheme.labelSmall,
      _TextPreset.metric => theme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    };
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines == null ? null : TextOverflow.ellipsis),
      semanticsLabel: semanticsLabel,
      style: preset?.copyWith(
        color:
            color ??
            (secondary
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface),
      ),
    );
  }
}
