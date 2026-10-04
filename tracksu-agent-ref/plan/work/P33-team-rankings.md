# P33 — рейтинг команд во вкладке «Рейтинги»

2026-10-04 · implemented in code / awaiting_manual_check.

## Контракт (osu-web, не официальная документация)

`GET /api/v2/rankings/{mode}/team?sort=performance|score&cursor[page]=N`
(`RankingController`, тип `team`): `TeamStatistics` с `ranked_score > 0`,
сортировка по `performance` или `ranked_score`, 50 строк на страницу,
максимум 10 000, `cursor.page` и `total` как у рейтинга игроков. Строка —
`TeamStatisticsTransformer` с includes `team` (`id`, `name`, `short_name`,
`flag_url`) и `member_count`: `team_id`, `ruleset_id`, `play_count`,
`ranked_score`, `performance`. Фильтры `country` и `variant` к командам
не применяются. В официальной документации тип `team` не описан
(RankingType: charts/country/performance/score) — **недокументированный
контракт**: парсер строгий, при изменении формы — понятная ошибка, не
пустой успех. Живой ответ исполнитель не проверял (нет токена в сессии) —
первая проверка на устройстве.

## Что сделано

- `lib/src/rankings/teams/`: домен (`TeamRankingEntry`, `TeamRankingsQuery`),
  источник, репозиторий (те же проверки страниц, что у игроков, + совпадение
  `team_id` с `team.id`), `TeamRankingsBloc` (latest-wins, кэш первой
  страницы на запрос, подгрузка без дублей), секция и карточка.
- «Рейтинги»: сверху переключатель «Игроки / Команды» (тот же сегментный
  контрол). Режим и сортировка (PP / очки) общие; страна и вариант mania —
  только у игроков. Pull-to-refresh и линия под app bar для обеих таблиц.
- Карточка команды на той же сетке: флаг 2:1 вместо аватара, место,
  название и значение с единицей сверху; тег команды и число участников
  снизу; тап — страница команды.
- Public allowlist: `rankings/{mode}/team`.
- Тест: `test/src/rankings/teams/repository_test.dart` (позиции, поля,
  отказ при отсутствии команды/несовпадении id).

## Проверить

- Переключение Игроки ↔ Команды, смена режима и сортировки в «Командах»,
  подгрузка следующих страниц, pull-to-refresh, переход в команду.
