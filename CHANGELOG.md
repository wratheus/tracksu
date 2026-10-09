# Changelog

## Unreleased

### Sheets, pickers, glass

- Short sheets (e.g. "Previously known as") no longer close the moment
  they open: a sheet fitted exactly to its minimum height was taken for a
  dismissal. Option lists use the app's chamfered rows with an icon chip
  and a check for the selected one.
- The category dropdown is a chamfered glass button: the choice's icon,
  a small caption with the picker's title, the value, and an unfold mark.
- Pausing the preview stops the timeline where it is instead of letting it
  glide on to the next expected position.

### Smoother player, glass search, tidy filters

- The preview player glides: the timeline eases between position reports,
  the play disc and icon morph, and a short rebuffer no longer flips it to
  a spinner and back.
- Search: a Liquid Glass capsule floating over the results — frosted, a
  light rim, hint and text centred on one line.
- Comment sorting uses the app's compact picker instead of a segment row.

### Beatmap packs (P55, wave 3 step 2)

- Home gains a Beatmap packs shelf: a tile per type (Standard, Featured
  Artist, Tournament, Project Loved, Spotlights, Theme, Artist/Album),
  each with its own colour and a one-line description.
- A type opens its packs: tag, name, date and author, ruleset; older packs
  load at the end. A pack shows its header and its beatmapsets.
- osu! pack links open in the app.
- Rows carry their type's colour and icon (the list has no covers). Typing
  a tag (S1500) opens that pack; other text filters the loaded packs.

### Smoother loading

- Placeholders wait a beat before fading in, so quick loads (cache, fast
  network) never flash them; content fades in over them instead of
  popping (lists, wiki, forum, events, changelog, map of the day).
- Sheets lose their close button: swipe down or tap outside.
- The search field is a floating capsule with a focus ring and an inline
  clear button.

### Map of the day, dressed up

- The map of the day is a poster: the cover fills the card with the title
  on it, glass chips for the day and the time left, the preview in the
  corner — on Home and on its page.
- The top three stand on a podium (gold, silver, bronze); a past day reads
  "Final leaderboard" instead of "Today's leaderboard".
- History rows show each day's cover fading in behind the text.
- Home drops the search card (search is a tab); the Spotlights archive
  stays at the bottom of Home (Rankings is crowded enough).

### Navigation by the iOS guidelines (ADR-010)

- App bars keep two actions, share and account; Settings moved into the
  account menu. The search pill left the bar.
- The bottom bar is Home / Rankings / osu! plus a separate round Search
  button (iOS 26 search tab). Search shows its tabs under the bar and the
  field at the bottom above the keyboard.

### Polish

- App bars name the place, not the item: Wiki, Forum, Map of the day. Wiki
  articles show their title once (the article's own `# Title` is
  dropped); a past day's date moves onto its card, and long difficulty
  names take two lines.
- Settings: images is one switch row with the explanation below, like the
  cache group; switches are the app's own chamfered, animated control.
- The back button loses its outline.

### Search from every app bar

- A search pill sits first in every app bar ("Search" on tab roots, icon
  only on pages) and grows into the search field when tapped.
- The search screen keeps the field in the bar, tabs below; the 2 pt
  overflow under the tabs is gone.
- Wiki flags (`::{ flag=NL }::`) show as flag emoji and user markers as
  profile links instead of raw syntax.

### osu! forum (P54, wave 3 step 1)

- The osu! tab gains a Forum page: forum sections with their subforums.
- A forum shows its description, subforums, pinned announcements and
  topics by latest post, loading older topics at the end.
- Topics read like articles: posts in order with quotes, spoilers, images
  and links, the author's avatar and name opening their profile.
- Forum links from news, comments and other pages open in the app.
- Read only: replying needs a signed-in user (after P37).

### Steady app bar

- Title and actions no longer jump by a few points between screens: rows
  under the bar get exactly the height they need, measured from the text
  size, so the toolbar is never squeezed.
- A compact back button in the style of the segmented controls replaces
  the default arrow on every screen.

### Links stay in the app (P53, ADR-009)

- osu! links in news, profiles, comments, changelog, wiki and teams open the
  wiki article, profile, beatmap or team screen in the app.
