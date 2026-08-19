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
  DTO не должны смешивать поля разных версий. Auth header появится только в
  P08 у session owner, а не через screen или feature.
- Для scores текущая product policy: `legacy_only=false`. Значение передаётся
  через один будущий query contract score feature; UI переключателя пока нет.
- `Accept-Language` не фиксируем до P07.1: источник locale должен быть один,
  а не случайный заголовок каждого endpoint.

## Inventory legacy запросов

| Legacy consumer | Актуальный путь и решение миграции |
| --- | --- |
| `getUser` | `GET /users/{user}/{mode}` остаётся. `key=username` устарел: новый `ProfileUserReference` разделяет положительный ID и нормализованное имя к `@username`; source кодирует route segment. UI/Bloc ещё не подключены. |
| `getUserMe` | `GET /me/{mode}` остаётся. Первый переносимый consumer: `profile` source → DTO → mapper → repository. |
| `getUserScore` | `GET /users/{user}/scores/{type}`. Явно передавать `legacy_only=false`, `include_fails`, ruleset/mode, limit, offset; `Score` DTO создавать только после sample response выбранной response version. |
| `getNews` | `GET /news`; `limit` ограничен 1–21, cursor pagination через `cursor_string`. Не индексировать ответ до фиксированной длины. |
| `getBeatmap` | `GET /beatmaps/{beatmap}` остаётся; response — extended beatmap, optional nested data проверяется decoder. |
| `getBeatmapScores` | `GET /beatmaps/{beatmap}/scores`; текущий путь актуален. Передавать `legacy_only=false`, ruleset/mode и mods явно; старый код не отправляет `mods` и содержит ошибку записи по индексу. |
| `getRankings` | `GET /rankings/{mode}/{type}`. Перед переносом снять actual contract pagination/filter/country и не переносить `length - 1`. |
| `getUserBeatmaps` | `GET /users/{user}/beatmapsets/{type}`. Нужны explicit limit/offset и ограниченный параллелизм при обогащении mapper. |
| commented changelog | Не переносить без реального consumer. |

## Последовательность

1. Снять обезличенный successful/empty/401/429 response первого endpoint.
2. Создать immutable DTO в `feature/data/dto`, строго проверить required/optional
   поля и map в domain model внутри repository.
3. После ручной проверки удалить только соответствующий legacy вызов. Остальные
   endpoints не меняются этим commit.
