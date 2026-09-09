# tracksu_ui

`UiSliverCardList` — lazy card list with the shared `UiSpace.md` (12 px) gap.
The screen owns outer padding; surfaces do not impose hidden margins.

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
- `UiModal.scrollable<T>`: content-fit draggable viewport for a lazy list or
  composed slivers. Return a scrollable with `primary: true` and no private
  controller/`shrinkWrap`. Its inherited controller expands the sheet before
  scrolling. Initial fitting uses sliver extent estimates (18–90% bounds);
  dragging takes ownership of size (18–95%). No eager measurement of all rows.
  Does not wrap another SingleChildScrollView around the lazy content.
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

## Media, statistics and product compositions

The product catalog now starts with actual reusable compositions, not only
Material controls. All examples use explicit preview values and existing local
Tracksu artwork; they do not fetch player data or represent real statistics.

| Family | Public API | Ownership |
| --- | --- | --- |
| Image | `UiImage`, `UiImage.loading`, `UiCover` | UI package |
| Avatar | `UiAvatar.small/medium/large` | UI package |
| Status badge | `UiBadge.neutral/accent/positive/warning/negative` | UI package |
| States | `UiContentState.empty/error/offline/loading`, `UiSkeleton.line/block` | UI package |
| Statistics | `UiMetric`, `UiMetricGroup` | UI package |
| Charts | `UiChart.line/bars`, `UiChartPoint` | UI package |
| Flags/modes/grades/mods | `OsuCountryFlag`, `OsuRulesetIcon`, `OsuRulesetSelector`, `OsuGradeBadge`, `OsuMods` | App shared UI |
| Player | `OsuPlayerCard.compact/profile` | App shared UI |
| Affiliation | `OsuAffiliationTile` (group/team identity) | App shared UI |
| Beatmap | `OsuBeatmapCard.compact/featured` | App shared UI |
| Score/news | `OsuPlayCard`, `OsuNewsCard` | App shared UI |

Import the latter group through
`package:tracksu/src/_shared/ui/osu_ui.dart`. These are display components, not
repositories, DTOs or new feature entry points. Existing production widgets
remain active until the page-migration step; do not mix the new compositions
into old pages without moving their theme and reviewing the resulting layout.

`OsuPlayerCard.profile(nameAction: ...)` places an accessible action beside the
name without teaching the card about history or repositories. `OsuAffiliationTile`
accepts text, image, optional accent and callback; server colours never become
body-text colours. The product catalog includes an offline affiliation example.

### Charts and navigation

`UiSegmentedControl<T>(segments: ..., selected: ..., onChanged: ...)` is a
controlled, bounded-width single-row selector; each `UiSegment` has value,
localized label and icon. Unique values and at least two items are required.
Tap selects immediately; drag previews the thumb and commits once on release,
cancel does not call the owner. RTL, disabled state, keyboard activation,
selected semantics, tooltips and reduced-motion duration are preserved.
Labels fall back to icons when measured text does not fit, without clamping
the user's text scale. Use for a small choice set, not a long category list.
The standard Material splash/overlay is disabled: a shape-matched local press
highlight and keyboard focus border are rendered explicitly. One clipped blur
(sigma 6) plus a translucent tonal gradient gives a restrained glass effect;
high-contrast mode uses a solid surface. No looping animation or per-cell filters.

Line charts accept `UiChartPoint.breakBefore` to start a new segment after
missing observations. The caller keeps the original x coordinates and provides
truthful labels (a rank-history index is not a calendar date). Isolated points
remain visible. The manual rank-chart sample includes a break; chart selection
is local state and does not rebuild the profile page or fetch data.

`UiNavigationBar(items: ..., selectedIndex: ..., onSelected: ...)` uses the
shared Material navigation theme. `UiNavigationItem` carries localized labels
and normal/selected icons. It owns no router, stacks or reselect policy; those
belong to the app's stateful shell. The manual catalog includes a selectable
three-destination sample.
### Images and assets

Pass an `ImageProvider` (e.g. `AssetImage` or an already validated `NetworkImage`)
or null. Null and image errors show a themed fallback; pending decoding shows
a static placeholder. Avatar initials use the first grapheme and empty names
show a person icon. The owner renders the accessible username; a decorative
avatar does not repeat it. A standalone image can take `semanticLabel`.