- Other https pages open as a single page: title and site in the header,
  share, progress, no address bar. Links inside the page open in the system
  browser, so the app is not a general-purpose browser.
- The whole changelog entry row is tappable; the chevron shows the text.
- Added `webview_flutter` (flutter.dev, BSD-3) for the page viewer.

### Search, events and wiki fixes

- The search field is focused when Search opens. Player rows match other
  tiles: rounded square avatar, name with supporter and online marks,
  country and team flags below.
- Opening a player from search no longer waits for an extra lookup: the
  profile loads in the player's default mode in one request.
- Events no longer hammer the API: a group (Ranks, Medals, …) only
  filters the loaded feed and never pages by itself; "Load older" fetches
  one page per tap, and an empty group says so. Only "All" pages
  automatically; at most one page request per second.
- Wiki `::: Infobox` / `::: Notice` blocks render as framed boxes.

### osu! wiki (P52, wave 2 step 3)

- Search gains a Wiki tab: find guides, rules and game mode articles; results
  page as you scroll.
- Articles open in the shared reader with images, tables, code and quotes,
  in the app language with an English fallback. Links to other wiki articles
  stay in the app; others open in the in-app browser.

### Unified rich content and Markdown (ADR-008)

- All rich text goes through one pipeline: HTML, BBCode and Markdown are
  adapted to HTML, filtered by the same allowlist and shown by the same
  reader with images, audio, video, links and spoilers.
- Profile "About me" renders the Markdown players type as plain text:
  headings, quotes, bullet and numbered lists, rules, bold, italic, code,
  strikethrough and links. Pages without Markdown look exactly as before.
- Added the `markdown` package (dart-lang, BSD-3) for the wiki and these pages.

### Global osu! events (P51, wave 2 step 2)

- The osu! tab gains an Events page between News and Changelog: the live
  feed of ranks, lost first places, medals, map uploads and status changes,
  supporter tags and name changes, with the player's name on each row.
- Rows open the beatmap, the beatmapset or the player's profile; older events
  load at the end. Profile activity shares the same rows.
- Events can be narrowed to Ranks, Medals, Beatmaps or Supporters and names.
  The API has no type filter, so the app groups the loaded events; older
  ones load on request.

### osu! tab and changelog (P50, wave 2 step 1)

- The News tab becomes **osu!** with News and Changelog pages switched by the
  segmented control or a swipe; each page keeps its scroll and refreshes by
  pulling down.
- Changelog shows every update stream (latest version, active players) and
  builds with entries grouped by category, add/fix/misc markers, authors and
  pull requests. Entries expand to their full text and open on GitHub.
- Web links (changelog, comments, articles, About, teams, groups) open in an
  in-app browser sheet instead of leaving the app; YouTube opens its own app.
- API requests carry the app language, and changing the language clears
  cached pages so the next visit loads localized data.
- Player search rows show the country flag after the name instead of the
  country code.
- Audio previews play at 35 % player gain; full gain was harsh even at low
  system volume.
- Progress lines under the app bar appear only after 600 ms of work and then
  stay at least 400 ms, so quick loads show nothing and the line never
  blinks. Medals, teams and spotlights moved their in-list strips there too.
- Settings → Cache has one switch to turn all caching off: page snapshots are
  not kept, images stay in memory only, and an audio preview's file is deleted
  after it plays. Turning it off deletes what was stored.
- Cached audio lives 12 hours with its own 24 MB budget (oldest first);
  images keep 7 days within the shared 128 MB.

### Profile activity and lazer grades (P49, wave 1)

- Grades SS/S/A/B/C/D/F are drawn like osu!lazer: a pill in the grade colour
  with soft triangles, gold SS/S, silver for Hidden/Flashlight variants and
  dark letters for A–D. Screen readers say "Silver S" instead of "SH".
- Profile results add Pinned and First places next to Best and Recent.
- New profile Activity tab: ranks, lost first places, medals, beatmap uploads
  and status changes, supporter and name changes, with links to the map, set
  or medals. Pull to refresh; older events load at the end (up to 100).
- Grade badges follow the website proportions: capitals at 55 % of the height,
  optically centred, wide letters with a soft lower shadow.
