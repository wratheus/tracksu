# Реализованная основа — архив активных шагов

Сверка 2026-09-05. Здесь факты кода/истории, не второй backlog и не заявление
о полной ручной проверке. Остатки каждого этапа находятся в ROADMAP.

| Область | Что уже не требуется начинать заново | Опорные коммиты |
| --- | --- | --- |
| Workspace/platforms | Flutter app в корне; удалены web/desktop/iOS hosts; новый Android namespace | ecf93d6, 580edf5, c158d82 |
| Toolchain | FVM 3.47.2, Dart 3.13, общая analyzer policy, workspace/lockfile, обновление runtime packages | 2d5826d, e50a124, 4dc5a2b, 17fb66b |
| Android | Kotlin host/DSL, AGP 9.3.2 / Gradle 9.7.1, shrinking/proguard для build types; пока debug signing | 2777953, e50a124, 1331398 |
| DI | registerDependencies, DepsContainer/DepsScope, bootstrap и shared clients | c60bdf4 |
| Network | http REST с именованными методами, payload accessors, options/cancellation/interceptors, API headers/version и один retry после 401 | 5d68dc8, a0bef16, e9dec2a, d09afbb |
| Auth/session | Secure token store, restore, envied, browser OAuth/App Links, callback state, recovery/progress, single-flight refresh, local logout | b07e24f, d6e653e, beb13f7, 278437e, 5a546d2, 2c6767f, 9bf5f0d, 174de2d, 0b6f907, 2f76fb5 |
| Guest entry | Убрана обязательная legacy login page, guest стал root | a077c70, 5377323 |
| l10n | ARB/gen-l10n en/ru, context.t, locale controller/store, language selector | 27e8c1c, 58f05c7 |
| Profile foundation | Get User/Get Own Data, DTO/domain mapping, typed lookup, базовый Bloc и UI | 6041b88, 46cee50, 1bad8bb, 0bebe81, 7a25db4, c663a0a, 8a53dfe, c3d9a79 |

Профильная основа выше заменена цельным [P09 explorer](work/P09-profile-explorer.md)
в `6dabda6`:
гостевой API, локальный repository, latest-wins, refresh/error states, поиск
на корневом экране. Ручное принятие этого среза отдельно от наличия foundation.

Старые карточки P00/P02/P03/P05.1 сохраняются как история решений и проверок.
Не следовать их устаревшим «следующим шагам», если ROADMAP уже указывает иной scope.
