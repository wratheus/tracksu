import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/ui_catalog/product_catalog.dart';
import 'package:tracksu/src/ui_catalog/content_catalog.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Manual component workbench. No bootstrap, credentials, repositories or API.
void main() => runApp(const _CatalogApp());

final class _CatalogApp extends StatefulWidget {
  const _CatalogApp();

  @override
  State<_CatalogApp> createState() => _CatalogAppState();
}

final class _CatalogAppState extends State<_CatalogApp> {
  ThemeMode _mode = ThemeMode.dark;
  Locale? _locale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: TracksuTheme.light(),
    darkTheme: TracksuTheme.dark(),
    themeMode: _mode,
    locale: _locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: _CatalogScreen(
      onThemeChanged: () => setState(
        () =>
            _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      ),
      onLocaleChanged: (Locale locale) => setState(() => _locale = locale),
    ),
  );
}

final class _CatalogScreen extends StatefulWidget {
  const _CatalogScreen({
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });
  final VoidCallback onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<_CatalogScreen> createState() => _CatalogScreenState();
}

final class _CatalogScreenState extends State<_CatalogScreen> {
  final TextEditingController _query = TextEditingController();
  bool _selected = false;
  int _navigationIndex = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _snack() =>
      UiFeedback.snack(context, message: context.t.uiCatalogConfirmMessage);

  Future<void> _confirm() async {
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    final bool confirmed = await UiModal.destructive(
      context,
      title: context.t.signOut,
      message: context.t.uiCatalogConfirmMessage,
      confirmLabel: material.okButtonLabel,
      cancelLabel: material.cancelButtonLabel,
    );
    if (!mounted) return;
    UiFeedback.snack(
      context,
      message: confirmed ? material.okButtonLabel : material.cancelButtonLabel,
    );
  }

  Future<void> _chooseLocale() async {
    final AppLocalizations t = context.t;
    final Locale? locale = await UiModal.selection<Locale>(
      context,
      title: t.languageSelection,
      selected: Locale(Localizations.localeOf(context).languageCode),
      choices: <UiChoice<Locale>>[
        UiChoice(value: const Locale('en'), label: t.englishLanguage),
        UiChoice(value: const Locale('ru'), label: t.russianLanguage),
        UiChoice(value: const Locale('de'), label: t.germanLanguage),
        UiChoice(value: const Locale('fr'), label: t.frenchLanguage),
        UiChoice(value: const Locale('es'), label: t.spanishLanguage),
        UiChoice(value: const Locale('ja'), label: t.japaneseLanguage),
        UiChoice(value: const Locale('zh'), label: t.chineseLanguage),
      ],
    );
    if (!mounted || locale == null) return;
    widget.onLocaleChanged(locale);
  }

  Future<void> _info() => UiModal.info(
    context,
    title: context.t.uiCatalogTitle,
    message: context.t.uiCatalogConfirmMessage,
    closeLabel: MaterialLocalizations.of(context).closeButtonLabel,
  );

  Future<void> _standardConfirm() async {
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    await UiModal.confirm(
      context,
      title: context.t.uiCatalogTitle,
      message: context.t.uiCatalogConfirmMessage,
      confirmLabel: material.okButtonLabel,
      cancelLabel: material.cancelButtonLabel,
    );
  }

