import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Future<void>? _cacheReady;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cacheReady ??= DepsScope.of(context).mediaCache.initialize();
  }

  /// Decimal megabytes, as people read storage sizes on their phones.
  String _size(int bytes) => NumberFormat.decimalPatternDigits(
    locale: context.t.localeName,
    decimalDigits: 1,
  ).format(bytes / 1000000);

  Future<void> _clearCache() async {
    final bool clear = await UiModal.confirm(
      context,
      title: context.t.settingsClearCacheTitle,
      message: context.t.settingsCacheConfirm(
        _size(DepsScope.of(context).mediaCache.sizeBytes),
      ),
      confirmLabel: context.t.settingsClearCache,
      cancelLabel: MaterialLocalizations.of(context).cancelButtonLabel,
    );
    if (!mounted || !clear) return;
    final deps = DepsScope.of(context);
    try {
      await deps.audioPlaybackController.stop();
      deps.pageCache.clear();
      await deps.mediaCache.clear();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      if (mounted) {
        setState(() => _cacheReady = deps.mediaCache.initialize());
        UiFeedback.snack(context, message: context.t.settingsCacheCleared);
      }
    } on Object {
      if (mounted) {
        UiFeedback.snack(context, message: context.t.settingsCacheFailed);
      }
    }
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
      appBar: UiAppBar(
        title: UiText.titleLarge(context.t.settingsTitle),
        bottom: UiAppBarProgressSlot(
          child: FutureBuilder<void>(
            future: _cacheReady,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) =>
                UiAppBarProgress(
                  visible:
                      _busy || snapshot.connectionState != ConnectionState.done,
                  semanticsLabel: context.t.settingsCacheCalculating,
                ),
          ),
        ),
      ),
      // Pull to recount the media cache; progress shows under the app bar.
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _cacheReady = deps.mediaCache.initialize());
        },
        child: UiFrame.scroll(
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
                      // Grouped list: short rows with the current value on
                      // the trailing edge; explanations live in footnotes.
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: UiSpace.xl,
                        children: <Widget>[
                          _AccountHeader(authenticated: authenticated),
                          UiListGroup(
                            title: context.t.account,
                            children: <Widget>[
                              if (authenticated)
                                UiTile.value(
                                  title: context.t.viewMyProfile,
                                  leading: const UiTileIcon(
                                    Icons.person_outline,
                                  ),
                                  onTap: _busy
                                      ? null
                                      : () => _run(
                                          () => deps.appRouter
                                              .openCurrentProfile(context),
                                        ),
                                ),
                              if (!authenticated)
                                UiTile.value(
                                  title: context.t.signInWithOsu,
                                  leading: const UiTileIcon(Icons.login),
                                  onTap: _busy
                                      ? null
                                      : () => _run(
                                          () =>
                                              deps.appRouter.openLogin(context),
                                        ),
                                ),
                            ],
                          ),
                          UiListGroup(
                            title: context.t.settingsAppearance,
                            children: <Widget>[
                              ValueListenableBuilder<Locale?>(
                                valueListenable: deps.localeController,
                                builder:
                                    (BuildContext context, Locale? locale, _) =>
                                        UiTile.value(
                                          title: context.t.languageSelection,
                                          value: AppLanguage.fromLocale(locale)
                                              .label(context.t),
                                          leading: const UiTileIcon(
                                            Icons.translate,
                                          ),
                                          onTap: _busy
                                              ? null
                                              : () => _run(
                                                  () => LanguagePicker.show(
                                                    context,
                                                  ),
                                                ),
                                        ),
                              ),
                              ValueListenableBuilder<ThemeMode>(
                                valueListenable: deps.themeController,
                                builder:
                                    (BuildContext context, ThemeMode mode, _) =>
                                        UiTile.value(
                                          title: context.t.settingsTheme,
                                          value: _themeLabel(context, mode),
                                          leading: UiTileIcon(_themeIcon(mode)),
                                          onTap: _busy
                                              ? null
                                              : () => _run(_selectTheme),
                                        ),
                              ),
                            ],
                          ),
                          UiListGroup(
                            title: context.t.settingsImages,
                            footer: context.t.contentMediaConsent,
                            children: <Widget>[
                              ContentMediaSettings(
                                controller: deps.contentMediaController,
                              ),
                            ],
                          ),
                          UiListGroup(
                            title: context.t.settingsCache,
                            footer: context.t.settingsCacheDescription,
                            children: <Widget>[
                              ListenableBuilder(
                                listenable: deps.cachePreference,
                                builder: (BuildContext context, _) =>
                                    UiTile.toggle(
                                      leading: const UiTileIcon(
                                        Icons.storage_rounded,
                                      ),
                                      title: context.t.settingsCacheEnabled,
                                      selected: deps.cachePreference.enabled,
                                      onToggle: deps.cachePreference.saving
                                          ? null
                                          : (bool value) => _run(
                                              () => deps.cachePreference.select(
                                                value,
                                              ),
                                            ),
                                    ),
                              ),
                              FutureBuilder<void>(
                                future: _cacheReady,
                                builder:
                                    (
                                      BuildContext context,
                                      AsyncSnapshot<void> snapshot,
                                    ) => ListenableBuilder(
                                      listenable: deps.mediaCache,
                                      builder: (BuildContext context, _) {
                                        final bool ready =
                                            snapshot.connectionState ==
                                            ConnectionState.done;
                                        return UiTile.value(
                                          title: context.t.settingsClearCache,
                                          value: snapshot.hasError
                                              ? context.t.settingsCacheFailed
                                              : ready
                                              ? context.t.settingsCacheSize(
                                                  _size(
                                                    deps.mediaCache.sizeBytes,
                                                  ),
                                                )
                                              : '…',
                                          leading: const UiTileIcon(
                                            Icons.cleaning_services_outlined,
                                          ),
                                          onTap: _busy || !ready
                                              ? null
                                              : () => _run(_clearCache),
                                        );
                                      },
                                    ),
                              ),
                            ],
                          ),
                          UiListGroup(
                            children: <Widget>[
                              UiTile.value(
                                title: context.t.aboutTitle,
                                leading: const UiTileIcon(Icons.info_outline),
                                onTap: _busy
                                    ? null
                                    : () => _run(
                                        () => deps.appRouter.openAbout(context),
                                      ),
                              ),
                            ],
                          ),
                          if (authenticated)
                            UiButton.destructive(
                              label: context.t.signOut,
                              onPressed: _busy
                                  ? null
                                  : () =>
                                        _run(() => SignOutAction.show(context)),
                            ),
                        ],
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Who is using the app: guest or signed in, in one calm tonal card.
final class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.authenticated});
  final bool authenticated;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return UiSurface.tonal(
      padding: const EdgeInsets.all(UiSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: UiSpace.md,
        children: <Widget>[
          Icon(
            authenticated
                ? Icons.verified_user_outlined
                : Icons.explore_outlined,
            size: 28,
            color: colors.onSecondaryContainer,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.xs,
              children: <Widget>[
                UiText.titleMedium(
                  authenticated ? context.t.account : context.t.guestModeTitle,
                  color: colors.onSecondaryContainer,
                ),
                UiText.bodySmall(
                  authenticated
                      ? context.t.guestSignedInDescription
                      : context.t.guestSignedOutDescription,
                  color: colors.onSecondaryContainer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