- Profile tabs are Profile / Results / Activity / Maps. The profile page now
  follows osu.ppy.sh order: header, friends and mapping subscribers, team,
  rank history, daily challenge, grades in one row, About, statistics with a
  compact level line, then medals and charts.

### Unified AppBar search (P48)

- Replaced the large player lookup form with a compact entry to Players / Maps.
  Both tabs share a field in the AppBar and retain its text on tab changes.
- Player suggestions work for guests with 400 ms debounce, immediate Enter,
  exact ID / @username lookup, pagination up to 100 accounts, and profile opening
  in the player's preferred ruleset. No ruleset choice is needed before searching.
- Cancelled queries cannot replace newer results. Search caches are bounded,
  live for two minutes, and rate limits display an explicit retry state.
- Map search retains filters, cards and paging; existing beatmaps routes redirect
  to the Maps tab. Empty searches do not issue API requests.
- Shared AppBar integrates search/ranking tabs and profile mode selection.
  Ranking share links and progress now match the visible ranking page.
- Updated all seven translations and added behavioral and large-text UI checks.
- Every screen now ends its AppBar with the same controls in the same order:
  Share, Settings and the account button, so signing in is reachable from any
  tab. Share stays visible (disabled) while loading.
- Removed AppBar Refresh buttons: every page refreshes by pulling down. Medals,
  teams and spotlights gained pull-to-refresh.
- The search field moved under the title to keep full width; search, daily
  challenge and its history gained website share links.
- Removed the API-naming note under mod settings in score details.

### Daily history, search filters, beatmap details and Kudosu (P44–P47)

- Map of the day links to past days with dates, difficulties, mods and final
  leaderboards. History loads up to 250 recent days; failed refresh or paging
  keeps visible rows and Retry repeats the failed request.
- Beatmap search supports all rulesets, genre and music language, with filters
  retained during pagination.
- Beatmap leaderboards can filter by mods, including No Mod and reset to all;
  incompatible choices are exclusive and cached results are scoped by filter.
- Selected difficulties show CS/keys, HP, OD and AR as applicable, plus available
  combo, object, play and pass statistics. Missing optional data stays absent.
- Rankings add a Kudosu tab with up to 1,000 contributors, profile links and
  available kudosu in a tooltip. Ruleset and PP/Score controls hide on this tab.
- Added complete English, Russian, German, French, Spanish, Japanese and
  Simplified Chinese strings for these features.

### Rankings pages, countries, comments polish

- Players / Teams / Countries are swipeable pages under a fixed header with
  the page switcher and the shared ruleset and PP/Score filters; country
  and 4K/7K stay on the Players page. Each page keeps its own scroll.
- Countries get the PP/Score view (osu! still orders them by PP) and show
  long names on two lines with the value below.
- Comment threads are soft cards with reply guide lines; votes are a
  heart pill; Reply and votes open the comment on osu.ppy.sh (the API lets
  only the official client vote or post).

### Faster profile tabs, linked tab switcher (P42)

- Opening a profile starts loading Results and Maps in the background, so
  switching tabs shows data right away; first pages stay in the session
  cache.
- The profile and About tab switcher switches as soon as a page is swiped
  past halfway instead of after it settles.
- About says the app is built with Flutter.

### Beatmap search (P41)

- Home has a Beatmap search entry: search by title/artist/mapper, ruleset
  and status (has leaderboard, ranked, loved, pending, graveyard…), with
  endless scroll and the usual beatmap cards.

### Country rankings (P40)

- Rankings have a third tab, Countries: flag, localized name, PP and active
  players per ruleset. Tapping a country opens the player table for it.

### Comments (P39)

- News posts and beatmaps show comments: New / Old / Top sort, pinned
  first, endless scroll, replies on demand, votes, relative time; avatars,
  names and profile links open the profile. Beatmaps switch between
  Results and Comments at the bottom.

### Videos and embeds in news (P38)

- osu!-hosted videos play inline (tap to load, controls, full screen).
- YouTube embeds show a preview card that opens YouTube; other players
  open their page.
- Posts with many track previews (over 32) open again.

