# Очередь переработки Tracksu

2026-09-08 · единственная активная очередь. Сверена с кодом и историей Git.

## Сейчас

**P07 — поэкранная доработка**, [активный контракт](work/P07-product-integration.md).
UI kit и raw migration dfe33f2 реализованы, но не являются готовностью страниц.
Приоритет: shell/главная → поиск/профиль → scores/карты → рейтинги → новости →
настройки. Для каждого среза доводим сценарий и данные, а не только виджеты.
Stitch остаётся ориентиром. Пользователь согласовал go_router/StatefulShellRoute,
три вкладки и Android Back из корня вторичной вкладки к сохранённому Поиску.
Shell/отдельный Search, OAuth overlay и [продуктовый обзор профиля](work/P09-profile-product.md)
реализованы. Текущий срез — [карточки и графики P10/P12](work/P10-cards-and-charts.md):
результаты с подробностями, metadata карт и профильные графики.
Partial-name/map search остаются отдельным scope после проверки API, не обещанной функцией.

[Обратная связь P09](work/P09-profile-feedback.md): общий selector/плотность и
цвета метрик, language flags, reselect-to-root и безопасное «О себе» реализованы,
ожидают ручной проверки. По уточнению user page нужен полноценный
[ContentFrame](work/P07-rich-content.md): форматирование, изображения и
раскрывающиеся блоки. Первый native reader подключён к профилю/новостям;
пользователь разрешил автоматические внешние HTTPS-картинки без тумблера,
с disclosure сейчас и полноценной страницей документов в P01.3 позже.
Ограничения совместимости и limits описаны в контракте; device-проверка ожидается.
Описание карт ещё требует API-проекции; остальные
срезы P10 и графики остаются в очереди.
[Долгосрочные идеи](work/PRODUCT-FUTURE.md) — друзья/чаты/push/сравнения и развитие
BFF с AI/PP what-if — deferred, не входят в текущую доработку клиента.

**P07.1 — локализация, без изменения дизайна**:
[семь языков и стандартный ARB](work/P07.1-languages.md) реализованы,
ожидают ручной проверки. [P16](work/P16-legacy-cleanup.md) удалил старый граф
экранов и перенёс авторизацию в auth; pages больше нет. По решению пользователя
выполнена [чистка подтверждённо лишних assets](work/P01.2-assets.md).
P09–P13 имеют рабочие API-срезы, но требуют продуктовой доработки.
[P01.3 privacy/условия](work/P01.3-privacy-and-terms.md) — отдельный этап до релиза/analytics.

Уже реализованная основа вынесена в [IMPLEMENTED](IMPLEMENTED.md).
Архив означает наличие кода, а не автоматически подтверждённое поведение.
[DETAILS](DETAILS.md) хранит исходный scope и аудит; его исторические baseline
не являются описанием сегодняшнего приложения.

## Активные задачи — только оставшаяся работа

