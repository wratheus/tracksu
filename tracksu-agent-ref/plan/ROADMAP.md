# Очередь переработки Tracksu

2026-09-06 · единственная активная очередь. Сверена с кодом и историей Git.

## Сейчас

**P07 — UI foundation** разрешён пользователем 2026-09-07: Stitch — ориентир,
допускается осмысленная визуальная корректировка. Сначала пакет/темы/компоненты
и [ручной каталог](work/P07-ui-foundation.md), затем перенос страниц.
Страницы и навигацию не менять автоматически вместе с foundation.

**P07.1 — локализация, без изменения дизайна**:
[семь языков и стандартный ARB](work/P07.1-languages.md) реализованы,
ожидают ручной проверки. [P16](work/P16-legacy-cleanup.md) удалил старый граф
экранов и перенёс авторизацию в auth; pages больше нет. По решению пользователя
аудит legacy-assets делаем совместно с дизайном после Stitch, не сейчас.
P09–P13 и OAuth ждут ручной приёмки. UI foundation — отдельный активный срез.

Уже реализованная основа вынесена в [IMPLEMENTED](IMPLEMENTED.md).
Архив означает наличие кода, а не автоматически подтверждённое поведение.
[DETAILS](DETAILS.md) хранит исходный scope и аудит; его исторические baseline
не являются описанием сегодняшнего приложения.

## Активные задачи — только оставшаяся работа