### Mod icons (P35)

- Mods everywhere are small chips with the official osu! icon (from
  ppy/osu-resources, tinted by mod type as in osu!lazer) and the acronym;
  the full name is in the tooltip. Unknown mods keep a neutral icon.

### Ranking rows

- Ranked score values no longer carry a "Ranked score" caption (players,
  teams, Spotlights); PP keeps its unit. Teams keep the PP/Score switch,
  but the osu! API orders them by PP in both views.

### Map of the day (P34)

- Home shows osu!'s current daily challenge under the search card: cover
  with preview, time left, ruleset, stars, difficulty, required mods and
  participants. Pull down to refresh. Tapping opens a page with the map
  and today's leaderboard (players open their profile, teams their page).

### Team rankings (P33)

- Rankings have a Players / Teams switch. Teams use the shared ruleset,
  load 50 per page with auto-load and pull-to-refresh, and open the team
  page. Rows show the team flag, rank, name, PP or score, tag and member
  count. Backed by osu-web's undocumented `rankings/{mode}/team`.

### iOS app icon

- The iOS app uses the same "Tracksu!" logo as the Android launcher.

### Settings and About (P36)

- Settings are a grouped list: account header, then rows with the current
  value on the trailing edge (language, theme, cache size) and footnotes
  for explanations (`UiTile.value`, `UiTileIcon`, `UiListGroup`).
- About has two labelled tabs: About (app, short history since 2021,
  authors Repentance and Sgooll opening their profiles, links, thanks) and
  Licenses (the searchable list, embedded).

### Glass controls, app-bar progress, licenses screen (P32)

- `UiGlass` frosted material for floating controls; the audio capsule and a
  new round scroll-to-top button use it (no saturated pink pill).
- Profile section tabs reuse `UiSegmentedControl`, synced with swipes.
- Refresh/ruleset-switch progress is one 2 px line under the app bar
  (`UiAppBarProgress`) on profile, rankings and settings; pull-to-refresh
  replaces the rankings refresh button and in-content loaders.
- Licenses: themed, searchable screen with an intro and per-package sheets
  instead of Flutter's stock page.
- Profile score/map tabs and the beatmap page refresh by pulling; their
  refresh buttons and in-list loaders are gone (`PageActivity` feeds one
  app-bar line). Beatmap page order: card, difficulties, description,
  leaderboard.
- Explicit platform page transitions (Android fade-forward, iOS native
  slide) and a softer 260 ms content reveal.
- Shared `OsuCategoryPicker` for profile scores and maps.
- Missing values (no rank, no PP, no play time) are small secondary text
  instead of headline numbers; empty list states are quieter.

### Compact filters, osu! colours, supporter heart (P32)

- Profile maps: one category selector line opening a grouped sheet
  (Player / Mapper) plus a refresh icon, replacing eight wrapped chips and a
  text button; scores use one line of two chips and a refresh icon.
- Beatmap difficulties: one horizontal strip of star-coloured ruleset pips
  (osu-web order and colours) with a star badge and the selected name.
- Hit results and grades use osu!lazer colours; the accuracy arc takes the
  grade colour and the grade letter is large, heavy and glowing.
- Team members: pink osu!supporter heart right after the name (also in the
  profile header); one presence line with a status dot instead of
  "offline" plus a separate last-seen line.

### Avatar grid and modern audio capsule (P32)

- Text beside an avatar now spans exactly its height (`OsuAvatarBands`): the
  top band starts on the avatar's top edge, the bottom band (flags, value
  label, status) ends on its bottom edge; line leading is trimmed at both
  ends. Ranking rows use a 72 px avatar, the profile header 96 px; the
  previous-names icon aligns with the name, the ID sits beside the avatar.
- `UiAudioPlayer` is a capsule: idle it is one 44 px round control; playing
  it expands to a slim 4 px timeline with elapsed/total time. Loading shows a
  ring, failures an icon and the cause. Over artwork the active capsule is
  frosted glass (no blur when idle, to keep long lists cheap).

### Spotlights: osu-web data contract and start-screen entry

