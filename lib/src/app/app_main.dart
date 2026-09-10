import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class AppMain extends StatelessWidget {
  const AppMain({required this.dependencies, super.key});

  final DepsContainer dependencies;

  @override
  Widget build(BuildContext context) {
    return DepsScope(
      dependencies: dependencies,
      child: ValueListenableBuilder<Locale?>(
        valueListenable: dependencies.localeController,
        builder: (BuildContext context, Locale? locale, Widget? child) {
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: dependencies.themeController,
            builder: (BuildContext context, ThemeMode mode, Widget? child) =>
                MaterialApp.router(
                  restorationScopeId: 'tracksu_app',
                  debugShowCheckedModeBanner: false,
                  onGenerateTitle: (BuildContext context) => context.t.appTitle,
                  locale: locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  theme: TracksuTheme.light(),
                  darkTheme: TracksuTheme.dark(),
                  themeMode: mode,
                  routerConfig: dependencies.appRouter.config,
                ),
          );
        },
      ),
    );
  }
}
