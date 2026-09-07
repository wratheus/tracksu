# tracksu_ui

Presentation foundation for Tracksu. Public import:

```dart
import 'package:tracksu_ui/tracksu_ui.dart';
```

No app/domain imports, network, OAuth, Bloc, analytics SDK or stored context.
The caller supplies localized text, state and callbacks. Feature-specific
score/player/beatmap cards remain in their feature or app-level shared code.

## Short, semantic API

```dart
UiText.bodyMedium(t.profileSearchHelp, secondary: true);
UiText.titleLarge(t.profileTitle);
UiText.labelSmall(t.guestModeTitle);
UiText.metric(formattedPp);
UiButton.primary(label: t.profileSearch, onPressed: search);
UiButton.secondary(label: t.retry, onPressed: retry);
UiButton.destructive(label: t.signOut, onPressed: requestConfirmation);
```

`UiText` exposes every Material TextTheme preset: display/headline/title/body/
label × Large/Medium/Small, plus `metric` for tabular numbers. It uses the
active theme at build time; changing TextTheme changes all consumers.
`bodyHead` is intentionally not another name for a title: use `titleMedium`
for a heading within content. Optional color/alignment/line limit/overflow/
semanticsLabel are presentation overrides, not new design tokens in a page.

Buttons have primary/secondary/outlined/text/destructive constructors. Disabled
means null `onPressed`; `isLoading` suppresses input, keeps visible text and
accepts a localized `loadingLabel`. The caller owns asynchronous operations.
Callbacks are not automatically caught, logged or sent to analytics. The future
P06.1 binding belongs at the caller boundary; no Firebase dependency is needed.

## Theme ownership

`TracksuTheme.dark()` / `.light()` return Material 3 ThemeData. Defaults are
defined in `src/theme/theme.dart`, dimensions in `UiSpace` / `UiShape`.
Prefer editing these owners for a product-wide change, not overriding each page.
Use normal ThemeData.copyWith for a deliberate app-level extension.

| Role | Dark | Light |
| --- | --- | --- |
| Surface | #19161E | #FCF8FB |
| Card/low container | #211D27 | #F6F0F6 |
| Main text | #F1EAF2 | #251F2B |
| Secondary text | #C7BBCD | #65576C |
| Primary | #F28BB7 | #A32960 |
| Secondary | #C6B5E0 | #655079 |

Other Material roles derive from the seed or explicit ColorScheme entries;
UiStatusColors supplies success/warning container/text pairs, not score grades.
AppBar, cards, buttons, input, chips, tabs, navigation, dialogs/sheets, snackbar,
menus, list tiles and progress share theme defaults. Native Material switch,
checkbox/radio and other controls consume the ColorScheme; do not reimplement
their focus, gestures or semantics merely to prefix their class name.

Typography: existing host-registered **Exo 2** for headings/numbers; platform
body font for readable content and system fallback for CJK. No font downloads.
`headingFontFamily` allows an explicit host alternative. The font registration
and asset provenance remain app/P01.2 responsibilities, not a claim of a completed
license audit. Spacing is 4/8/12/16/24/32; controls/cards/sheets use 12/16/24 radii.
Touch targets are not reduced to the visual icon's size. Body text is not forced
into fixed-height boxes. Platform page transitions are not replaced by this theme.

## Surfaces and feedback

- `UiSurface.card/outlined/tonal/inset`: theme-owned surfaces, optional tap,
  custom padding; no business model. Plain `UiSurface` remains the card default.
- `UiSearchField`: external controller/focus, label/error/help/clear strings;
  the caller decides query validation and debounce. Clearing emits `onChanged('')`.
- `UiNotice`: information/success/warning/error, optional localized action.
- `UiLoading`: labelled inline progress, usable in a page or pagination footer.
- `UiFeedback.snack`: replaces the currently visible snackbar; call from an
  event/listener, never build. Action text and callback must be supplied together.
- `UiModal.confirm/destructive`: confirmation sheet; true only on explicit
  confirm, false on cancel/dismiss/Back. The destructive variant changes action
  styling, not business behavior. Check result and `mounted`/Bloc ownership.
- `UiModal.info`: short informational sheet with a localized close action.
- `UiModal.selection<T>`: typed single choice from `UiChoice<T>` items, lazy list;
  selected value is highlighted, disabled items cannot be picked, dismiss is null.
  Values must be unique; non-null `T` distinguishes cancellation from selection.
- `UiModal.sheet<T>`: custom short content/form. Owns scrolling and keyboard insets.
- `UiModal.scrollable<T>`: custom bounded viewport for a lazy list or composed
  scrollable content. Does not wrap another SingleChildScrollView around it.
  Both methods own the title/close header and have explicit root navigator choice.