- Spotlights moved from Rankings to the start (Search) screen as an archive
  card; the feature now lives in `lib/src/spotlights`. Rankings no longer link
  to it. Route `…/spotlights` is unchanged and still exists in every branch.
- Root cause of the empty catalog: chart 68 "Best of 2012" has
  `start_date` 2013-02-01 and `end_date` 2013-01-31 in the live API. osu-web
  stores these as staff-entered descriptive dates, never validates or uses
  them, and renders both verbatim. The DTO no longer imposes an ordering rule
  (and no longer drops such dates); the UI shows "Start date" and "End date"
  as two facts instead of a range. Malformed date strings still fail.
- Domain gains `SpotlightKind` from `type` (monthly, best of the year,
  special, theme; unknown values stay `other`), shown as a badge and in the
  catalogue picker. Catalogue search matches name/ID; names carry the year.
- osu-web answers 404 when a chart has no table for the requested ruleset.
  For a chart from the catalogue this is now a "No ranking for this ruleset"
  empty state, not an error with a pointless Retry.
- New/changed strings in all seven ARB files; `spotlightsPeriod/Starts/Ends`
  removed. Tests: repository contract (real chart 68 data, kinds, malformed
  date) and Bloc ruleset-404 → empty state → back to a loaded ruleset.

### Typed audio failure messages

- `AudioPlaybackController.failure` classifies a failed attempt as network,
  unavailable (404/410, blocked source), unsupported (decoder rejection,
  invalid format, too large), focus or unknown; the player shows a matching
  localized message. Previously every failure, including iOS decoder -11800,
  told the user to check the connection. Logging is unchanged (no URLs).

### Navigation, languages and media (P29 follow-up)

- Long main screens show a shared scroll-to-top button after about one
  viewport; re-tapping the active tab scrolls its root to the top (also after
  returning from details) without resetting filters or refreshing.
- The language picker and the current setting show each language in its own
  name (English, Русский, Deutsch, Français, Español, 日本語, 中文).
- Avatar/cover decoding errors no longer evict healthy cached bytes; typed
  download failures propagate unchanged.
- Removed the template counter test that never matched the app.

### Rankings rows, scroll-to-top clearance (P30)

- Ranking rows: rank, name and metric share one alphabetic baseline; flags and
  the metric label form a second line; narrow widths/large text stack instead.
- Long pages reserve exact space under the last item for the scroll-to-top
  button, so the final action stays tappable at max extent.

### Rankings list identity during refresh

- The loaded rankings group is a positional sliver list whose optional leading
  refresh slivers and trailing auto-load shift the unkeyed list sliver between
  rebuilds, so its rows were deactivated despite their own keys. The list
  `SliverPadding` now has one constant `ValueKey<String>('rankings-list')`.
- Pinned formatter/analyzer, diff-check and iOS simulator build passed.
  Parent's earlier instrumented before/after refresh retained the sampled list
  and visible-row identities, but did not capture the in-refresh transition.
- Refresh retention, absence of repeated cold skeleton/scroll reset,
  pagination and Retry remain unverified by GUI; P29 awaits manual check.

### iOS Ogg Vorbis previews

- Added `audio_decode` 1.3.5 (MIT; compiles stb_vorbis MIT/Unlicense and
  minimp3 CC0 through a Dart build hook, no plugin or pod). On iOS a validated
  Ogg Vorbis preview is decoded once in a background isolate and cached as a
  16-bit WAV; MP3 and non-iOS Ogg keep the native path. Legacy cache entries are
  classified by their bytes, not their `.mp3` suffix.
- Before native decode, a structural preflight accepts only one complete
  logical stream (1–2 channels, 8–48 kHz, standard block sizes) and bounds
  decoded PCM to 16 MiB. The claimed end granule is checked before decoding;
  actual decoded duration is checked afterward and accepted output is at most
  45 s. One decode runs at a time, four slots bound full payload lifetimes,
  and stale results are never written. Codec notices are under About → Licenses.
- Status: awaiting user acceptance. Analyzer and iOS simulator build passed;
  parent verified real preview873811 playback, pause/seek/resume and MP3 control518
  on the existing iPhone17. The quaver card shows Pause/progress without its old error.

### Rich-content image diagnostics

