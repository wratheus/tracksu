# Очередь переработки Tracksu

2026-09-05 · единственная активная очередь. Сверена с кодом и историей Git.

## Сейчас

**P12 — карта и leaderboard**: подключены переходы и выбор сложности.
[Карточка и ручные сценарии](work/P12-beatmap.md). Следующая реализация — P11.

Уже реализованная основа вынесена в [IMPLEMENTED](IMPLEMENTED.md).
Архив означает наличие кода, а не автоматически подтверждённое поведение.
[DETAILS](DETAILS.md) хранит исходный scope и аудит; его исторические baseline
не являются описанием сегодняшнего приложения.

## Активные задачи — только оставшаяся работа

| Порядок / ID | Следующий цельный результат | Статус |
| --- | --- | --- |
| 1 · [P09](work/P09-profile-explorer.md) | Ручная проверка гостевого поиска, четырёх ruleset, ошибок/refresh и optional /me; исправления по результату | awaiting_manual_check |
| 2 · P10 · [scores](work/P10-scores.md) / [карты](work/P10-beatmaps.md) | Best/recent и восемь категорий карт подключены: scoped Bloc, lazy slivers, refresh/load-more/retry. Ручная проверка; cleanup зависимых legacy consumers после P12. legacy: false для scores | awaiting_manual_check |
| 3 · [P12](work/P12-beatmap.md) | Подключены typed navigation из профиля, набор/выбор сложности, публичный top leaderboard, новые Score/mod acronyms и back. Ручная проверка; расширенные фильтры отдельно | awaiting_manual_check |
| 4 · [P11](DETAILS.md#features) | Рейтинги: фильтры/страницы без гонок, потерь строк и сброса scroll position; доступ из mobile shell | backlog |
| 5 · [P13](DETAILS.md#features) | Новости: список, безопасный HTML и ссылки, ошибки/пагинация; доступ из mobile shell | backlog |
| 6 · [P01.2](DETAILS.md#p01-2) | Аудит assets: происхождение/права, вес, usage, дубли/форматы; основа согласования визуального направления | backlog |
| 7 · [P07 — планирование](DETAILS.md#p07) | Согласовать с пользователем аккуратный osu!-стиль, пригодные assets, палитру/шрифты/иконки, состояния и примеры ключевых экранов. Не реализовывать темы до согласования | backlog |
| 8 · [P07 + P07.1 — реализация](DETAILS.md#p07) | После согласования: tracksu_ui, единые light/dark/ThemeMode, AppBar/кнопки, вынос l10n в пакет. Не блокирует функциональный перенос страниц | backlog |
| 9 · [P06.1](DETAILS.md#p06-1) | Firebase analytics: typed facade, базовые действия и UI binding, privacy/consent; выбрать Firebase environment | backlog |
| 10 · [P14](DETAILS.md#features) | Audio preview после проверки прав: один player и lifecycle/audio focus либо явно отложить | backlog |
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

Следующая большая задача — **рейтинги (P11)**, параллельно
пользователь проверяет P09/P10/P12. Приоритет — восстановление
функциональности, а не редизайн. P09 заменяет только поиск/шапку/статистику,
не весь legacy user_page и его вложенные сценарии.

Переносим пользовательские сценарии, не файлы один к одному: user_page/
user_tab_page → profile и его секции; beatmap_page → beatmap; rankings_page/
rankings_tab_page → rankings; last_news_page → news. HomePage/mobile navigation
восстанавливаем по мере подключения разделов без curved_navigation_bar.
authorization_page ещё требует переноса из legacy presentation; error_page —
замены локальными typed error states. Desktop-ветки не переносим: удаляем после
проверки imports/consumers вместе с соответствующим срезом P16.

До P07 используем текущее временное оформление и изолированные widgets,
не вводим новую палитру/брендинг. Локализация новых экранов продолжает работать
через существующие ARB/context.t и не ждёт редизайна. Аудит assets → визуальный
план/примеры → согласование пользователя → реализация тем и UI kit.

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
