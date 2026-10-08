import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/chrome/account_button.dart';
import 'package:tracksu/src/_shared/preferences/settings_button.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';

/// The one trailing action set every AppBar uses, in a fixed order so the
/// controls never move between tabs and pages:
/// share · page tools (e.g. refresh) · settings · account.
///
/// [share] may be null while the page has nothing to share yet; the button is
/// then shown disabled rather than removed, keeping the positions stable.
final class AppBarActions extends StatelessWidget {
  const AppBarActions({required this.share, this.tools = const [], super.key});

  /// Builds the share target from the page state; null disables sharing.
  final ShareTarget? share;

  /// Page-specific controls placed between share and settings.
  final List<Widget> tools;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ShareButton.icon(target: share),
      ...tools,
      const SettingsButton(),
      const AccountButton(),
    ],
  );
}
