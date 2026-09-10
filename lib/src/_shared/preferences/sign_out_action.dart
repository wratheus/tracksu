import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Both account entry points use the same explicit, cancellable confirmation.
abstract final class SignOutAction {
  static Future<void> show(BuildContext context) async {
    final bool confirmed = await UiModal.destructive(
      context,
      title: context.t.signOut,
      message: context.t.settingsSignOutConfirm,
      confirmLabel: context.t.signOut,
      cancelLabel: MaterialLocalizations.of(context).cancelButtonLabel,
    );
    if (!context.mounted || !confirmed) return;
    try {
      await DepsScope.of(context).authRepository.logout();
    } on Object {
      if (context.mounted) {
        UiFeedback.snack(context, message: context.t.signOutFailed);
      }
    }
  }
}
