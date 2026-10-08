import 'package:flutter/material.dart';

/// Shared page chrome. Features own the title, actions and tab controller.
/// Keeping tabs in the bottom slot leaves each page's scroll view independent.
final class UiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UiAppBar({
    required this.title,
    this.actions,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
    super.key,
  });
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) => AppBar(
    title: title,
    actions: actions,
    bottom: bottom,
    toolbarHeight: toolbarHeight,
    centerTitle: false,
  );
}