- Preserve privacy-safe typed HTTP/size/format/transport failures. Missing upstream
  images (404/410) show compact source-unavailable cards instead of huge placeholders
  and a misleading format message; transient failures retain Retry.
- Invalidate old request identity before a null-URI branch; distinguish paused
  loaders from blocked addresses. All seven locales were generated from ARB sources.
- Reproduced lifeline's two expired-source images: proxy and origin return404;
  the client cannot restore missing upstream bytes. A healthy PNG from that same
  profile cold-loaded and decoded at960×1780; no broad format expansion was needed.

### Correction 2: team load and skeleton transitions

- Public API client now allows `GET /api/v2/teams/{id}[/{ruleset}]`; before,
  team requests failed locally with `StateError` before any network call.
- `UiPageSkeleton` pulses with one controller per page (static under reduced
  motion). New `UiReveal`/`UiSliverReveal` and `UiMotion` tokens fade content in
  once on cold load (news, team, profile, rankings, beatmap, medals); images fade
  in without a spinner flash, synchronous cache hits stay immediate.
- Initial developer pass ran format/analyzer only. Subsequent parent simulator
  cold-load QA covered team/news and all four team rulesets; full GUI acceptance,
  large-font/reduced-motion coverage and ranking-list identity follow-up remain open.

### Correction 1: audio formats, inline images, ranking row

- Media cache accepts first-party Ogg Vorbis previews in addition to MP3,
  recognized by payload signature; cached files get the matching `.ogg`/`.mp3`
  suffix and `CachedAudio` exposes the format. Other codecs remain rejected.
  Whether iOS plays Ogg natively is not yet verified.
- Inline rich-content images keep their intrinsic ratio and are never upscaled;
  authored width/height are maxima. Placeholders are bounded on both axes and
  decoding follows the display size and device pixel ratio.
- Ranking rows center the avatar against name/position; flags sit in a band below.
- `UiAudioPlayer` is controls-only; `UiPageSkeleton.news/article` added.
- Verified before this correction: analyzer and iOS build. Not verified: tests,
  Android, audio playback, final visuals.

### September 22 feedback: cached media and browsing

- Added a shared persistent image/MP3 repository: coalesced requests, bounded
  downloads, atomic writes, seven-day expiry and 128 MiB / 500-file eviction target.
  Settings displays completed file size and clears media plus page snapshots,
  stopping playback first. Decoder-owned files stay pinned until disposal.
- Images now load by default with a Settings opt-out; previous explicit opt-outs
  remain respected. All network image consumers share the same policy/cache.
  First-party CDN requests use platform DNS/TLS; arbitrary external images retain
  checked-address connections. Raster signatures, not unreliable MIME headers,
  determine supported formats; compressed HTTP responses are supported.
- Added compact cover players to map cards/details, spotlights and score sheets;
  rich content also recognizes supported direct MP3 links. Removed the repeated
  Play connection paragraph; disclosure remains in Settings. No autoplay.
- Fixed the retained Search form staying disabled after returning to its root.
- Country/team flags are 30×20, avatars are squarer and ranking identities align
  at the avatar baseline. All 224 country entries have seven-language CLDR names,
  with bundled Unicode attribution. API availability is unchanged.
- Static analysis only; device playback, networking and visual acceptance pending.

### Asset provenance and native cleanup

- Matched all 225 flag PNGs to a pinned historical osu-resources revision and
  registered its CC-BY-NC 4.0 attribution/license links alongside the Exo 2 notice.
  This does not approve commercial distribution or license other app artwork.
- Removed eight unreferenced Android PNGs (610,464 source bytes); active launcher
  and density-specific splash assets are unchanged. No APK-size claim is made.
- Corrected the asset plan: countries.json now powers the country picker and
  must remain bundled. Torus/Venera need separate licensing; Exo 2 stays in use.

### Shared foreground audio

- Added an application-owned single-track player and reusable UiAudioPlayer:
  explicit play, pause/seek/replay, cancelable loading, timeouts and retry.
- Beatmaps consume preview_url; the rich reader extracts supported first-party
  MP3 audio/source blocks without forwarding media HTML to the renderer.