`UiImage` requires finite width/height; `fit: BoxFit.contain` supports uncropped
flags/medals, while covers keep the default crop. `UiCover` requires bounded width.
Decode dimensions follow layout × device pixel ratio with a 2048px ceiling per
dimension. No global image-cache mutation, disk cache, authenticated headers,
per-byte progress rebuilds or shimmer loops. Changing the provider does not
briefly show the previous player's image. Images belong in lazy builder lists.

`UiImageViewer.show(context, image: decodedImage, closeLabel: ..., imageLabel: ...)`
opens a root dialog with pinch zoom and Close/Back. It clones an already decoded
`dart:ui.Image`, retains it through the route exit animation, then disposes it.
It never downloads a higher-resolution original. Untrusted user-page images use
the app's bounded `ContentMediaLoader`/`ContentFrame.sliver`, not `NetworkImage`:
the generic UiImage decode resize alone does not limit response bytes or hosts.

Flags validate two-letter codes; missing/unknown assets show a flag placeholder.
Grades are native themed osu-style badges rather than image assets; unknown values
remain visible with a neutral treatment. Mods always display acronyms, including
unknown ones. Existing flag/font provenance and licensing still need
P01.2 review; using them in this catalog is not a completed rights audit.

### Charts

```dart
UiChart.line(
  title: t.uiCatalogHistory,
  emptyLabel: t.uiCatalogNoData,
  lowerIsBetter: true,
  points: observations.map((item) => UiChartPoint(
    x: item.timestamp.millisecondsSinceEpoch.toDouble(),
    value: item.rank.toDouble(),
    label: formatDate(item.timestamp),
    valueLabel: formatRank(item.rank),
  )).toList(growable: false),
);
```

This is a construction recipe, not a claim that the current Profile model
provides dated observations. Profile rank history now provides ordered indices;
card media need their own API-to-domain projection when integrated. Never
substitute the catalog samples for absent player data.

Series are copied to an immutable list. x must be finite and strictly
increasing; values and ranges must be finite. Bars additionally require
non-negative values and use a zero baseline. Bars are equally spaced categories:
the caller must disclose omitted months rather than invent zero-valued samples.
Line charts preserve x spacing, use shape-preserving harmonic-mean tangents
without extra extrema, a subtle area fill per contiguous segment, and reverse y when
`lowerIsBetter` is true. Empty, single-point, flat and zero-valued series have
defined rendering. Missing intervals are not synthesized by this widget.
`tone: UiChartTone.primary/secondary/tertiary` selects a semantic theme accent.
Only segment endpoints and the selected sample get markers on a line.

Tap/drag selects a sample; the displayed date/value and native discrete slider
provide the same information for keyboard/accessibility navigation. Selection
is preserved by x when data refreshes. The callback is optional and only fires
on user selection. Charts own local selection/repaint, not the page Bloc.
Use a bounded aggregated time window (e.g. days/months), not an unbounded stream
of raw events. No chart library or network dependency was added.

### Content states and cards

State components are content-sized: place inside `SliverToBoxAdapter` for a
scrolling screen. A retry action is optional, but its label/callback come as a
pair. Use `UiNotice` alongside existing content for refresh failures, and
`UiLoading` at pagination footers; do not replace a loaded list with full-page
loading. Skeletons are static, and the parent announces loading once.

Card text is on an opaque themed surface rather than over artwork. Main titles
wrap; news previews alone are capped. Metrics switch to one column with narrow
width/large text. Optional PP, cover, country/status and details remain absent
or use caller-provided localized unknown labels — the UI invents no values.
All cards receive callbacks; they do not navigate or mutate accounts themselves.

`UiMetric` keeps prominent figures; `UiMetric.compact` uses titleMedium for
secondary grid values, and `UiMetric.row` puts a decorative icon beside the
label/value stack for full-width statistics. All require bounded width.
Optional `icon` is decorative; `tone: UiMetricTone.primary/secondary/tertiary`
selects theme text colors, never ad-hoc per-page hex values. Keep labels and
exact locale-formatted values: colors/icons do not replace meaning. No global
font-size override or text-scale suppression is needed for compact metrics.

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
persistence, missing API projections, final accessibility/visual acceptance and
feature-page migration are follow-up work. The component set above is implemented;
do not equate it with a completed product redesign or device acceptance.
