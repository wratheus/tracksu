# Changelog

## Unreleased

### Refactored

- Moved live authorization from pages into auth: local composition, typed Bloc
  states/events, transaction/browser repository and lifecycle-only screen.
  Router owns success navigation. Removed the last pages file; palette retained.
  Reused en/ru strings, guarded duplicate callbacks/start and browser failures,
  and retained the callback URL, scopes and pending-transaction storage format.

### Removed

- 45 unreachable legacy Dart files: old Home/desktop navigation, drawer/error
  flow, profile/rankings/beatmap/news pages, Cubits, models, requests and helpers.
  Active authorization and palette remain unchanged; assets/storage are untouched.
- Direct dependencies on curved_navigation_bar, fluttericon, audioplayers,
  cached_network_image and provider. The latter two remain transitively required.

### Added

- Composable UI recipes: surface variants, body/sliver frames with safe footer,
  sections, menu/choice tiles and icon-button variants. Centralized modal APIs
  in UiModal (confirm, destructive, info, typed selection, short/custom-scroll
  sheets), with updated manual catalog and construction examples. Feature pages
  and production navigation remain unchanged.

- `tracksu_ui` workspace foundation: dark/light Material themes, Exo 2 heading
  typography, all named UiText presets, semantic buttons, surfaces, search,
  notices, loading, typed sheets/confirmation and snackbar helpers. Added a
  separate API-free manual catalog with seven-language labels. Normal app pages
  remain unchanged; navigation and visual acceptance are still pending.
  Corrected the case of the existing italic font asset path.

- Full UI catalogs for German, French, Spanish, Japanese and Simplified Chinese,
  alongside English/Russian (169 messages per locale). Language selection persists;
  English remains the unsupported-language fallback. Flutter ARB descriptions and
  typed placeholders live in the English template, with required metadata and a
  missing-translation report. Native-speaker/device review is still pending.
  Included the user-approved guest shell move from presentation to widgets.

- Guest news feed and article reader: opaque cursor pagination, content-preserving
  refresh/retry, route-scoped cancellation, lazy slivers and en/ru UI.
  Article HTML is reduced to allowlisted text markup; HTTPS links and the
  canonical osu! original open externally instead of the legacy edit_url.

- Spotlights catalog and charts route from rankings: ruleset selection,
  beatmapsets and score ranking, navigation to existing profiles/map details,
  latest-wins cancellation, content-preserving refresh/retry and en/ru strings.

- Rankings country filter and mania 4K/7K selection with English/Russian labels.
  Filters persist during paging/refresh; switching away from mania resets its
  variant. Country codes are normalized and validated before requesting data.

- Ranking rows open the selected player's profile in the ranking ruleset.
  Back keeps the ranking route and loaded pages; repeated row taps are guarded.

- Public performance/score rankings for four rulesets, accessible from the
  profile toolbar: server cursor pagination, latest-wins filters, lazy rows,
  refresh/load-more retry and English/Russian strings.

- Typed navigation from profile scores and beatmap lists to beatmap details:
  difficulty selection, public top leaderboard, independent refresh/retry,
  cancellation on navigation and English/Russian strings.

- Profile beatmap lists: eight categories, typed BeatmapPlaycount/beatmapset
  projections, independent cancellation and paged lazy slivers with English/
  Russian loading, empty and retry states. Refresh failures preserve content.

- Profile scores data foundation (best/recent): typed query/page/summary,
  cancellation, modern score parsing and domain failures.
- Best/recent scores section in the guest profile: lazy sliver cards, independent
  refresh, load-more/retry, duplicate ID suppression and player/ruleset lifecycle.
  Card metadata comes from the same response; there are no per-row API requests.

- Guest-first player lookup by username/ID, optional account menu and own profile.
- Four rulesets for the selected player; rank, accuracy, performance, play count,
  play time, maximum combo and explicit missing-statistics state.
- Memory-only public API credentials, expiry renewal and one controlled 401 retry.
- Localized search/errors/refresh in English and Russian, number formatting.

### Changed

- Score DTO/model/card are shared by profile and leaderboard; no second parser.
- Public client allows GET requests to numeric beatmap/beatmapset detail and
  beatmap scores endpoints while retaining host/path restrictions.

- Profile composition is local: Main, domain/data, Bloc parts, widgets.
- Search/ruleset requests are latest-wins and cancel superseded transport work.
- Refresh preserves content and shows progress/failure; avatars have a fallback
  and bounded decoding, profile content uses one sliver scroll view.
- README describes the current app; completed foundations moved out of the
  active roadmap. Earlier migration commits remain in Git history.

### Fixed

- Ruleset changes no longer switch a searched player to the signed-in account.
- A late refresh cannot restore credentials after logout; storage writes are ordered.
- HTTP timeout covers response-body reading and aborts timed-out requests;
  typed exceptions survive retry instead of being wrapped again.

No release/version bump or store publication is implied. User verification
is pending; automated tests remain deferred.
