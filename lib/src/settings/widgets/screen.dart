import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/widgets/content_media_settings.dart';
import 'package:tracksu/src/_shared/preferences/language_picker.dart';
import 'package:tracksu/src/_shared/preferences/sign_out_action.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  Future<void> _clearCache() async {
    final bool clear = await UiModal.confirm(
      context,
      title: context.t.settingsClearCache,
      message: context.t.settingsCacheDescription,
      confirmLabel: context.t.settingsClearCache,
      cancelLabel: MaterialLocalizations.of(context).cancelButtonLabel,
    );
    if (!mounted || !clear) return;
    final deps = DepsScope.of(context);
    deps.pageCache.clear();
    deps.contentMediaController.cache.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    UiFeedback.snack(context, message: context.t.settingsCacheCleared);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selectTheme() async {
    final controller = DepsScope.of(context).themeController;
    final ThemeMode? selected = await UiModal.selection<ThemeMode>(
      context,
      title: context.t.settingsTheme,
      selected: controller.value,
      choices: <UiChoice<ThemeMode>>[
        for (final ThemeMode mode in ThemeMode.values)
          UiChoice<ThemeMode>(
            value: mode,
            label: _themeLabel(context, mode),
            icon: _themeIcon(mode),
          ),
      ],
    );
    if (!mounted || selected == null) return;
    try {
      await controller.select(selected);
    } on Object {
      if (mounted) {
        UiFeedback.snack(context, message: context.t.settingsThemeSaveFailed);
      }
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: UiSpace.xl,
                      children: <Widget>[
                        UiSurface.tonal(
                          padding: const EdgeInsets.all(UiSpace.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: UiSpace.md,
                            children: <Widget>[
                              Icon(
                                authenticated
                                    ? Icons.verified_user_outlined
                                    : Icons.explore_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                              UiText.headlineSmall(
                                authenticated
                                    ? context.t.account
                                    : context.t.guestModeTitle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                              UiText.bodyMedium(
                                authenticated
                                    ? context.t.guestSignedInDescription
                                    : context.t.guestSignedOutDescription,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            ],
                          ),
                        ),
                        _SettingsGroup(
                          title: context.t.account,
                          children: <Widget>[
                            if (authenticated)
                              UiTile.navigation(
                                title: context.t.viewMyProfile,
                                leading: const Icon(Icons.person_outline),
                                onTap: _busy
                                    ? null
                                    : () => _run(
                                        () => deps.appRouter.openCurrentProfile(
                                          context,
                                        ),
                                      ),
                              ),
                            UiTile.navigation(
                              title: authenticated
                                  ? context.t.signInWithAnotherAccount
                                  : context.t.signInWithOsu,
                              leading: const Icon(Icons.login),
                              onTap: _busy
                                  ? null
                                  : () => _run(
                                      () => deps.appRouter.openLogin(context),
                                    ),
                            ),
                          ],
                        ),
                        _SettingsGroup(
                          title: context.t.settingsAppearance,
                          children: <Widget>[
                            ValueListenableBuilder<Locale?>(
                              valueListenable: deps.localeController,
                              builder:
                                  (
                                    BuildContext context,
                                    Locale? locale,
                                    _,
                                  ) => UiTile.navigation(
                                    title: context.t.languageSelection,
                                    subtitle: AppLanguage.fromLocale(locale)
                                        .label(context.t),
                                    leading: AppLanguageIcon(
                                      language: AppLanguage.fromLocale(locale),
                                    ),
                                    onTap: _busy
                                        ? null
                                        : () => _run(
                                            () => LanguagePicker.show(context),
                                          ),
                                  ),
                            ),
                            const Divider(
                              height: 1,
                              indent: UiSpace.lg,
                              endIndent: UiSpace.lg,
                            ),
                            ValueListenableBuilder<ThemeMode>(
                              valueListenable: deps.themeController,
                              builder:
                                  (BuildContext context, ThemeMode mode, _) =>
                                      UiTile.navigation(
                                        title: context.t.settingsTheme,
                                        subtitle: _themeLabel(context, mode),
                                        leading: Icon(_themeIcon(mode)),
                                        onTap: _busy
                                            ? null
                                            : () => _run(_selectTheme),
                                      ),
                            ),
                          ],
                        ),
                        UiSection(
                          title: context.t.contentMediaSettings,
                          child: UiSurface.card(
                            child: ContentMediaSettings(
                              controller: deps.contentMediaController,
                            ),
                          ),
                        ),
                        if (authenticated)
                          UiButton.destructive(
                            label: context.t.signOut,
                            onPressed: _busy
                                ? null
                                : () => _run(() => SignOutAction.show(context)),
                          ),
                        UiSection(
                          title: context.t.settingsCache,
                          child: UiSurface.card(
                            padding: EdgeInsets.zero,
                            child: UiTile.navigation(
                              title: context.t.settingsClearCache,
                              subtitle: context.t.settingsCacheDescription,
                              leading: const Icon(
                                Icons.cleaning_services_outlined,
                              ),
                              onTap: _busy ? null : () => _run(_clearCache),
                            ),
                          ),
                        ),
                        UiSurface.card(
                          padding: EdgeInsets.zero,
                          child: UiTile.navigation(
                            title: context.t.aboutTitle,
                            leading: const Icon(Icons.info_outline),
                            onTap: _busy
                                ? null
                                : () => _run(
                                    () => deps.appRouter.openAbout(context),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }
}

final class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => UiSection(
    title: title,
    child: UiSurface.card(
      padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
}

String _themeLabel(BuildContext context, ThemeMode mode) => switch (mode) {
  ThemeMode.system => context.t.settingsThemeSystem,
  ThemeMode.light => context.t.settingsThemeLight,
  ThemeMode.dark => context.t.settingsThemeDark,
};

IconData _themeIcon(ThemeMode mode) => switch (mode) {
  ThemeMode.system => Icons.brightness_auto_outlined,
  ThemeMode.light => Icons.light_mode_outlined,
  ThemeMode.dark => Icons.dark_mode_outlined,
};
