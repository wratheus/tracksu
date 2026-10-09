# P56 — мультиплеер: матчи (волна 3) — подготовка

2026-10-09 · запрос пользователя: «над матчами мультиплеер я бы поработал
красиво, это не ниша и интересно»; «следующим готовимся к мульти, пока не
делаем». Статус: **next — подготовка**, код не начат. Часть
[P49](P49-api-coverage.md) (волна 3).

## API (osu-web `LegacyMatchesController`, срез 04643de)

- `GET /matches?limit=&sort=&active=&cursor_string=` — scope public;
  `limit` ≤ 50, `sort` `id_desc` (по умолчанию) / `id_asc`, `active`
  (true — только идущие). Ответ: `matches[]` (`id`, `name`, `start_time`,
  `end_time` — null у идущего), `cursor_string`, `params`.
- `GET /matches/{id}?before=&after=&limit=` — `limit` ≤ 101, курсор по
  событиям. Ответ: `match`, `events[]`, `users[]` (с `country`),
  `first_event_id`, `latest_event_id`, `current_game_id`.
  - событие: `id`, `timestamp`, `user_id`, `detail.type`
    (`match-created`, `player-joined`, `player-left`, `player-kicked`,
    `host-changed`, `match-disbanded`, `other` — у последнего есть `game`).
  - `game`: `beatmap` (+`beatmapset`), `mode`, `scoring_type`
    (`score`/`accuracy`/`combo`/`scorev2`), `team_type`
    (`head-to-head`/`tag-coop`/`team-vs`/`tag-team-vs`), `mods`,
    `start_time`/`end_time`, `scores[]` с `match.slot`, `match.team`
    (`red`/`blue`/`none`), `match.pass`.
- Только чтение. Allowlist: `^/api/v2/matches(/[1-9][0-9]*)?$`.
- Перед реализацией: свежий срез osu-web, `x-api-version`, пример ответа
  в тест-фикстуру, проверить поведение `active` и пустых `game.scores`.

## Дизайн (предложение, ждёт подтверждения размещения)

- **Вход:** блок на Главной «Мультиплеер · N матчей идут сейчас» (один
  запрос `matches?active=true&limit=50` при открытии Главной, кэш сессии);
  плюс AppLinks `/community/matches/{id}` и `/mp/{id}`.
- **Список матчей:** сегменты «Идут сейчас / Завершённые», строка: название
  (часто `OWC: (TeamA) vs (TeamB)` — разобрать на две стороны), время,
  живая точка у идущих. Подгрузка курсором по кнопке/в конце, без циклов.
- **Матч:** шапка (название, статус, счёт команд red/blue при team-vs),
  дальше карточки игр: обложка карты, моды, тип счёта, таблица игроков с
  полосой цвета команды, победитель сверху; тихие строки событий
  (зашёл/вышел/хост). Бар красный/синий — доля очков игры.
- **Live:** пока матч идёт и экран виден — `after=latest_event_id` раз в
  ~10 с; пауза в фоне/при уходе со страницы; без запроса на каждого игрока
  (пользователи приходят в `users[]`).

## Бережём сервер

Нет автоподгрузки истории в цикле; опрос только видимого идущего матча;
один запрос списка на открытие; кэш PageCache. Ошибки 429 — пауза опроса.

## Открытые вопросы к пользователю

1. Блок на Главной — да/нет, или вход из вкладки «Рейтинги»/«osu!».
2. Разбирать ли названия турниров (`ACRONYM: (A) vs (B)`) в две стороны.
3. Показывать ли комнаты lazer (`rooms`, плейлисты) рядом с legacy-матчами
   или только `matches`.
