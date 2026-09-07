import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

/// Bounded Scaffold-body composition. Does not own routing or business state.
final class UiFrame extends StatelessWidget {
  const UiFrame.body({
    required Widget this._child,
    this.footer,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    super.key,
  }) : _slivers = null,
       controller = null;

  /// Pass lazy SliverList/SliverGrid for dynamic data; no implicit shrinkWrap.
  const UiFrame.scroll({
    required List<Widget> this._slivers,
    this.controller,
    this.footer,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    super.key,
  }) : _child = null;

  final Widget? _child;
  final List<Widget>? _slivers;
  final ScrollController? controller;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: _slivers == null
              ? Padding(padding: padding, child: _child)
              : CustomScrollView(
                  controller: controller,
                  slivers: <Widget>[
                    SliverPadding(
                      padding: padding,
                      sliver: SliverMainAxisGroup(slivers: _slivers),
                    ),
                  ],
                ),
        ),
        if (footer != null)
          Padding(padding: const EdgeInsets.all(UiSpace.lg), child: footer),
      ],
    ),
  );
}

/// Shared heading and content spacing, without owning the section's data.
final class UiSection extends StatelessWidget {
  const UiSection({
    required this.title,
    required this.child,
    this.action,
    super.key,
  });
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: UiSpace.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.md,
      children: <Widget>[
        OverflowBar(
          spacing: UiSpace.md,
          overflowSpacing: UiSpace.sm,
          alignment: MainAxisAlignment.spaceBetween,
          overflowAlignment: OverflowBarAlignment.start,
          children: <Widget>[
            Semantics(header: true, child: UiText.titleLarge(title)),
            ?action,
          ],
        ),
        child,
      ],
    ),
  );
}
