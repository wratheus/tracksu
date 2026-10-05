# P40 — рейтинг стран во вкладке «Рейтинги»

2026-10-05 · implemented in code / awaiting_manual_check.

## Зачем

Третья внутренняя вкладка из плана P33 («Игроки / Команды / Страны»).

## Контракт (официальная документация + osu-web)

`GET /api/v2/rankings/{mode}/country?cursor[page]=N` — тип `country`
документирован (RankingType, CountryStatistics). `RankingController`:
`CountryStatistics::where('display', 1)->where('mode', …)
->orderByDesc('performance')`, 50 строк, `cursor.page`, `total`.
Строка — `CountryStatisticsTransformer`: `code`, `active_users`,
`play_count`, `ranked_score`, `performance` (+ include `country`).
Сортировки нет (только PP), фильтры страны/варианта mania не применяются.

## Решение

- `lib/src/rankings/country_stats/`: домен, источник, репозиторий
  (строгий разбор как у команд: курсор, total, размер страницы, код из
  двух букв, без дублей), `CountryRankingsBloc` (latest-wins, кэш первой
  страницы на режим), карточка и секция.
- Вкладка «Страны»: общий выбор режима (PP/очки, страна и 4K/7K скрыты —
  `RankingsFilterScope.countries`). Строка: флаг (локальный ассет), место,
  локализованное название (CLDR из `countries.json`), PP; снизу — число
  активных игроков. Тап по стране открывает «Игроки» с фильтром этой страны.
- Pull-to-refresh и линия под app bar для всех трёх таблиц.
- Allowlist: `rankings/{mode}/country`.
- Тест: `test/src/rankings/country_stats/repository_test.dart`.

## Проверить

- Вкладка «Страны» во всех режимах, подгрузка (≈ 240 стран — 5 страниц).
- Тап по стране → «Игроки», выбрана эта страна.
- Названия на языке приложения.