  Future<void> _formSheet() => UiModal.sheet<void>(
    context,
    title: context.t.profileSearch,
    builder: (BuildContext modalContext) => TextField(
      autofocus: true,
      decoration: InputDecoration(labelText: modalContext.t.profileSearchHint),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = context.t;
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.uiCatalogTitle),
        actions: <Widget>[
          UiIconButton.standard(
            tooltip: t.uiCatalogTheme,
            onPressed: widget.onThemeChanged,
            icon: Icons.contrast,
          ),
          UiIconButton.standard(
            tooltip: t.languageSelection,
            icon: Icons.language,
            onPressed: _chooseLocale,
          ),
        ],
      ),
      body: UiFrame.scroll(
        slivers: <Widget>[
          const ProductCatalogSliver(),
          const ContentCatalogSliver(),
          SliverList.list(
            children: <Widget>[
              UiSection(
                title: t.uiCatalogTypography,
                child: UiSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: UiSpace.md,
                    children: <Widget>[
                      UiText.headlineSmall(t.appTitle),
                      UiText.titleMedium(t.profileTitle),
                      const UiText.metric('7 837 pp'),
                      UiText.bodyLarge(t.profileSearchIntroduction),
                      UiText.bodyMedium(t.profileSearchHelp, secondary: true),
                      UiText.labelLarge(t.guestModeTitle),
                      UiText.bodySmall(
                        t.uiCatalogConfirmMessage,
                        secondary: true,
                      ),
                    ],
                  ),
                ),
              ),
              UiSection(
                title: t.uiCatalogButtons,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: UiSpace.sm,
                  children: <Widget>[
                    UiButton.primary(
                      label: t.profileSearch,
                      icon: Icons.search,
                      onPressed: _snack,
                    ),
                    UiButton.secondary(
                      label: t.viewMyProfile,
                      onPressed: _snack,
                    ),
                    UiButton.outlined(
                      label: t.profileRefresh,
                      onPressed: _snack,
                    ),
                    UiButton.text(label: t.newsOriginal, onPressed: _snack),
                    UiButton.destructive(label: t.signOut, onPressed: _confirm),
                    UiButton.primary(label: t.profileSearch, onPressed: null),
                    UiButton.primary(
                      label: t.profileSearch,
                      onPressed: null,
                      isLoading: true,
                      loadingLabel: t.profileLoading,
                    ),
                  ],
                ),
              ),
              UiSection(
                title: t.uiCatalogTypography,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: UiSpace.md,
                  children: <Widget>[
                    UiSurface.outlined(
                      child: UiText.bodyMedium(t.profileSearchHelp),
                    ),
                    UiSurface.tonal(
                      child: UiText.titleMedium(t.guestModeTitle),
                    ),
                    UiSurface.inset(
                      child: UiText.bodySmall(t.uiCatalogConfirmMessage),
                    ),
                    Wrap(
                      spacing: UiSpace.sm,
                      runSpacing: UiSpace.sm,
                      children: <Widget>[
                        UiIconButton.standard(
                          icon: Icons.search,
                          tooltip: t.profileSearch,
                          onPressed: _snack,
                        ),
                        UiIconButton.filled(
                          icon: Icons.refresh,
                          tooltip: t.profileRefresh,
                          onPressed: _snack,
                        ),
                        UiIconButton.tonal(
                          icon: Icons.info_outline,
                          tooltip: t.uiCatalogTitle,
                          onPressed: _info,
                        ),
                        UiIconButton.outlined(
                          icon: Icons.favorite_outline,
                          selectedIcon: Icons.favorite,
                          isSelected: _selected,
                          tooltip: t.beatmapsFavourite,
                          onPressed: () =>
                              setState(() => _selected = !_selected),
                        ),
                        UiIconButton.filled(
                          icon: Icons.search,
                          tooltip: t.profileSearch,
                          onPressed: null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              UiSection(
                title: t.uiCatalogInputs,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: UiSpace.md,
                  children: <Widget>[
                    UiSearchField(
                      controller: _query,
                      label: t.profileSearchHint,
                      clearLabel: material.deleteButtonTooltip,
                      helperText: t.profileSearchHelp,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: t.rankingsCountry,
                        errorText: t.rankingsCountryInvalid,
                        errorMaxLines: 4,
                      ),
                    ),
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: t.profileSearchHint,
                      ),
                    ),
                    Wrap(
                      spacing: UiSpace.sm,
                      runSpacing: UiSpace.sm,
                      children: <Widget>[
                        ChoiceChip(
                          label: Text(t.scoresBest),
                          selected: _selected,
                          onSelected: (bool value) =>
                              setState(() => _selected = value),
                        ),
                        ChoiceChip(
                          label: Text(t.scoresRecent),
                          selected: !_selected,
                          onSelected: (bool value) =>
                              setState(() => _selected = !value),
                        ),
                        Chip(label: Text(t.rulesetMania)),
                      ],
                    ),
                    SwitchListTile(
                      title: Text(t.profileOnline),
                      value: _selected,
                      onChanged: (bool value) =>
                          setState(() => _selected = value),
                    ),
                    CheckboxListTile(
                      title: Text(t.scoresBest),
                      value: _selected,
                      onChanged: (bool? value) =>
                          setState(() => _selected = value ?? false),
                    ),
                    RadioGroup<bool>(
                      groupValue: _selected,
                      onChanged: (bool? value) =>
                          setState(() => _selected = value ?? false),
                      child: Column(
                        children: <Widget>[
                          RadioListTile<bool>(
                            value: true,
                            title: Text(t.scoresBest),
                          ),
                          RadioListTile<bool>(
                            value: false,
                            title: Text(t.scoresRecent),
                          ),
                        ],
                      ),
                    ),
                    SegmentedButton<bool>(
                      segments: <ButtonSegment<bool>>[
                        ButtonSegment<bool>(
                          value: true,
                          label: Text(t.scoresBest),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text(t.scoresRecent),
                        ),
                      ],
                      selected: <bool>{_selected},
                      onSelectionChanged: (Set<bool> value) =>
                          setState(() => _selected = value.single),
                    ),
                  ],
                ),
              ),
              UiSection(
                title: t.uiCatalogFeedback,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: UiSpace.md,
                  children: <Widget>[
                    UiNotice(message: t.guestSignedOutDescription),
                    UiNotice(
                      message: t.profileOnline,
                      tone: UiNoticeTone.success,
                    ),
                    UiNotice(
                      message: t.profileShowingPreviousData,
                      tone: UiNoticeTone.warning,
                    ),
                    UiNotice(
                      message: t.profileConnectionFailed,
                      tone: UiNoticeTone.error,
                      actionLabel: t.retry,
                      onAction: _snack,
                    ),
                    UiLoading(label: t.profileLoading),
                    UiButton.secondary(
                      label: t.uiCatalogFeedback,
                      onPressed: _snack,
                    ),
                    UiButton.primary(
                      label: material.okButtonLabel,
                      onPressed: _standardConfirm,
                    ),
                    UiButton.secondary(
                      label: t.uiCatalogTitle,
                      onPressed: _info,
                    ),
                    UiButton.outlined(
                      label: t.languageSelection,
                      onPressed: _chooseLocale,
                    ),
                    UiButton.text(
                      label: t.profileSearch,
                      onPressed: _formSheet,
                    ),
                    UiButton.destructive(label: t.signOut, onPressed: _confirm),
                  ],
                ),
              ),
              UiSection(
                title: t.uiCatalogNavigation,
                child: Column(
                  spacing: UiSpace.md,
                  children: <Widget>[
                    DefaultTabController(
                      length: 2,
                      child: TabBar(
                        tabs: <Widget>[
                          Tab(text: t.scoresBest),
                          Tab(text: t.scoresRecent),
                        ],
                      ),
                    ),
                    UiSurface(
                      padding: EdgeInsets.zero,
                      child: UiTile.navigation(
                        title: t.profileTitle,
                        subtitle: t.guestModeTitle,
                        onTap: _snack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Component preview only, not the P07.2 stateful navigation implementation.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navigationIndex,
        onDestinationSelected: (int value) =>
            setState(() => _navigationIndex = value),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: t.profileSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.leaderboard_outlined),
            label: t.rankingsTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.newspaper_outlined),
            label: t.newsTitle,
          ),
        ],
      ),
    );
  }
}
