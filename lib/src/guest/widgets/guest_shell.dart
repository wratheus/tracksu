import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/navigation/shell_reselect.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Stack and state lifetime belong to StatefulShellRoute, not tab taps.
final class GuestShell extends StatefulWidget {
  const GuestShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<GuestShell> createState() => _GuestShellState();
}

final class _GuestShellState extends State<GuestShell> {
  final ShellReselectController _reselect = ShellReselectController();

  StatefulNavigationShell get _shell => widget.navigationShell;
  static final int _searchIndex = ShellTab.find.index;

  @override
  void dispose() {
    _reselect.dispose();
    super.dispose();
  }

  void _select(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    final bool reselect = index == _shell.currentIndex;
    _shell.goBranch(index, initialLocation: reselect);
    if (!reselect) return;
    // Details are already popped by the next frame, so the root is mounted.
    // A tab switched in the meantime must not scroll a now inactive branch.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.navigationShell.currentIndex == index) {
        _reselect.request(ShellTab.values[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    // The delegate tries the active branch first. This scope belongs only
    // to the shell's root page: it does not veto a detail's native pop/swipe.
    canPop: _shell.currentIndex == 0,
    onPopInvokedWithResult: (bool didPop, _) {
      if (!didPop && _shell.currentIndex != 0) _select(0);
    },
    child: Scaffold(
      // The inner feature Scaffold handles keyboard insets once.
      resizeToAvoidBottomInset: false,
      body: ShellReselectScope(controller: _reselect, child: _shell),
      bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : UiNavigationBar(
              // The last branch is search: its own round button.
              selectedIndex: _shell.currentIndex == _searchIndex
                  ? null
                  : _shell.currentIndex,
              onSelected: _select,
              search: context.t.navigationSearch,
              searchSelected: _shell.currentIndex == _searchIndex,
              onSearch: () => _select(_searchIndex),
              items: <UiNavigationItem>[
                UiNavigationItem(
                  label: context.t.navigationHome,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                ),
                UiNavigationItem(
                  label: context.t.rankingsTitle,
                  icon: Icons.leaderboard_outlined,
                  selectedIcon: Icons.leaderboard,
                ),
                UiNavigationItem(
                  label: context.t.hubTitle,
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore,
                ),
              ],
            ),
    ),
  );
}