| Порядок / ID | Следующий цельный результат | Статус |
| --- | --- | --- |
| Сейчас · [Поэкранная доработка](work/P07-product-integration.md) | Функциональный shell/главная, затем каждый экран по отдельным data/UX критериям; raw migration не является завершением | in_progress |
| До analytics/release · [P01.3](work/P01.3-privacy-and-terms.md) | Data inventory, privacy notice/policy, условия, About/атрибуции, ссылки из guest/OAuth/settings и store disclosures | backlog |
| Сейчас · [P07.1](work/P07.1-languages.md) | en/ru/de/fr/es/ja/zh, стандартный ARB template, language persistence и fallback подключены; ручная языковая проверка | awaiting_manual_check |
| Сейчас · [P07 foundation](work/P07-ui-foundation.md) | Темы, базовые компоненты и предметный каталог: media/аватары, flags/grades/mods, карточки игрока/карты/результата/новости, метрики, line/bar charts, content states. Код реализован; ручная оценка каталога перед переносом страниц | awaiting_manual_check |
| 1 · [P09 профиль](work/P09-profile-product.md) | Cover, уровень/грейды/метрики/история, Обзор/Результаты/Карты и сохранение данных при смене ruleset реализованы. Ручная проверка вместе с exact lookup и optional /me | awaiting_manual_check |
| 2 · P10 · [scores](work/P10-scores.md) / [карты](work/P10-beatmaps.md) | Best/recent и восемь категорий карт подключены: scoped Bloc, lazy slivers, refresh/load-more/retry. Ручная проверка; старые неиспользуемые consumers удалены в P16. legacy: false для scores | awaiting_manual_check |
| 3 · [P12](work/P12-beatmap.md) | Подключены typed navigation из профиля, набор/выбор сложности, публичный top leaderboard, новые Score/mod acronyms и back. Ручная проверка; расширенные фильтры отдельно | awaiting_manual_check |
| 4 · [P11](work/P11-rankings.md) | PP/score × четыре режима, paging, страны/mania variants, spotlights с картами и переходами подключены. Ручная проверка; старый граф удалён в P16 | awaiting_manual_check |
| 5 · [P13](work/P13-news.md) | Новости: список с cursor paging, текстовый HTML reader, HTTPS-ссылки, refresh/retry и вход из shell подключены. Ручная проверка | awaiting_manual_check |
| Проверить · [P07.2 — навигация](../reference/NAVIGATION_SPEC.md) | go_router/stateful branches, отдельный Search, панель на деталях, OAuth overlay и status stream реализованы. Ручной Back/keyboard/callback/restoration checklist | awaiting_manual_check |
| 6 · [P01.2](work/P01.2-assets.md) | 34 assets/Palette удалены в 9a70de5. Остались источники, лицензии и атрибуции flags/modes/fonts; native splash/branding отдельно | backlog |
| 7 · [P07 — визуальная приёмка](work/P07-ui-foundation.md) | Оценить уже реализованные предметные карточки/графики в каталоге, состояния и assets. Уточнить палитру/шрифты/иконки перед переносом страниц; корректировки относительно Stitch разрешены | backlog |
| 8 · [P07 + P07.1 — интеграция](work/P07-product-integration.md) | Raw migration выполнена; требуется поэкранная доработка вместе с нужными media/data projections. Theme persistence и вынос l10n в пакет отдельно | backlog |
| 9 · [P06.1](DETAILS.md#p06-1) | Firebase analytics: typed facade, базовые действия и UI binding, privacy/consent; выбрать Firebase environment | backlog |
| 10 · [P14](DETAILS.md#features) | Audio preview после проверки прав: один player и lifecycle/audio focus либо явно отложить | backlog |
| [P16](work/P16-legacy-cleanup.md) | Мёртвый граф/старые dependencies/pages/Palette удалены. Дальше cleanup по фактическим consumers в каждом срезе; ручной OAuth smoke | awaiting_manual_check |
| До выпуска · [P08](DETAILS.md#p08) | Полный ручной auth/session flow, решение об очистке/миграции старого storage, восстановление после ошибок; новый guest token не пользовательская сессия | backlog |
| До выпуска · [P02 + P06](DETAILS.md#p02) | Scripts/CI format-analyze-build без тестов; analyze всего lib/packages чистый после P16. Проверить оставшиеся plugins; общий error reporting/lifetime по фактическим consumers | backlog |
| До выпуска · [P02.1](DETAILS.md#p02-1) | Поддерживать README/CHANGELOG при каждом срезе; дополнить команды CI, package contracts и release-инструкцию по мере реализации | ongoing |
| До выпуска · [P00 + P01.1 + P03](DETAILS.md#p00) | Новые store accounts и публичный branding, новый release keystore/backup, production signing/App Links fingerprints, release/profile build и device checks | backlog |
| До выпуска · [P01](DETAILS.md#p01) | Актуализировать архитектурные ADR и карту функций; права osu!, атрибуция, privacy/market requirements | backlog |
| [P15](DETAILS.md#p15) | Ручная регрессия и release readiness; отдельное разрешение на публикацию. Старый update-path не обещаем: ID новый, прежних ключей нет | backlog |
| [P04](DETAILS.md#p04) | Новый iOS host/SPM, signing/capabilities, simulator/device/archive — после Android | deferred |
| [P17](DETAILS.md#p17) | BFF с callback/token exchange, убрать secret из binary, выбрать domain/hosting/stack после client MVP | deferred |
| [T01](DETAILS.md#t01) | Автотесты — только по отдельному решению; не пишем и не запускаем параллельно | deferred |

Следом — поэкранные срезы из активного контракта с ручной оценкой пользователя.
Cleanup выполняется для доказанно мёртвого кода/assets. Удаление legacy не означает,
что все его исторические возможности реализованы: расширенная статистика,
about/medals/audio и прочие отсутствующие сценарии остаются отдельными решениями.

Старые user_page/user_tab_page, beatmap_page, rankings_page/rankings_tab_page,
last_news_page, Home/desktop/drawer/error и зависимые модели/Cubit удалены
как недостижимый из main.dart граф. Новый shell открывает profile, beatmap,
rankings/spotlights, news и AuthMain. authorization_page удалена, OAuth теперь
изолирован в auth. После dfe33f2 активны TracksuTheme.light/dark и ThemeMode.system.
Подробности и восстановление — в P16/Git.

UI kit и каталог уже существуют. Следующие страницы доводим до завершённого
сценария на их основе, включая media/data и семь локализаций. Наличие компонента
в каталоге не означает наличие его данных в API-проекции.

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
