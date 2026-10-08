import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/chrome/account_button.dart';
import 'package:tracksu/src/_shared/preferences/settings_button.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';

/// The one trailing action set every AppBar uses, in a fixed order so the
/// controls never move between tabs and pages: share · settings · account.
/// Pages refresh by pull-to-refresh, not by an AppBar button.
///
/// [share] may be null while the page has nothing to share yet; the button is
/// then shown disabled rather than removed, keeping the positions stable.
final class AppBarActions extends StatelessWidget {
  const AppBarActions({required this.share, super.key});

  /// Builds the share target from the page state; null disables sharing.
  final ShareTarget? share;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ShareButton.icon(target: share),
      const SettingsButton(),
      const AccountButton(),
    ],
  );
}
