import 'package:flutter/material.dart';

final class UiNavigationItem {
  const UiNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

/// Theme-driven destinations; the app owns stacks and selection policy.
final class UiNavigationBar extends StatelessWidget {
  const UiNavigationBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<UiNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    destinations: <Widget>[
      for (final UiNavigationItem item in items)
        NavigationDestination(
          label: item.label,
          tooltip: item.label,
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon ?? item.icon),
        ),
    ],
  );
}
