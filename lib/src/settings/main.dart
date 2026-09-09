import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/widgets/content_media_settings.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key});
  @override
  State<SettingsMain> createState() => _SettingsMainState();
}

final class _SettingsMainState extends State<SettingsMain> {
  bool _busy = false;
  Future<void> _logout() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bool confirmed = await UiModal.destructive(
        context,
        title: context.t.signOut,
        message: context.t.settingsSignOutConfirm,
        confirmLabel: context.t.signOut,
        cancelLabel: MaterialLocalizations.of(context).cancelButtonLabel,
      );
      if (!mounted || !confirmed) return;
      await DepsScope.of(context).authRepository.logout();
    } on Object {
      if (mounted) UiFeedback.snack(context, message: context.t.signOutFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deps = DepsScope.of(context);
    return Scaffold(
      appBar: AppBar(title: UiText.titleLarge(context.t.settingsTitle)),
      body: UiFrame.scroll(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: UiSection(
              title: context.t.account,
              child: StreamBuilder<SessionStatus>(
                stream: deps.sessionController.statusChanges,
                initialData: deps.sessionController.status,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<SessionStatus> snapshot,
                    ) {
                      final bool authenticated =
                          snapshot.data == SessionStatus.authenticated;
                      return UiSurface.card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: UiSpace.sm,
                          children: <Widget>[
                            if (authenticated)
                              UiTile.navigation(
                                title: context.t.viewMyProfile,
                                leading: const Icon(Icons.person_outline),
                                onTap: () =>
                                    deps.appRouter.openCurrentProfile(context),
                              ),
                            UiTile.navigation(
                              title: authenticated
                                  ? context.t.signInWithAnotherAccount
                                  : context.t.signInWithOsu,
                              leading: const Icon(Icons.login),
                              onTap: () => deps.appRouter.openLogin(context),
                            ),
                            if (authenticated)
                              UiButton.destructive(
                                label: context.t.signOut,
                                onPressed: _busy ? null : _logout,
                              ),
                          ],
                        ),
                      );
                    },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: UiSpace.lg),
              child: UiSurface.card(
                child: UiSection(
                  title: context.t.contentMediaSettings,
                  child: ContentMediaSettings(
                    controller: deps.contentMediaController,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
