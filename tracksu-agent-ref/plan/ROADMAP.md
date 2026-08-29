# Очередь переработки Tracksu

2026-09-05 · единственная активная очередь. Сверена с кодом и историей Git.

## Сейчас

**P09 — гостевой поиск и профиль**: цельный вертикальный срез, а не серия задач
на отдельные методы. [Карточка, проверки и ручные сценарии](work/P09-profile-explorer.md).

Уже реализованная основа вынесена в [IMPLEMENTED](IMPLEMENTED.md).
Архив означает наличие кода, а не автоматически подтверждённое поведение.
[DETAILS](DETAILS.md) хранит исходный scope и аудит; его исторические baseline
не являются описанием сегодняшнего приложения.

## Активные задачи — только оставшаяся работа

| Порядок / ID | Следующий цельный результат | Статус |
| --- | --- | --- |
| 1 · [P09](work/P09-profile-explorer.md) | Ручная проверка гостевого поиска, четырёх ruleset, ошибок/refresh и optional /me; исправления по результату | awaiting_manual_check |
| 2 · [P07 + P07.1](DETAILS.md#p07) | Единый tracksu_ui, темы light/dark/ThemeMode, читаемые AppBar и кнопки, phone-only shell; вынос l10n в пакет, перевод auth; без responsive desktop | backlog |
| 3 · [P10](DETAILS.md#features) | Scores и карты профиля: актуальные DTO, независимые состояния, lazy slivers, пагинация, пустые/ошибочные ответы, один флаг legacy: false с возможностью переключения | backlog |
| 4 · [P11](DETAILS.md#features) | Рейтинги: фильтры/страницы без гонок, потерь строк и сброса scroll position | backlog |
| 5 · [P12](DETAILS.md#features) | Beatmap/leaderboard: typed navigation, новые score/mods, возврат назад | backlog |
| 6 · [P13](DETAILS.md#features) | Новости: список, безопасный HTML и ссылки, ошибки/пагинация | backlog |
| 7 · [P06.1](DETAILS.md#p06-1) | Firebase analytics: typed facade, базовые действия и UI binding, privacy/consent; выбрать Firebase environment | backlog |
| 8 · [P01.2](DETAILS.md#p01-2) | Аудит assets: происхождение/права, вес, usage, дубли/форматы; заменить или удалить лишнее | backlog |
| 9 · [P14](DETAILS.md#features) | Audio preview после проверки прав: один player и lifecycle/audio focus либо явно отложить | backlog |
| По срезам · [P16](DETAILS.md#p16) | Удалять заменённый legacy по usages, routes и assets; убрать curved_navigation_bar/fluttericon после последних consumers. История Git вместо вечных bridges | backlog |
| До выпуска · [P08](DETAILS.md#p08) | Полный ручной auth/session flow, решение об очистке/миграции старого storage, восстановление после ошибок; новый guest token не пользовательская сессия | backlog |
| До выпуска · [P02 + P06](DETAILS.md#p02) | Scripts/CI format-analyze-build без тестов; устранить legacy analyzer debt, проверить оставшиеся plugins; общий error reporting/lifetime по фактическим consumers | backlog |
| До выпуска · [P02.1](DETAILS.md#p02-1) | Поддерживать README/CHANGELOG при каждом срезе; дополнить команды CI, package contracts и release-инструкцию по мере реализации | ongoing |
| До выпуска · [P00 + P01.1 + P03](DETAILS.md#p00) | Новые store accounts и публичный branding, новый release keystore/backup, production signing/App Links fingerprints, release/profile build и device checks | backlog |
| До выпуска · [P01](DETAILS.md#p01) | Актуализировать архитектурные ADR и карту функций; права osu!, атрибуция, privacy/market requirements | backlog |
| [P15](DETAILS.md#p15) | Ручная регрессия и release readiness; отдельное разрешение на публикацию. Старый update-path не обещаем: ID новый, прежних ключей нет | backlog |
| [P04](DETAILS.md#p04) | Новый iOS host/SPM, signing/capabilities, simulator/device/archive — после Android | deferred |
| [P17](DETAILS.md#p17) | BFF с callback/token exchange, убрать secret из binary, выбрать domain/hosting/stack после client MVP | deferred |
| [T01](DETAILS.md#t01) | Автотесты — только по отдельному решению; не пишем и не запускаем параллельно | deferred |

Следующая рекомендуемая большая задача после проверки P09 — **UI kit + единая
темизация + пакет локализации**, затем scores. Это инфраструктура для всех
следующих экранов; не нужно заново дробить её на «добавить одну кнопку».

## Уже принятые решения — не спрашивать повторно

- Flutter 3.47.2 / Dart 3.13; Pub workspace в корне; JDK 25, Android по TSD.
- Android ID/namespace: `io.github.wratheus.tracksu`. iOS/web/desktop hosts удалены.
- REST поверх `http`, именованные методы, interceptors, cancellation, один retry.
- DTO parsing в repository, raw payload в source, общие JSON readers.
- Main → local source/repository/Bloc, shared infrastructure в DepsContainer.
- Guest-first, OAuth — дополнительное действие; текущий HTTPS callback на Pages.
- en/ru сейчас, системный язык и сохранённый выбор; ARB/context.t для нового UI.
- Client secret пока envied из ignored .env; обфускация не защита секрета; BFF позже.
- Устройство/UX проверяет пользователь. Автотесты отложены.

## Как работаем дальше

Одна задача — законченный сценарий или технический результат, несколько
содержательных коммитов при необходимости. Пользователь разрешил брать
существенные части самостоятельно внутри согласованного плана. Вопросы нужны
перед новой продуктовой/архитектурной развилкой, внешними настройками, данными
или публикацией, а не перед каждым методом.

Старт: карточка выбранного среза → [PLAYBOOK](../workflow/PLAYBOOK.md) →
[skills](../standards/SKILLS.md) → нужный [TSD reference](../reference/TSD.md)
или [API contract](../reference/OSU_API_V2.md). Не перечитывать весь архив.
На сдаче: фактические проверки, ручной checklist, обновлённая очередь.

Статусы: backlog → in_progress → awaiting_manual_check → verified.
ongoing — постоянное сопровождение; deferred — явно отложено.
Подтверждённый завершённый scope переносим в архив, сохраняя нерешённые части
в этой очереди. Секреты, их значения и защищённое содержимое в docs не попадают.