| Порядок / ID | Следующий цельный результат | Статус |
| --- | --- | --- |
| Сейчас · [P07.1](work/P07.1-languages.md) | en/ru/de/fr/es/ja/zh, стандартный ARB template, language persistence и fallback подключены; ручная языковая проверка | awaiting_manual_check |
| Сейчас · [P07 foundation](work/P07-ui-foundation.md) | Темы, базовые компоненты и предметный каталог: media/аватары, flags/grades/mods, карточки игрока/карты/результата/новости, метрики, line/bar charts, content states. Код реализован; ручная оценка каталога перед переносом страниц | awaiting_manual_check |
| 1 · [P09](work/P09-profile-explorer.md) | Ручная проверка гостевого поиска, четырёх ruleset, ошибок/refresh и optional /me; исправления по результату | awaiting_manual_check |
| 2 · P10 · [scores](work/P10-scores.md) / [карты](work/P10-beatmaps.md) | Best/recent и восемь категорий карт подключены: scoped Bloc, lazy slivers, refresh/load-more/retry. Ручная проверка; старые неиспользуемые consumers удалены в P16. legacy: false для scores | awaiting_manual_check |
| 3 · [P12](work/P12-beatmap.md) | Подключены typed navigation из профиля, набор/выбор сложности, публичный top leaderboard, новые Score/mod acronyms и back. Ручная проверка; расширенные фильтры отдельно | awaiting_manual_check |
| 4 · [P11](work/P11-rankings.md) | PP/score × четыре режима, paging, страны/mania variants, spotlights с картами и переходами подключены. Ручная проверка; старый граф удалён в P16 | awaiting_manual_check |
| 5 · [P13](work/P13-news.md) | Новости: список с cursor paging, текстовый HTML reader, HTTPS-ссылки, refresh/retry и вход из shell подключены. Ручная проверка | awaiting_manual_check |
| 5a · [P07.2 — навигация](../reference/NAVIGATION_SPEC.md) | Bottom bar, независимые стеки вкладок, сохранение состояния, iOS interactive pop / Android predictive Back, OAuth и restoration. Сначала согласовать ADR и Back-at-root; функциональный shell можно сделать до финальной темы | backlog |
| 6 · [P01.2](DETAILS.md#p01-2) | Аудит assets: происхождение/права, вес, usage, дубли/форматы — совместно с дизайном после Stitch, по решению пользователя | deferred_until_design |
| 7 · [P07 — визуальная приёмка](work/P07-ui-foundation.md) | Оценить уже реализованные предметные карточки/графики в каталоге, состояния и assets. Уточнить палитру/шрифты/иконки перед переносом страниц; корректировки относительно Stitch разрешены | backlog |
| 8 · [P07 + P07.1 — интеграция](DETAILS.md#p07) | После оценки foundation: перенос страниц на tracksu_ui, theme preference/persistence, вынос l10n в пакет. Не смешивать с API-расширениями | backlog |
| 9 · [P06.1](DETAILS.md#p06-1) | Firebase analytics: typed facade, базовые действия и UI binding, privacy/consent; выбрать Firebase environment | backlog |
| 10 · [P14](DETAILS.md#features) | Audio preview после проверки прав: один player и lifecycle/audio focus либо явно отложить | backlog |
| [P16](work/P16-legacy-cleanup.md) | Мёртвый граф и старые прямые зависимости удалены; авторизация перенесена в auth, pages удалена. Ручной OAuth smoke; palette/assets вместе с будущим дизайном | awaiting_manual_check |
| До выпуска · [P08](DETAILS.md#p08) | Полный ручной auth/session flow, решение об очистке/миграции старого storage, восстановление после ошибок; новый guest token не пользовательская сессия | backlog |
| До выпуска · [P02 + P06](DETAILS.md#p02) | Scripts/CI format-analyze-build без тестов; analyze всего lib/packages чистый после P16. Проверить оставшиеся plugins; общий error reporting/lifetime по фактическим consumers | backlog |
| До выпуска · [P02.1](DETAILS.md#p02-1) | Поддерживать README/CHANGELOG при каждом срезе; дополнить команды CI, package contracts и release-инструкцию по мере реализации | ongoing |
| До выпуска · [P00 + P01.1 + P03](DETAILS.md#p00) | Новые store accounts и публичный branding, новый release keystore/backup, production signing/App Links fingerprints, release/profile build и device checks | backlog |
| До выпуска · [P01](DETAILS.md#p01) | Актуализировать архитектурные ADR и карту функций; права osu!, атрибуция, privacy/market requirements | backlog |
| [P15](DETAILS.md#p15) | Ручная регрессия и release readiness; отдельное разрешение на публикацию. Старый update-path не обещаем: ID новый, прежних ключей нет | backlog |
| [P04](DETAILS.md#p04) | Новый iOS host/SPM, signing/capabilities, simulator/device/archive — после Android | deferred |
| [P17](DETAILS.md#p17) | BFF с callback/token exchange, убрать secret из binary, выбрать domain/hosting/stack после client MVP | deferred |
| [T01](DETAILS.md#t01) | Автотесты — только по отдельному решению; не пишем и не запускаем параллельно | deferred |

Следом — ручная проверка локализации и P09/P10/P11/P12/P13/OAuth; исправления
по результату. До готовности дизайна доступен технический P02/P06: scripts/CI
format-analyze-build без тестов. P16/P01.2 assets не начинаем отдельно от дизайна.
Приоритет — восстановление
функциональности, а не редизайн. Удаление недостижимого legacy не означает,
что все его исторические возможности реализованы: расширенная статистика,
about/medals/audio и прочие отсутствующие сценарии остаются отдельными решениями.

Старые user_page/user_tab_page, beatmap_page, rankings_page/rankings_tab_page,
last_news_page, Home/desktop/drawer/error и зависимые модели/Cubit удалены
как недостижимый из main.dart граф. Новый shell открывает profile, beatmap,
rankings/spotlights, news и AuthMain. authorization_page удалена, OAuth теперь
изолирован в auth. Активная палитра сохраняется без изменений.
Подробности и восстановление — в P16/Git.

До переноса страниц используем на них текущее временное оформление,
новую палитру сначала проверяем в каталоге P07. Локализация новых экранов работает
через существующие ARB/context.t и не ждёт редизайна. Аудит assets → визуальный
план/примеры → согласование пользователя → реализация тем и UI kit.

## Уже принятые решения — не спрашивать повторно

- Flutter 3.47.2 / Dart 3.13; Pub workspace в корне; JDK 25, Android по TSD.
- Android ID/namespace: `io.github.wratheus.tracksu`. iOS/web/desktop hosts удалены.
- REST поверх `http`, именованные методы, interceptors, cancellation, один retry.
- DTO parsing в repository, raw payload в source, общие JSON readers.
- Main → local source/repository/Bloc, shared infrastructure в DepsContainer.
- Guest-first, OAuth — дополнительное действие; текущий HTTPS callback на Pages.
- en/ru/de/fr/es/ja/zh, системный язык и сохранённый выбор; ARB/context.t для UI.
  Формат ARB — [Flutter policy](../standards/LOCALIZATION.md), не примеры TSD.
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