- Route/branch ownership, interruption/background handling and lazy-list keep-alive
  prevent overlapping tracks and accidental auto-resume. No background service.
- Seven-language Play disclosure is independent of external-image permission.
  Existing just_audio/audio_session versions promoted to direct dependencies.
- Verification is static only; device playback and layout acceptance remain open.

### Collection cache coverage

- Extended the bounded session page cache to medals, spotlight catalog/details
  and beatmap leaderboards. Keys distinguish player, chart/mode and difficulty/
  mode/legacy variant; only successful responses replace immutable snapshots.
- Reopening shows cached content while revalidating, cold loads use shared static
  skeletons, and failed refreshes retain content with Retry. Cache clearing and
  account-identity invalidation use the existing revision guards.
- Added explicit droppable/concurrent BLoC policies and complete leaderboard
  provider keys; rapid selections cannot write obsolete spotlight responses.
- Fixed the team cold-load box/sliver mismatch and misleading failure text while
  a team ruleset change is still in progress. Audio remains planned.

### Teams and compact rankings

- Added a native public team page: cover/flag/tag, description, recruitment and
  free slots, leader/roster with profile navigation, and per-mode API statistics.
  Team flags in profiles, rankings and spotlights open it inside the retained
  navigation branch. Website-only management and extra statistics are not faked.
- Team BBCode uses a bounded adapter and the shared consent-aware content reader.
  Team data uses session-memory snapshots, cold skeletons and latest-wins refresh;
  failures retain usable data. Sharing and seven-language labels are included.
- Rankings and spotlight rows now show a yellow position and a right-aligned
  performance/score column, with smaller avatars and preserved country/team flags.
- Settings access no longer depends on the account action's busy state; a shared
  button is available on the main browsing pages, including loading/error states.
- Static analysis only; device/layout/navigation verification remains manual.

### Seamless collections and shared presentation

- Removed manual load-more buttons from news, rankings, profile scores and maps.
  Shared sliver trigger debounces near-end visibility, pauses off-route/inactive,
  and handles short viewports without a scroll gesture. Explicit BLoC concurrency,
  busy guards and generation checks prevent duplicate/stale work; repeated pages
  stop with Retry instead of an automatic request loop.
- Extended first-page memory snapshots and cold-load skeletons to profile scores
  and map collections. Successful refresh replaces data; failed refresh retains it.
- Shared loaders now use a centred compact column with rounded progress and the
  label below it. Medal/spotlight loading and country-picker sheets centre in their
  available viewport; content-fitting sheets do not grow from fill-remaining states.
- Team flags sit beside country flags at matching 28×20 size and corner radius,
  including profile/rankings/spotlights and map result cards/sheets when supplied
  by the API. No extra per-player requests; detailed profile affiliation stays.
- Added `pubspec_generator`: version/build come from `pubspec.yaml`, while the
  installed package ID still comes from the platform. No hardcoded version copy.

### September feedback: media, loading and results

- Fixed the rich-image HTTPS connection factory: explicit TLS and hostname
  validation after checked DNS/IP connection, with TCP address fallback.
  Consent, redirect/address/type/size limits and cancellation remain in place.
- Added bounded session-memory snapshots for profiles, beatmap details, news
  feed/articles and ranking queries. Cached content stays visible while refreshing
  and on refresh errors; first loads use shared static skeletons. Snapshot keys
  distinguish modes/queries and are invalidated on account changes.
- Shared rich-image memory LRU and settings cache clearing (also clears Flutter's
  decoded image cache). This is not cross-launch disk/offline storage.
- Score sheets now have a full-bleed, rounded cover header and a grade/accuracy
  gauge inspired by lazer, not a hit-count pie chart. API grades remain authoritative;
  hit counts/ratios have their own legend. Monthly profile charts are unchanged.
- Replaced the difficulty strip with bounded wrapping chips and a full lazy picker.
  Reduced leaderboard spacing, centered initial medal loading, removed empty daily
  challenge statistics and unearned weekly dates. Large counts now show grouped
  exact integers in compact rows rather than ambiguous large-unit abbreviations.
