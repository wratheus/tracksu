import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

final class UiMetric extends StatelessWidget {
  const UiMetric({
    required this.label,
    required this.value,
    this.detail,
    this.icon,
    this.tone = UiMetricTone.neutral,
    super.key,
  }) : _layout = _MetricLayout.featured;
  const UiMetric.compact({
    required this.label,
    required this.value,
    this.detail,
    this.icon,
    this.tone = UiMetricTone.neutral,
    super.key,
  }) : _layout = _MetricLayout.compact;
  const UiMetric.row({
    required this.label,
    required this.value,
    this.detail,
    this.icon,
    this.tone = UiMetricTone.neutral,
    super.key,
  }) : _layout = _MetricLayout.row;
  final String label;
  final String value;
  final String? detail;
  final IconData? icon;
  final UiMetricTone tone;
  final _MetricLayout _layout;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color valueColor = switch (tone) {
      UiMetricTone.neutral => colors.onSurface,
      UiMetricTone.primary => colors.primary,
      UiMetricTone.secondary => colors.secondary,
      UiMetricTone.tertiary => colors.tertiary,
    };
    final Widget heading = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: UiSpace.sm,
      children: <Widget>[
        if (icon != null)
          ExcludeSemantics(
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        Expanded(child: UiText.bodySmall(label, secondary: true)),
      ],
    );
    if (_layout == _MetricLayout.row) {
      return MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: UiSpace.md,
          children: <Widget>[
            if (icon != null)
              ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.only(top: UiSpace.xs),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: UiSpace.xs,
                children: <Widget>[
                  UiText.bodySmall(label, secondary: true),
                  UiText.titleMedium(value, color: valueColor),
                  if (detail != null)
                    UiText.bodySmall(detail!, secondary: true),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: UiSpace.xs,
        children: <Widget>[
          heading,
          if (_layout == _MetricLayout.featured)
            UiText.metric(value, color: valueColor)
          else
            UiText.titleMedium(value, color: valueColor),
          if (detail != null) UiText.bodySmall(detail!, secondary: true),
        ],
      ),
    );
  }
}

enum _MetricLayout { featured, compact, row }

enum UiMetricTone { neutral, primary, secondary, tertiary }

/// A short group of statistics, not an API-backed grid/list.
final class UiMetricGroup extends StatelessWidget {
  const UiMetricGroup({required this.children, super.key});
  final List<UiMetric> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final double minimum =
          144 * MediaQuery.textScalerOf(context).scale(14) / 14;
      final int columns = constraints.maxWidth >= minimum * 2 + UiSpace.lg
          ? 2
          : 1;
      final double width =
          (constraints.maxWidth - (columns - 1) * UiSpace.lg) / columns;
      return Wrap(
        spacing: UiSpace.lg,
        runSpacing: UiSpace.lg,
        children: children
            .map((UiMetric child) => SizedBox(width: width, child: child))
            .toList(growable: false),
      );
    },
  );
}
