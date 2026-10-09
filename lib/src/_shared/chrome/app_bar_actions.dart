import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/chrome/account_button.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';

/// The trailing actions every AppBar uses: share · account, and on pages
/// shown per game mode the mode first (ADR-011): mode · share · account. Settings and sign-in live in the account menu;
/// search is the separate search tab in the bottom bar. Pages refresh by
/// pull-to-refresh, not by an AppBar button.
///
/// [share] may be null while the page has nothing to share yet; the button is
/// then shown disabled rather than removed, keeping the positions stable.
final class AppBarActions extends StatelessWidget {
  const AppBarActions({required this.share, this.ruleset, super.key});

  /// Builds the share target from the page state; null disables sharing.
  final ShareTarget? share;

  /// A `RulesetButton` on pages shown per game mode; null elsewhere.
  final Widget? ruleset;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ?ruleset,
      ShareButton.icon(target: share),
      const AccountButton(),
    ],
  );
}
