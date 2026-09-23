import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/content_media_controller.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Images are on by default; users can opt out in settings.
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
    builder: (BuildContext context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.md,
      children: <Widget>[
        UiText.bodyMedium(context.t.contentMediaConsent),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: UiText.bodyMedium(context.t.contentMediaSettings),
          value: controller.allowed,
          onChanged: controller.saving
              ? null
              : (bool value) => _select(context, value),
        ),
        if (controller.saving) const LinearProgressIndicator(),
      ],
    ),
  );
}
