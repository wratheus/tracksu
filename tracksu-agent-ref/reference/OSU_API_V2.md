# osu! API v2: актуальный контракт миграции

2026-09-04 · источник: актуальная [официальная документация osu! API v2](https://osu.ppy.sh/docs/).

Это рабочая карта для переноса legacy consumers. Она не заменяет проверку
реального anonymized response перед созданием DTO и не является клиентом для
всего публичного API.

## Общий контракт

- Base URI приложения: `https://osu.ppy.sh/api/v2`.
- OAuth routes `/oauth/authorize` и `/oauth/token` не являются API v2 routes и
  остаются отдельным auth/session concern.
- `OsuApiHeadersInterceptor` добавляет `Accept: application/json` и закрепляет
  `x-api-version: 20220705`. Это response version, где изменился `Score`;
  DTO не должны смешивать поля разных версий. Auth headers уже добавляются
  interceptors пользовательского/public клиентов, не screen или feature.
- Для scores текущая product policy: `legacy_only=0`. Значение передаётся
  через `ProfileScoresQuery.legacy` (default false); UI переключателя пока нет.
- `Accept-Language` не фиксируем до P07.1: источник locale должен быть один,
  а не случайный заголовок каждого endpoint.

## Profile P09 product projection — 2026-09-08

Сверено с [UserExtended](https://osu.ppy.sh/docs/index.html#userextended) и
[UserStatistics](https://osu.ppy.sh/docs/index.html#userstatistics): source
возвращает raw map прежнего endpoint, repository создаёт DTO/domain.
UI exact lookup уже подключён; упоминания неподключённого UI в foundation ниже — история.

- `cover.url` вместо deprecated `cover_url`; отсутствующий/невалидный HTTPS
  URL даёт media fallback, без нового запроса и без срыва всего профиля.
- `play_time` допускает null. `level.current/progress`, `grade_counts`
  (`ss/ssh/s/sh/a`), `ranked_score/total_score/total_hits/replays_watched_by_others`
  преобразуются в отдельную domain-проекцию; отсутствующие optional поля не
  подменяются нулями. Неверный тип присутствующего поля — invalidResponse.
- `rank_history.mode/data` содержит последовательность без временных меток
  отдельных точек. UI показывает порядковые наблюдения только текущего режима;
  null/0 — разрыв, не rank 0. Не приписываем календарные даты и не соединяем
  пропуски. Неизвестный режим пропускается, неверный тип данных отклоняется.

Это сверка опубликованного контракта, не подтверждение live ответов на устройстве.
Scoring policy, scopes и API version не менялись.

## Inventory legacy запросов

| Legacy consumer | Актуальный путь и решение миграции |
| --- | --- |
| `getUser` | `GET /users/{user}/{mode}` остаётся. `key=username` устарел: новый `ProfileUserReference` разделяет положительный ID и нормализованное имя к `@username`; source кодирует route segment. UI/Bloc ещё не подключены. |
| `getUserMe` | `GET /me/{mode}` остаётся. Первый переносимый consumer: `profile` source → DTO → mapper → repository. |
| `getUserScore` | `GET /users/{user}/scores/{type}`: best/recent уже подключены через новый scores repository/Bloc. legacy_only=0, explicit mode/limit/offset, include_fails только recent. DTO по документированному Score 20220705+, runtime-проверка пользователем ещё нужна. |
| `getNews` | `GET /news`; `limit` ограничен 1–21, cursor pagination через `cursor_string`. Не индексировать ответ до фиксированной длины. |
| `getBeatmap` | `GET /beatmaps/{beatmap}` остаётся; response — extended beatmap, optional nested data проверяется decoder. |
| `getBeatmapScores` | `GET /beatmaps/{beatmap}/scores`; текущий путь актуален. Передавать `legacy_only=false`, ruleset/mode и mods явно; старый код не отправляет `mods` и содержит ошибку записи по индексу. |
| `getRankings` | `GET /rankings/{mode}/{type}`. Перед переносом снять actual contract pagination/filter/country и не переносить `length - 1`. |
| `getUserBeatmaps` | Новый P10: `GET /users/{user}/beatmapsets/{type}`, explicit limit/offset, без N+1 обогащения. Source raw list → repository DTO → domain. |
| commented changelog | Не переносить без реального consumer. |

### P10: контракт списков карт

Сверено 2026-09-05 с [Get User Beatmaps](https://osu.ppy.sh/docs/index.html#get-user-beatmaps).
Для most_played используется BeatmapPlaycount: beatmap_id/count и nullable
beatmap/beatmapset. Остальные семь категорий возвращают BeatmapsetExtended.
Проекция хранит только ID, название/исполнителя, сложность и число игр,
если применимо. Отсутствующие metadata most_played отображаются через ID;
неверные типы обязательных полей — invalidResponse, не подставные данные.
Mode/legacy не передаются: endpoint их не документирует.
Пагинация offset/limit=20; полная страница допускает следующий запрос,
короткая завершает список. Offset считается до UI-дедупликации.
Это сверка документации, не запись live authenticated ответов.

## Последовательность

1. Снять обезличенный successful/empty/401/429 response первого endpoint.
2. Создать immutable DTO в `feature/data/dto`, строго проверить required/optional
   поля и map в domain model внутри repository.
3. После ручной проверки удалить только соответствующий legacy вызов. Остальные
   endpoints не меняются этим commit.

## Profile P09 foundation

`profile` теперь принимает публичный lookup как `ProfileUserReference`: ID
валидируется как положительное число, username normalizes to API-required
`@username`, а source кодирует route segment. `ProfileBloc` владеет только
feature state: отдельные `ProfileLookupRequested` и
`CurrentProfileLoadRequested`, затем loading/loaded/failure с исходным request
для будущего retry. Он не знает HTTP, DTO или Flutter UI. Успешный ручной
request пока не заявлен: UI и guest credentials не подключались этим шагом.
