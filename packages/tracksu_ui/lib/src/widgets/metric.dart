import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

final class UiMetric extends StatelessWidget {
  const UiMetric({
    required this.label,
    required this.value,
    this.detail,
    super.key,
  });
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: UiSpace.xs,
      children: <Widget>[
        UiText.bodySmall(label, secondary: true),
        UiText.metric(value),
        if (detail != null) UiText.bodySmall(detail!, secondary: true),
      ],
    ),
  );
}

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
