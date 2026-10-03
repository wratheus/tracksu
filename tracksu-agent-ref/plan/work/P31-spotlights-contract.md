# P31 — Spotlights: контракт osu-web и вход со стартового экрана

2026-10-03 · implemented in code / awaiting_manual_check.

## Цель и границы

Убрать временную обработку «перевёрнутого периода» и привести Spotlights
к фактическому контракту osu-web. Перенести вход в Spotlights из Рейтингов
на стартовый экран. Scope: `lib/src/spotlights`, SearchHome, RankingsSection,
ARB, документация. Seasons, новые API-срезы и Android не входят.

## Что такое Spotlights в osu-web (проверено по исходникам 2026-10-03)

- Модель `App\Models\Spotlight` (`chart_id`, `acronym`, `name`, `type`,
  `mode_specific`, `start_date`, `end_date`, `chart_month`, `active`). Это
  чарт ranked score по подобранному набору beatmapsets: отдельные таблицы
  `{acronym}_user_stats[_{mode}]` и `{acronym}_beatmapsets[_{mode}]`,
  в ответе — top 40 (`SPOTLIGHT_MAX_RESULTS`).
- `type`: `monthly`, `bestof` (периодические, `PERIODIC_TYPES`), а также
  `special` и `theme`. На сайте раздел сейчас называется «Spotlights (old)»;
  текущие соревнования — Seasons, отдельная система.
- `start_date`/`end_date` — справочные даты, которые вносит staff. osu-web их
  не валидирует и нигде не использует в логике; страница чарта показывает
  «Start Date» и «End Date» как есть. Пример: чарт 68 «Best of 2012» —
  start 2013-02-01, end 2013-01-31 (live API и сайт).
- `GET /api/v2/spotlights` (`SpotlightsController@index`) — каталог
  по `chart_id` desc, без `participant_count`.
- `GET /api/v2/rankings/{mode}/charts?spotlight={id}` — если для ruleset нет
  таблицы (`hasMode` false), API отвечает **404** «ruleset … isn't available
  for the specified spotlight». Многие старые чарты есть не для всех режимов.

Источники: `app/Models/Spotlight.php`, `app/Transformers/SpotlightTransformer.php`,
`app/Http/Controllers/SpotlightsController.php`,
`app/Http/Controllers/RankingController.php` в ppy/osu-web.

## Решение

1. **Даты.** Прежний DTO требовал `end >= start` и отбрасывал весь каталог;
   затем это заменили специальной заглушкой (обнуление дат). Обе версии
   навязывали API контракт, которого у него нет. Теперь `Spotlight.startDate`
   и `endDate` — независимые факты: порядок не проверяется, даты не
   обнуляются; UI показывает «Дата начала» и «Дата окончания» отдельными
   строками, как osu-web, без диапазона/длительности. Некорректная строка
   даты по-прежнему → `invalidResponse` (это действительно сломанный контракт).
2. **Тип.** `SpotlightKind` (monthly/bestOf/special/theme/other) из `type`,
   бейдж в карточке и подзаголовок в выборе. Неизвестное значение — `other`
   без подписи, а не ошибка (forward-compatible enum). Поиск в каталоге —
   по названию/ID: годы есть в названиях, а даты могут относиться к
   следующему году («Best of 2012» начинается в 2013).
3. **Ruleset 404.** Для выбранного из каталога чарта 404 деталей означает
   отсутствие чарта для режима. Bloc отдаёт `rulesetUnavailable` → пустое
   состояние «Для этого режима рейтинга нет» с подсказкой выбрать другой
   режим; без `addError`, без Retry. 404 каталога остаётся ошибкой.
4. **Расположение.** Spotlights — архив, а не живой рейтинг и не лента
   новостей, поэтому вход перенесён на стартовый экран (карточка под
   поиском профиля). Кнопка в Рейтингах удалена. Код фичи перенесён из
   `lib/src/rankings/spotlights` в `lib/src/spotlights`; общий тип ошибок
   `RankingsFailure` и remote exception пока переиспользуются. Route
   `…/spotlights` не менялся. Навигация из SearchHome использует тот же
   guard `_opening`/`_navigation`, что и открытие профиля (сброс при
   возврате на root через reselect).

## Тесты (ключевые регрессии)

- `test/src/spotlights/data/repository_test.dart`: реальные даты чарта 68
  сохраняются как есть, `type` разбирается, неизвестный тип → `other`,
  некорректная дата → `invalidResponse`; прежние проверки деталей.
- `test/src/spotlights/bloc/bloc_test.dart`: osu загружен → taiko 404 →
  `rulesetUnavailable` без failure → возврат на osu загружает детали.

## Проверка пользователем

- Поиск → карточка Spotlights → последняя подборка, бейдж типа, две даты.
- Выбрать «Best of 2012» (68): каталог загружен, даты как на сайте.
- Переключить режим на чарте, где его нет: пустое состояние, не ошибка;
  вернуть osu — данные появляются.
- Рейтинги: кнопки Spotlights больше нет.
- Retap вкладки Поиск со Spotlights → root, кнопки активны.

Исполнитель не запускал format/analyze/tests (по поручению проверку
выполняет пользователь); `gen-l10n` выполняется при сборке.

## Возврат

Адресный revert файлов фичи/ARB; данных, кэша и auth изменение не касается
(ключ `spotlights-catalog` в PageCache живёт только в памяти).
