# Реализованная основа — архив активных шагов

Сверка 2026-09-07. Здесь факты кода/истории, не второй backlog и не заявление
о полной ручной проверке. Остатки каждого этапа находятся в ROADMAP.

Новый checkpoint: P07.2 go_router + три stateful branches, отдельная главная
поиска, typed detail routes и OAuth overlay; UiNavigationBar и status-only stream
аккаунта. Ручная приёмка в NAVIGATION_SPEC. Cleanup 34 assets/Palette — 9a70de5.

| Область | Что уже не требуется начинать заново | Опорные коммиты |
| --- | --- | --- |
| Workspace/platforms | Flutter app в корне; удалены web/desktop/iOS hosts; новый Android namespace | 4bd22db, da72ed0, 9fb1e84 |
| Toolchain | FVM 3.47.2, Dart 3.13, общая analyzer policy, workspace/lockfile, обновление runtime packages | a3d793f, 50f62d3, 3594f0a, 21f8c8a |
| Android | Kotlin host/DSL, AGP 9.3.2 / Gradle 9.7.1, shrinking/proguard для build types; пока debug signing | 7382e34, 50f62d3, 5cbfc76 |
| DI | registerDependencies, DepsContainer/DepsScope, bootstrap и shared clients | 87f321d |
| Network | http REST с именованными методами, payload accessors, options/cancellation/interceptors, API headers/version и один retry после 401 | 4a4f4f5, d97974b, ac6b2a9, c36d2a7 |
| Auth/session | Secure token store, restore, envied, browser OAuth/App Links, callback state, recovery/progress, single-flight refresh, local logout | 2c90ae3, 7690edc, 2cfac5a, dfd051f, 5365ea2, 7a4e959, 9927efc, 0b5be15, de1b8df, 38b0310 |
| Guest entry | Убрана обязательная legacy login page, guest стал root | 8004826, d369b07 |
| l10n | ARB/gen-l10n en/ru, context.t, locale controller/store, language selector | c4563a4, 3cb15d9 |
| Profile foundation | Get User/Get Own Data, DTO/domain mapping, typed lookup, базовый Bloc и UI | 5a10230, dd2557e, 92b238c, d25cf23, 46dd6fe, 14922aa, 6f674cc, 5431e9a |

Профильная основа выше заменена цельным [P09 explorer](work/P09-profile-explorer.md)
в `2c3c566`:
гостевой API, локальный repository, latest-wins, refresh/error states, поиск
на корневом экране. Ручное принятие этого среза отдельно от наличия foundation.

Старые карточки P00/P02/P03/P05.1 сохраняются как история решений и проверок.
Не следовать их устаревшим «следующим шагам», если ROADMAP уже указывает иной scope.
