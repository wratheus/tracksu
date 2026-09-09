import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/sharing/share_destination.dart';
import 'package:tracksu/src/_shared/sharing/share_sheet.dart';
import 'package:tracksu/src/_shared/sharing/share_service.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// App composition of UI kit controls; platform sharing stays out of the UI kit.
final class ShareButton extends StatefulWidget {
  const ShareButton.icon({required this.target, this.label, super.key})
    : _labelled = false;
  const ShareButton.labelled({required this.target, this.label, super.key})
    : _labelled = true;
  final ShareTarget target;
  final String? label;
  final bool _labelled;

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

final class _ShareButtonState extends State<ShareButton> {
  bool _busy = false;

  Future<void> _share() async {
    if (_busy) return;
    final ShareTarget target = widget.target;
    final ShareService service = DepsScope.of(context).shareService;
    FocusScope.of(context).unfocus();
    final RenderObject? render = context.findRenderObject();
    final Rect? origin = render is RenderBox && render.hasSize
        ? render.localToGlobal(Offset.zero) & render.size
        : null;
    setState(() => _busy = true);
    try {
      final ShareDestination? destination =
          await UiModal.scrollable<ShareDestination>(
            context,
            title: context.t.shareAction,
            builder: (_) => ShareSheet(target: target),
          );
      if (!mounted || destination == null) return;
      await service.share(target, destination: destination, origin: origin);
      if (mounted && destination == ShareDestination.copy) {
        UiFeedback.snack(context, message: context.t.shareCopied);
      }
    } on Object {
      if (mounted) UiFeedback.snack(context, message: context.t.shareFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = Theme.of(context).platform == TargetPlatform.iOS
        ? Icons.ios_share
        : Icons.share_outlined;
    return widget._labelled
        ? UiButton.secondary(
            label: widget.label ?? context.t.shareAction,
            icon: icon,
            onPressed: _busy ? null : _share,
          )
        : UiIconButton.standard(
            tooltip: widget.label ?? context.t.shareAction,
            icon: icon,
            onPressed: _busy ? null : _share,
          );
  }
}
