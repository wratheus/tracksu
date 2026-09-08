![Tracksu banner](assets/utils/1024x500_banner.png)

# Tracksu

[![Flutter 3.47.2](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart 3.13](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform: Android](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)](#platform-status)
[![License: MIT](https://img.shields.io/badge/license-MIT-A78BFA)](LICENSE)

An unofficial Flutter client for exploring player statistics, rankings,
beatmaps, scores, spotlights, and news from the [osu! API](https://osu.ppy.sh/docs/).

Tracksu is designed as a compact companion for osu! players who want to browse
the game's public data from an Android device. Most of the app is available
without signing in; osu! OAuth can optionally be used to open your own profile.

> [!IMPORTANT]
> Tracksu is under active reconstruction and is not currently distributed on
> Google Play. The old store listing was removed after its information became
> outdated and the original app depended on the deprecated osu! API v1.

## Features

### Player profiles

- Search for a player by username or user ID without signing in.
- Prefix a numeric username with `@`, for example `@12345`; an unprefixed number
  is treated as a user ID.
- View global and country rank, performance points, accuracy, play count, play
  time, maximum combo, and other available statistics.
- Real profile covers, level progress, grade counts and additional score/hit
  totals are displayed when available. Missing ranks are not shown as rank zero.
- Rank history uses API observations with visible gaps, not invented dates.
- Overview / Scores / Maps are separate lazy sections that retain visited
  content and scroll. Changing ruleset keeps the previous profile visible while
  loading, resets the mode-specific scores, and preserves the maps section.
- Switch between `osu!`, `osu!taiko`, `osu!catch`, and `osu!mania`.
- A single-row tap/drag selector replaces wrapping mode chips. Secondary
  statistics use compact icon-labelled metrics; PP and ranks have theme accents.
- Expand About me for a safe text rendering of the server's BBCode-derived
  HTML. Images/embeds/advanced styles remain available through the original
  profile link; missing rendered content falls back to escaped raw text.
- Browse best and recent passed scores with pagination.
- Browse most-played, favourite, ranked, graveyard, and other beatmap categories.
- Refresh each section independently without discarding already loaded content.

### Navigation

- Start in Search as a guest; login is optional in the account menu.
- Search / Rankings / News have independent retained stacks. The bottom bar
  stays visible on profile, beatmap and article details.
- Switching tabs preserves the destination's stack. Tapping the active tab
  returns to its root; the root's filters and scroll are not reset.
- Android Back pops details first, then returns from a secondary tab's root
  to the retained Search tab. Only Back at the actual Search root can exit.
- OAuth opens above the shell and closes back to the original context.
  Device gesture, cold-callback and restoration acceptance is still pending;
  see the [navigation checklist](tracksu-agent-ref/reference/NAVIGATION_SPEC.md).
- Router restoration covers destinations and identifiers, not the entire
  network cache or search/filter state after process death.

### Rankings and spotlights

- Browse global performance-point and score rankings for all four rulesets.
- Filter rankings by two-letter country code.
- Switch osu!mania rankings between 4K and 7K variants.
- Open any ranked player directly in the selected ruleset.
- Browse osu! Spotlights, their beatmaps, and server-provided player charts.

### Beatmaps and scores

- Open a beatmap set from a player score or profile collection.
- Browse available difficulties, star rating, duration, mapper, and metadata.
- View the public top scores for a selected difficulty.

### News, account, and experience

- Read the latest news from the osu! website in a lightweight in-app reader.
- Read formatted profile About pages and news through a shared native reader:
  expandable spoilers, bounded raster images and an image zoom viewer.
- External images load automatically; third-party hosts receive your IP address
  and may record requests. Video/unsupported embeds and full original styling
  remain available through the original-page action. Raw BBCode is a plain-text fallback.
- Optionally sign in through osu! OAuth, open your own profile, and sign out locally.
- Use the interface in English, Russian, German, French, Spanish, Japanese, or
  Simplified Chinese; the selected language is remembered between launches.
- Keep browsing through section-specific loading, empty, error, retry, refresh,
  and pagination states.

## Preview

![Tracksu Android preview](https://i.imgur.com/sAJppQf.png)

> The screenshot above shows the legacy Android interface. A unified visual
> redesign is planned after the active feature reconstruction is complete.

## UI foundation preview

The new [tracksu_ui package](packages/tracksu_ui/README.md) contains dark/light
Material themes and reusable components. App pages use the new components,
but the raw migration is not a finished redesign: per-page media, layout and
interaction improvements are still in progress. Inspect the independent,
API-free manual catalog with:

```sh
fvm flutter run -t lib/ui_catalog.dart
```

The catalog starts with avatars/images, flags/grades/mods, player/beatmap/score/
news cards, metrics, interactive line/bar charts and loading/empty/error states.
Samples are explicitly preview-only, using local artwork and no player API.
The catalog also includes offline rich text, nested spoilers and blocked-media
states, without fetching third-party images or tracking counters.
Osu-specific compositions live in `lib/src/_shared/ui`; the base package stays
independent of domain models. See the package README for contracts and recipes.

It uses the same Android app ID as the normal debug app. Run the default
`lib/main.dart` target again to return to the application.

## Platform status

| Platform | Status |
| --- | --- |
| Android | Active development; debug builds are available locally |
| Google Play | Not currently published |
| iOS | Host project will be recreated after the Android rebuild |
| Windows | Not part of the current supported build |

All current Android variants use debug signing. They are development builds,
not production releases, and are not guaranteed to update an older installation.
The current Android application ID is `io.github.wratheus.tracksu`.

## Getting started

### Requirements

- [FVM](https://fvm.app/)
- Flutter `3.47.2`
- Dart `3.13`
- Android SDK with `compileSdk 37`
- JDK `25`

The Android build uses AGP `9.3.2`, Gradle `9.7.1`, JVM target `21`, and a
minimum Android SDK of `26`.

### Local setup

1. Clone the repository and enter its directory.

   ```sh
   git clone https://github.com/wratheus/tracksu.git
   cd tracksu
   ```

2. Install the pinned Flutter SDK.

   ```sh
   fvm install
   ```

3. Copy `.env.example` to `.env`, then add your `OSU_CLIENT_ID` and
   `OSU_CLIENT_SECRET`. Never commit or publish these values.

4. Install dependencies and generate configuration and localization files.

   ```sh
   fvm flutter pub get
   fvm dart run build_runner build --delete-conflicting-outputs
   fvm flutter gen-l10n
   ```

5. Run the application.

   ```sh
   fvm flutter run
   ```

Run the code generator again whenever `.env` changes. Generated environment
files are ignored by Git and should not be edited manually.

> [!WARNING]
> Obfuscating a client secret does not make it private inside a distributed
> mobile binary. The current environment-based setup is intended for local
> development; a backend-for-frontend flow is planned before production release.

## osu! API and OAuth

Create an OAuth application in the OAuth section of your osu! account settings,
then place its client ID and secret in the local `.env` file.

Public guest browsing uses the client-credentials flow and does not require a
browser callback. Optional user sign-in requires the registered callback URL to
match this value exactly:

```text
https://wratheus.github.io/oauth/osu/callback/
```

Android App Links also require the correct signing-certificate fingerprint on
the external Pages host. A debug keystore created on another computer can have
a different fingerprint.

## Project structure

```text
lib/src/_core/             Application bootstrap, routing, networking, and l10n
lib/src/auth/              osu! OAuth authorization flow
lib/src/session/           Authenticated user session
lib/src/profile/           Profiles, scores, beatmaps, and presentation state
packages/tracksu_network/  Shared HTTP transport and request infrastructure
packages/tracksu_storage/  Secure tokens, OAuth transactions, and preferences
```

The active application uses feature-local data, domain, Bloc, and widget layers.
The removed legacy implementation is not an architectural reference for new work.

## Development checks

```sh
fvm dart analyze lib packages/tracksu_network/lib packages/tracksu_storage/lib
fvm flutter build apk --debug
```

The debug APK is generated at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Automated tests are currently deferred; behavior still requires manual device
verification. See the [changelog](CHANGELOG.md) for recent implementation work
and the [active roadmap](tracksu-agent-ref/plan/ROADMAP.md) for planned work.

## Roadmap

- Restore audio previews.
- Add beatmap mod filters and personal score tables.
- Complete the visual system and unified themes.
- Move production-sensitive OAuth credentials behind a backend service.
- Restore a supported iOS host after the Android application is ready.

Plans may change as the API integration and interface are validated. Historical
source builds remain available on the [Releases page](https://github.com/wratheus/tracksu/releases),
but they should not be treated as current production builds.

## Resources and attribution

Tracksu uses or references the following projects and services:

- [osu! API documentation](https://osu.ppy.sh/docs/)
- [osu! resources](https://github.com/ppy/osu-resources)
- [osu! website](https://osu.ppy.sh/)
- [osu! source code](https://github.com/ppy/osu)

Attribution does not replace a license. The origin, license, and distribution
rights of bundled assets must be reviewed before a public release.

## License and disclaimer

The original Tracksu source code is licensed under the [MIT License](LICENSE),
Copyright © 2022 Aleksandr Pavlenko.

The MIT License applies only to original source code created for Tracksu. It does
not grant rights to the osu! name, trademarks, logos, game assets, API data,
beatmaps, music, artwork, or other third-party materials. Those materials remain
the property of their respective owners and are governed by their own terms and
licenses.

Tracksu is an unofficial community project. It is not affiliated with, endorsed
by, sponsored by, or otherwise officially associated with ppy Pty Ltd or the
osu! team.

## Acknowledgements

With sincere appreciation to **peppy**, the **osu! team**, and the wider
**osu! community** for creating and maintaining the game, API, tools, and
ecosystem that inspired this project and made it possible.

Any mistakes or issues in Tracksu are solely the responsibility of its author.
Please [open an issue](https://github.com/wratheus/tracksu/issues) and report them
kindly so they can be corrected.
