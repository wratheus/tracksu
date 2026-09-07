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

- `UiSurface`: quiet card, optional tap, custom padding; no business model.
- `UiSearchField`: external controller/focus, label/error/help/clear strings;
  the caller decides query validation and debounce. Clearing emits `onChanged('')`.
- `UiNotice`: information/success/warning/error, optional localized action.
- `UiLoading`: labelled inline progress, usable in a page or pagination footer.
- `UiFeedback.snack`: replaces the currently visible snackbar; call from an
  event/listener, never build. Action text and callback must be supplied together.
- `UiFeedback.confirm`: scrollable confirmation sheet; true only on explicit
  confirm, false on cancel/dismiss/Back. Mutations are performed by the caller
  **after** checking the result and lifecycle (`mounted`/Bloc ownership).
- `UiFeedback.sheet<T>`: localized caller content and typed result; root navigator
  choice is explicit. Intended for short content, not eagerly built API lists.

Use `Row/Column.spacing` and `Padding` to assemble components. Do not rewrap each
one with new hardcoded colors or rebuild a second set of Material styles.

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
