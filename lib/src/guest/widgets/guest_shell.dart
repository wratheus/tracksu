import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Stack and state lifetime belong to StatefulShellRoute, not tab taps.
final class GuestShell extends StatelessWidget {
  const GuestShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    // The delegate tries the active branch first. This scope belongs only
    // to the shell's root page: it does not veto a detail's native pop/swipe.
    canPop: navigationShell.currentIndex == 0,
    onPopInvokedWithResult: (bool didPop, _) {
      if (!didPop && navigationShell.currentIndex != 0) _select(0);
    },
    child: Scaffold(
      // The inner feature Scaffold handles keyboard insets once.
      resizeToAvoidBottomInset: false,
      body: navigationShell,
      bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : UiNavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onSelected: _select,
              items: <UiNavigationItem>[
                UiNavigationItem(
                  label: context.t.navigationSearch,
                  icon: Icons.search,
                ),
                UiNavigationItem(
                  label: context.t.rankingsTitle,
                  icon: Icons.leaderboard_outlined,
                  selectedIcon: Icons.leaderboard,
                ),
                UiNavigationItem(
                  label: context.t.newsTitle,
                  icon: Icons.newspaper_outlined,
                  selectedIcon: Icons.newspaper,
                ),
              ],
            ),
    ),
  );
}
