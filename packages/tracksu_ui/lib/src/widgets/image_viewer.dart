import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/widgets/icon_button.dart';

/// Displays an already decoded image; never fetches URLs or owns credentials.
abstract final class UiImageViewer {
  static Future<void> show(
    BuildContext context, {
    required ui.Image image,
    required String closeLabel,
    required String imageLabel,
  }) async {
    final ui.Image owned = image.clone();
    try {
      final DialogRoute<void> route = DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => Dialog.fullscreen(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: UiIconButton.standard(
                    icon: Icons.close,
                    tooltip: closeLabel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    maxScale: 5,
                    child: Center(
                      child: Semantics(
                        image: true,
                        label: imageLabel,
                        child: RawImage(image: owned, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await Navigator.of(context, rootNavigator: true).push(route);
      // pop's future completes before the exit animation/overlay disposal.
      await route.completed;
    } finally {
      owned.dispose();
    }
  }
}
