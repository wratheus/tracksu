import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Settings are local: account/profile requests must never disable this action.
final class SettingsButton extends StatefulWidget {
  const SettingsButton({super.key});
  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

final class _SettingsButtonState extends State<SettingsButton> {
  bool _opening = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Branch-root navigation can remove a pushed page without returning through
    // this widget's original await. A visible route must remain usable.
    if (ModalRoute.isCurrentOf(context) ?? true) _opening = false;
  }

  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await DepsScope.of(context).appRouter.openSettings(context);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => UiIconButton.standard(
    tooltip: context.t.settingsTitle,
    icon: Icons.settings_outlined,
    onPressed: _opening ? null : _open,
  );
}