- Home sharing targets Tracksu on GitHub; classic selector label is `ctd`.
  Language selection is settings-only, with its selected PNG flag. Keyboard no
  longer reserves hidden bottom-bar space; theme transitions use eased timing
  and respect disabled animations.
- Audio playback and wider page-cache coverage remain planned. Liquid Glass and
  Dynamic Island/Live Activities are deferred. No tests/APK/device launch.

### About and licenses

- Added About from settings, with installed version/build/package metadata,
  retry on metadata failure, project/osu! links and a clear unofficial-client note.
- Bundled dependency licenses open inside the retained navigation branch.
  Exo 2's OFL 1.1 copyright/license notice is bundled and registered separately;
  existing font binaries and typography are unchanged.
- package_info_plus 10.2.1 is now a direct dependency at its existing locked
  version. All new About labels support seven locales. No analytics, policy
  placeholders, external publishing or automatic browser navigation.

### Settings

- Grouped account, appearance and external-image controls on a dedicated
  settings screen, with a guest/signed-in summary and separate sign-out action.
- Persisted system/light/dark theme preference using the existing storage
  dependency. Applying a choice retains the router and branch stacks; an
  unreadable preference falls back to system, a failed save retains the old mode.
- Shared language sheet with PNG flags and current selection in both settings
  and the toolbar. Account-menu entries now include icons and share the same
  cancellable sign-out confirmation as settings. Repeated actions are guarded.
- Six new settings labels translated in all seven ARB locales. No new network
  endpoints, dependencies, analytics or unfinished legal links.

### News

- News cards now use API high-resolution previews, localized dates and shared
  list spacing. Article headers use consistent typography and gutters; refresh
  and append progress stay compact while existing content remains visible.
- Preview images follow the existing device-level external-media choice, with
  one prompt in the feed. A shared bounded queue cancels requests on hidden
  routes/branches, backgrounding and permission revocation; decoded previews
  survive a covered route. No API credentials, cookies or new dependency.
- The native article reader remains responsible for inline images, avoiding a
  duplicate first-image banner. Original-page and sharing actions are retained.

### Spotlights

- Replaced text-only maps/players with shared banner/player cards, flags, team
  badges when supplied, table positions and compact scores with exact tooltips.
- Spotlight period and participant count come from the existing API responses;
  the participant total is separate from the server's top-40 ranking.
- Searchable lazy catalogue sheet by name/year/ID preserves the underlying
  page on dismissal. Shared single-row ruleset selector replaces wrapping chips.
  Seven locales; no new endpoint, dependency, auth scope or persisted data.

### September feedback

- Follow-up UI pass: content-fit draggable list sheets, selection chips without
  redundant checkmarks, stronger Exo 2 metric weight and prominent world rank.
- Pink monthly-play bars retain calendar gaps. Daily challenge, team and ranked
  play move above general statistics; team flags appear beside player avatars.
- Beatmap details use high-resolution wide covers and a horizontal difficulty
  strip with a full-list sheet. Score details show banners, player avatars,
  ruleset-specific judgments and recorded-hit proportions instead of raw keys.
- Dedicated settings route for image permission/account actions, account-avatar
  menu, and account-change notification without notifying on token refresh.
- Profile details: previous-name sheet next to the username, team flag/name
  and group accents with official web links, ranked play per pool (rating,
  provisional status, rank, plays, first places and points), daily challenge
  streaks/placements and last participation dates. Missing sections stay absent.
- Earned medals open a dedicated illustrated collection with names/descriptions
  and award dates. An isolated public web client reads the official osu! profile
  bootstrap (not a stable REST endpoint), without cookies or auth tokens. Typed
  repository/BLoC, cancellation, retry and stale-data preservation isolate failures.
- Reusable affiliation tile and player-card name-action slot; all new labels
  generated from seven ARB locales. No additional requests for profile fields.

- Shared Tracksu share sheet: Telegram, WhatsApp, Facebook, X/Twitter composers,
  native system chooser (`share_plus`) and copy link. Available on search,
  rankings/Spotlights, news, profile, beatmap and result details, including
  difficulty-selection modals. Public osu! URLs only; no automatic posting.

- External rich-content images now require a persisted allow/decline choice;
  Settings → External images exposes the same control for guests and signed-in users.
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
