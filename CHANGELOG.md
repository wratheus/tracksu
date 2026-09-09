# Changelog

## Unreleased

### September feedback

- Profile details: previous-name sheet next to the username, team flag/name
  and group accents with official web links, ranked play per pool (rating,
  provisional status, rank, plays, first places and points), daily challenge
  streaks/placements and last participation dates. Missing sections stay absent.
- Earned medals have a count and lazy dated list. The profile API only supplies
  achievement IDs/dates; names/artwork await a verified metadata source. The
  sheet explains this and opens the official illustrated profile collection.
- Reusable affiliation tile and player-card name-action slot; all new labels
  generated from seven ARB locales. No additional requests for profile fields.

- Shared Tracksu share sheet: Telegram, WhatsApp, Facebook, X/Twitter composers,
  native system chooser (`share_plus`) and copy link. Available on search,
  rankings/Spotlights, news, profile, beatmap and result details, including
  difficulty-selection modals. Public osu! URLs only; no automatic posting.

- External rich-content images now require a persisted allow/decline choice;
  Account → External images exposes the same control for guests and signed-in users.
  Revocation cancels active requests. Failure/unsupported-address text is separate
  from disabled-by-preference text; avatars and map covers are outside this setting.

- Full-width beatmap banners, shared lazy card-list spacing, category icons,
  integer PP and localized compact profile/ranking counters (long-press for exact values).
- Monthly play-count history from `monthly_playcounts`, separate from replay views;
  shared full-history calendar chart, gaps retained instead of invented zeros.
- Player navigation from beatmap leaderboard result details.

### Refactored

- Moved live authorization from pages into auth: local composition, typed Bloc
  states/events, transaction/browser repository and lifecycle-only screen.
  Router owns success navigation. Removed the last pages file; palette retained.
  Reused en/ru strings, guarded duplicate callbacks/start and browser failures,
  and retained the callback URL, scopes and pending-transaction storage format.

### Removed

- 34 unused legacy assets (6,256,733 source bytes): old grade/mod PNGs,
  MyFlutterApp icon font and unused backgrounds/utility images including
  triangle.gif. Removed unused Palette; native splash resources, active
  flags/modes/Exo fonts and catalog artwork remain. Assets now use explicit
  utils entries; unused countries JSON is not bundled.

- 45 unreachable legacy Dart files: old Home/desktop navigation, drawer/error
  flow, profile/rankings/beatmap/news pages, Cubits, models, requests and helpers.
  Active authorization and palette remain unchanged; assets/storage are untouched.
- Direct dependencies on curved_navigation_bar, fluttericon, audioplayers,
  cached_network_image and provider. The latter two remain transitively required.

### Added

- Rankings now separate ruleset and PP/score selection, show player avatars and
  positions in the filtered table, and offer a local searchable country picker
  with existing flag assets. Only the selected ranking metric is emphasized.
  New filters reset scroll, while refresh/append and profile Back preserve it.
  Cross-page duplicate players retain earlier snapshots instead of jumping
  positions; refresh failures remain visible above the retained table.

- Beatmap descriptions now reuse the profile's native rich-content reader, with
  a shared typed page model, collapsible slivers, external-image disclosure and
  original-page fallback. Removed duplicate profile-only DTO/domain/widgets and
  unused localization keys. No additional API calls or WebView introduced.

- Result details retain sparse hit-result counts and perfect-play counts, plus
  typed mod settings. Missing values are not zero-filled, and unknown setting
  types are explicitly unavailable. The shared bounded sheet builds rows lazily
  and keeps a score snapshot while refreshes occur. Manual catalog sample included.

- Profile replay-view history uses API month/count observations, sorted and
  validated independently of core profile data, in local windows of 24 samples.
  Rank charts now have shape-preserving curves, subtle fill, fewer markers and
  a semantic accent; missing intervals stay disconnected and exact selection remains.

- Beatmap cards show optional covers, mapper/status and set-level plays/favourites;
  player play counts remain explicitly separate. Selected difficulty exposes
  stars, total duration and BPM when available. A lazy difficulty picker replaces
  the long inline list above the leaderboard; missing covers need no hero placeholder.

- Compact score cards now open a shared result sheet with PP, accuracy, combo,
  standardised total and exact local timestamp. Profile results retain a map
  action with the played ruleset; leaderboard results can also be inspected.
  No extra network request or replay playback is introduced.

- Mode selector: removed the default Material ripple/overlay, added explicit
  bevel-shaped press/focus feedback and one clipped subtle glass blur (solid in
  high contrast). Search uses an Open profile action with exact username/ID copy,
  without promising partial-name suggestions.

- Shared native rich-content reader for profile About and news: bounded HTML
  normalization, themed formatting, lazy blocks and nested disclosures, isolated
  public-HTTPS raster loading, static animation previews and a reusable zoom
  viewer. External-image/IP disclosure in all seven languages; no consent toggle
  or legal-page publication in this slice. Unsupported embeds open the original.
  Added offline reader samples; removed the superseded text-only sanitizer.
- Profile feedback: one-row draggable mode selector with a beveled, lightly
  translucent highlight and shape-matched ink; compact secondary metrics,
  decorative stat icons, theme accents for PP/ranks, and PNG language flags.
  Active-tab reselect now returns to that branch's root; switching to another
  tab still restores its stack. Root filters/scroll are not deliberately reset.
- Expandable About me from API page.html, with escaped raw BBCode fallback.
  Shared allowlisted HTML/HTTPS-link handling extracted from news without
  relaxing its policy. Script/style/embedded media are never rendered; links
  open externally. Oversized/deep optional content offers the original profile
  rather than hiding valid statistics. Five new messages in all seven locales.
- Deferred product backlog for social features, push, player comparisons and
  possible BFF-backed AI recommendations/PP simulations; no scopes or SDKs added.

- Product profile overview with API-backed cover, level progress, grade counts,
  optional score/hit/replay totals and rank history. Metrics use separate labels
  and locale-aware values; nullable ranks/play time no longer become fake zeros.
  Overview / Scores / Maps retain visited sections, scroll and local Blocs.
  Ruleset switching preserves previous data, handles latest-wins responses and
  retries the failed mode; only the score section resets on a successful switch.
  Rank charts support explicit gaps and isolated observations without invented
  dates. Added 25 messages in all seven locales and tightened numeric ID input.

- Stateful Search / Rankings / News navigation with go_router 18: independent
  lazy branch stacks, persistent themed UiNavigationBar on details, retained
  tab content and Android Back-to-Search root policy. Separate guest search
  landing opens typed ID/username profiles; profile pages no longer own search.
  Route restoration IDs and seven-language navigation/fallback labels included.
- Root OAuth overlay now returns to its previous context instead of clearing
  the shell. Session-status notifications update the account menu after cold
  callback, logout and session invalidation without exposing credentials.
  Android callback handling stays exclusively in app_links; Flutter's parallel
  deep-link handler is disabled to keep callback parameters out of router state.
- Per-page product integration queue and a separate privacy/terms/disclosures
  release gate, based on actual storage and external data flows. No public
  legal policy or external publication was created.

- Product UI catalog: bounded images/covers, avatar fallbacks, semantic badges,
  content states/skeletons, metrics and selectable line/bar charts. Shared osu
  compositions now include player/profile, beatmap, score and news cards plus
  flag/ruleset/grade/mod primitives. Seventeen labels translated into all seven
  ARB catalogs. Preview data only; no production page, API or routing changes.

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
