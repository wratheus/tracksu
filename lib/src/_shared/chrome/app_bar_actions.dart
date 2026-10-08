import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/account_button.dart';
import 'package:tracksu/src/_shared/preferences/settings_button.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// The one trailing action set every AppBar uses, in a fixed order so the
/// controls never move between tabs and pages:
/// search · share · settings · account. Search is a pill ("Search" on root
/// tabs, icon only on pushed pages) that grows into the search screen's
/// field; the search screen itself passes [search] false.
/// Pages refresh by pull-to-refresh, not by an AppBar button.
///
/// [share] may be null while the page has nothing to share yet; the button is
/// then shown disabled rather than removed, keeping the positions stable.
final class AppBarActions extends StatelessWidget {
  const AppBarActions({required this.share, this.search = true, super.key});

  /// Builds the share target from the page state; null disables sharing.
  final ShareTarget? share;
  final bool search;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      if (search)
        UiSearchPill(
          label: context.t.navigationSearch,
          onPressed: () {
            // One push per tap: the page behind search ignores repeats.
            if (!(ModalRoute.isCurrentOf(context) ?? true)) return;
            unawaited(DepsScope.of(context).appRouter.openSearch(context));
          },
        ),
      ShareButton.icon(target: share),
      const SettingsButton(),
      const AccountButton(),
    ],
  );
}
