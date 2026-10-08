import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/content_media_controller.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Images are on by default; users can opt out in settings. One toggle row,
/// the explanation is the group's footnote (like the cache group).
final class ContentMediaSettings extends StatelessWidget {
  const ContentMediaSettings({required this.controller, super.key});
  final ContentMediaController controller;

  Future<void> _select(BuildContext context, bool allowed) async {
    try {
      await controller.select(allowed);
    } on Object {
      if (context.mounted) {
        UiFeedback.snack(context, message: context.t.contentMediaSaveFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (BuildContext context, _) => UiTile.toggle(
      title: context.t.contentMediaSettings,
      leading: const UiTileIcon(Icons.image_outlined),
      selected: controller.allowed,
      onToggle: controller.saving
          ? null
          : (bool value) => _select(context, value),
    ),
  );
}
