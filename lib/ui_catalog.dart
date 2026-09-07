import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
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
    final bool confirmed = await UiFeedback.confirm(
      context,
      title: context.t.signOut,
      message: context.t.uiCatalogConfirmMessage,
      confirmLabel: material.okButtonLabel,
      cancelLabel: material.cancelButtonLabel,
      destructive: true,
    );
    if (!mounted) return;
    UiFeedback.snack(
      context,
      message: confirmed ? material.okButtonLabel : material.cancelButtonLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = context.t;
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.uiCatalogTitle),
        actions: <Widget>[
          IconButton(
            tooltip: t.uiCatalogTheme,
            onPressed: widget.onThemeChanged,
            icon: const Icon(Icons.contrast),
          ),
          PopupMenuButton<Locale>(
            tooltip: t.languageSelection,
            icon: const Icon(Icons.language),
            onSelected: widget.onLocaleChanged,
            itemBuilder: (BuildContext context) => AppLocalizations
                .supportedLocales
                .map(
                  (Locale locale) => PopupMenuItem<Locale>(
                    value: locale,
                    child: Text(locale.languageCode),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(UiSpace.lg),
        children: <Widget>[
          _Section(
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
                  UiText.bodySmall(t.uiCatalogConfirmMessage, secondary: true),
                ],
              ),
            ),
          ),
          _Section(
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
                UiButton.secondary(label: t.viewMyProfile, onPressed: _snack),
                UiButton.outlined(label: t.profileRefresh, onPressed: _snack),
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
          _Section(
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
                  decoration: InputDecoration(labelText: t.profileSearchHint),
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
                  onChanged: (bool value) => setState(() => _selected = value),
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
                    ButtonSegment<bool>(value: true, label: Text(t.scoresBest)),
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
          _Section(
            title: t.uiCatalogFeedback,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: UiSpace.md,
              children: <Widget>[
                UiNotice(message: t.guestSignedOutDescription),
                UiNotice(message: t.profileOnline, tone: UiNoticeTone.success),
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
                UiButton.destructive(label: t.signOut, onPressed: _confirm),
              ],
            ),
          ),
          _Section(
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
                  child: ListTile(
                    title: Text(t.profileTitle),
                    subtitle: Text(t.guestModeTitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _snack,
                  ),
                ),
              ],
            ),
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

final class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: UiSpace.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.md,
      children: <Widget>[
        Semantics(header: true, child: UiText.titleLarge(title)),
        child,
      ],
    ),
  );
}
