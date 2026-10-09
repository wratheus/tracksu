# Tracksu flows

Rendered on GitHub from Mermaid; the same flows are a board in
`tracksu-design.html` and in the Figma file.

## Navigation map (ADR-010)

```mermaid
flowchart LR
  subgraph Home["Home /search"]
    Daily["Map of the day"] --> DailyPage["Day page"] --> History["Past days"]
    Packs["Beatmap packs shelf"] --> PackType["Packs of a type"] --> Pack["Pack"]
    Spot["Spotlights"]
  end
  subgraph Rankings["Rankings /rankings"]
    Players --- Teams --- Countries --- Kudosu
  end
  subgraph Hub["osu! /news"]
    News --> Article["Article + comments"]
    Events
    Forum --> Board["Board"] --> Topic["Topic"]
    Changelog
  end
  subgraph Search["Search /find"]
    SPlayers["Players"] --- SMaps["Maps"] --- SWiki["Wiki"]
  end
  Details(["Details: profile, beatmap, team, wiki, topic, pack, settings, sign-in"])
  Home --> Details
  Rankings --> Details
  Hub --> Details
  Search --> Details
```

## Sign in

```mermaid
flowchart LR
  A["Any screen: account menu"] -->|"Sign in with osu!"| B["Auth screen"]
  B -->|"Continue"| C["Safari: osu! OAuth"]
  C -->|"callback"| D["Code exchange, token stored"]
  D --> E["Back where you were"]
  C -->|"returned without code"| F["Auth screen: try again"]
```

## Game mode (ADR-011)

```mermaid
flowchart LR
  A["Rankings / Spotlights"] -->|"tap mode icon"| B["Game mode sheet"]
  B -->|"choose"| C["RulesetController (saved)"]
  C -->|"notifies"| D["Pages reload in the mode"]
  P["Profile / Team"] -->|"tap mode icon"| Q["Same sheet"] -->|"choose"| R["Only this page changes"]
```

## Search

```mermaid
flowchart LR
  A["Search tab"] -->|"focus"| B["Glass bar rides the keyboard"]
  B -->|"2+ characters"| C["Results: players / maps / wiki"]
  C -->|"tap"| D["Detail page"]
```

## Links inside content

```mermaid
flowchart LR
  A["Article / comment / wiki link"] --> B{"AppLinks"}
  B -->|"osu! page"| C["In-app screen"]
  B -->|"YouTube, non-https"| D["System browser"]
  B -->|"other https"| E["Single-page viewer (ADR-009)"]
```

## Loading

```mermaid
flowchart LR
  A["Page opens"] -->|"cache hit"| B["Content at once, no fade"]
  A -->|"network"| C["Skeleton after ~130 ms"] -->|"data"| D["Content fades in 260 ms"]
  D -->|"pull to refresh"| E["Content stays, app-bar line"]
```