- `UiFrame.body/scroll`: body composition, common padding/safe areas and optional
  footer outside the scroll view; does not own Scaffold, routes or data.
- `UiSection`: title, optional action, content and common section spacing.
- `UiTile.navigation/action/selection`: menu/settings/choice rows, theme-owned
  layout. Null onTap disables the row. Selection requires explicit selected state.
- `UiIconButton.standard/filled/tonal/outlined`: localized tooltip required,
  standard touch/focus behavior and optional selected/selectedIcon for toggles.

Modal recipes now live in UiModal, not UiFeedback: the only pre-release consumer
(the catalog) was migrated together; no duplicate compatibility implementation.

Use `Row/Column.spacing` and `Padding` to assemble components. Do not rewrap each
one with new hardcoded colors or rebuild a second set of Material styles.

## Composition recipes

These fragments assume the caller already has localized `t`, callbacks and
typed display data. Use them as construction patterns, not new repositories.

### A page with a lazy list and a fixed action

```dart
Scaffold(
  appBar: AppBar(title: UiText.titleLarge(t.profileTitle)),
  body: UiFrame.scroll(
    controller: scrollController,
    footer: UiButton.primary(label: t.profileRefresh, onPressed: refresh),
    slivers: [
      SliverToBoxAdapter(
        child: UiSection(
          title: t.profileTitle,
          child: UiSurface.tonal(child: UiText.bodyMedium(description)),
        ),
      ),
      SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => UiTile.navigation(
          title: items[index].title,
          onTap: () => openItem(items[index]),
        ),
      ),
    ],
  ),
);
```

Use `UiFrame.body(child: ..., footer: ...)` when the child already owns its
layout/scrolling. Both frames need bounded height (normally Scaffold.body).
Do not put a frame inside a SingleChildScrollView. The owning Scaffold should
retain keyboard resizing; footer belongs outside the content scroll, not in
a Stack hiding the last rows. Huge multi-action footers belong in scrollable
content instead. External controllers are disposed by their creator.

### Confirmation before a mutation

```dart
final confirmed = await UiModal.destructive(
  context,
  title: t.signOut,
  message: confirmationMessage,
  confirmLabel: t.signOut,
  cancelLabel: MaterialLocalizations.of(context).cancelButtonLabel,
);
if (!context.mounted || !confirmed) return;
// Dispatch to the feature/session owner here, not inside UiModal.
```

Do not open modals from build, and do not treat dismiss as successful consent.
If an action can be triggered repeatedly, the initiating feature owns the
in-flight guard. Built-in modal buttons also guard against popping the previous
route on a second tap during dismissal. Custom sheet content must follow the
same lifecycle rules when it closes routes itself.

### A typed selection

```dart
final locale = await UiModal.selection<Locale>(
  context,
  title: t.languageSelection,
  selected: currentLocale,
  choices: [
    UiChoice(value: const Locale('en'), label: t.englishLanguage),
    UiChoice(value: const Locale('ru'), label: t.russianLanguage),
  ],
);
if (!context.mounted || locale == null) return;
// Pass the choice to the setting owner. The sample is not the full language list.
```

### Which customization layer?

1. Choose a named variant before adding flags or copying implementation.
2. Supply content/callbacks/typed values; business state stays outside the kit.
3. For product-wide changes edit ThemeData/ColorScheme, UiSpace/UiShape or the
   component owner. For a deliberate local composition use padding/slots.
4. If several pages repeat a new pattern, add one named recipe and a catalog
   example. Do not build a universal container with a growing list of booleans.
5. Feature-specific content stays outside this package. The existing Material
   controls are supported building blocks styled by the theme, not a loophole
   for inventing per-page colors, hit targets or transitions.

## Manual catalog

From the repository root:

```sh
fvm flutter run -t lib/ui_catalog.dart
```

Theme/language controls, enabled/disabled/loading buttons, fields, selection,
feedback, confirmation and navigation visuals can be inspected without API or
OAuth initialization. Text uses the existing seven ARB catalogs. It is a manual
workbench, not an automated test harness or production navigation shell.
Changing a sample control affects only demonstration state, never an account.
Installing/running this target uses the **same Android application ID** as the
normal debug app; it is not a second installable product. Run `lib/main.dart`
again to return to normal app entry. No storage migration/clear is performed.

The primary app has NOT adopted this theme yet. P07.2 stacks/Back, theme preference
persistence, image/flag/ruleset/grade primitives, empty-state composition,
final accessibility/visual acceptance and feature-page migration are follow-up
work. Do not label the complete product redesign or complete UI kit finished.
