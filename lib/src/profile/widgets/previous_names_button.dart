import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class PreviousNamesButton extends StatefulWidget {
  const PreviousNamesButton({required this.names, super.key});
  final List<String> names;
  @override
  State<PreviousNamesButton> createState() => _PreviousNamesButtonState();
}

final class _PreviousNamesButtonState extends State<PreviousNamesButton> {
  bool _open = false;
  Future<void> _show() async {
    if (_open) return;
    final List<String> names = widget.names;
    setState(() => _open = true);
    try {
      await UiModal.scrollable<void>(
        context,
        title: context.t.profilePreviousNames,
        // Same rows as the other sheets, static (nothing to choose).
        builder: (_) => ListView.separated(
          primary: true,
          padding: const EdgeInsets.fromLTRB(
            UiSpace.lg,
            0,
            UiSpace.lg,
            UiSpace.lg,
          ),
          itemCount: names.length,
          separatorBuilder: (_, _) => const SizedBox(height: UiSpace.sm),
          itemBuilder: (BuildContext context, int index) => UiOptionRow(
            label: names[index],
            icon: Icons.history_rounded,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) => UiIconButton.standard(
    tooltip: context.t.profilePreviousNames,
    icon: Icons.badge_outlined,
    onPressed: _open ? null : _show,
  );
}
