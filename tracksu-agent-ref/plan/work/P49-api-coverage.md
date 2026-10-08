# P49 — покрытие osu! API v2: матрица и волны

2026-10-08 · запрос пользователя: покрыть 90–100 % доступного API, «как в osu!».
Статус: in_progress (волна 1). Источник — код osu-web, а не только docs:
`routes/web.php` (группа `api/v2`), `require-scopes` в контроллерах,
`RequireScopes::NO_TOKEN_REQUIRED`, `Models/OAuth/Token::validate()`,
`ppy/osu-notification-server` (`oauth-verifier.ts`). Срез osu-web
`8d395f2` (2026-10-08).

## Как osu-web решает доступ

- Без токена (GET): `changelog`, `comments`, `news`, `seasonal-backgrounds`,
  `suggestions/wiki`, `wiki`.
- `public` — гостевой client-credentials токен приложения (как сейчас).
- `identify`, `friends.read`, `forum.write` — нужен вход пользователя
  (authorization code). На iOS вход заблокирован [P37](P37-ios-oauth-callback.md).
- `chat.read`, `chat.write`, `chat.write_manage` — **только** если OAuth-клиент
  принадлежит bot-аккаунту (или пользователь — владелец клиента):
  `InvalidScopeException('bot_only')`. Bot-статус выдаёт команда osu!.
- Маршрут без `require-scopes` требует `*` — это scope `lazer`, только
  официальный клиент. Сторонним приложениям недоступно никогда.
- Websocket `notify.ppy.sh` принимает токен только со `*` или `chat.read`.

BFF ([P17](../DETAILS.md#p17)) этих правил не меняет: он ретранслирует запросы
с токеном пользователя и scopes остаются теми же. BFF даёт нормальный OAuth
callback, скрытый secret, кэш и собственные функции поверх API.

## Матрица

| Раздел | Эндпоинты | Доступ | У нас |
| --- | --- | --- | --- |
| Users | `users/{id}[/{mode}]`, `scores/best\|recent`, `beatmapsets/{type}` | public | есть |
| Users | `scores/firsts\|pinned`, `recent_activity` | public | волна 1 |
| Users | `users/{id}/kudosu` (история), `beatmaps-passed`, `users?ids[]`, `users/lookup` | public | волна 4 |
| Me | `me/{mode}` | identify | есть (вход) |
| Me | `me/beatmapset-favourites`, `friends` | identify / friends.read | после P37 |
| Rankings | performance/score/country/team/charts, kudosu, spotlights | public | есть |
| Beatmaps | `beatmaps/{id}`, `scores`, `beatmapsets/{id}`, `search` | public | есть |
| Beatmaps | `scores/users/{user}[/all]`, `lookup`, `attributes` (SR с модами), `packs` | public | волна 4 / 3 |
| Discussions | `beatmapsets/discussions`, `posts`, `votes`, `events` (моддинг) | public | волна 3 |
| Scores | `scores/{id}`, `scores` (лента последних, cursor) | public | частично / волна 4 |
| Comments | чтение | без токена | есть |
| Comments | создать / голос / удалить | `*` (lazer) | недоступно |
| News | список / статья | без токена | есть |
| Changelog | `changelog`, `{stream}/{build}` | без токена | есть (P50) |
| Wiki | `wiki/{locale}/{path}`, `suggestions/wiki` | без токена | есть (P52), suggestions — нет |
| Events | `events` (глобальная лента, cursor) | public | есть (P51) |
| Seasonal backgrounds | список фонов сезона | без токена | волна 2 (оформление) |
| Forum | `forums`, `forums/{id}`, `topics`, `topics/{id}` | public | готово ([P54](P54-forum.md)) |
| Forum | ответ / новая тема / правка | forum.write | после P37 |
| Matches | `matches`, `matches/{id}` (legacy multiplayer) | public | волна 3 |
| Multiplayer | `rooms`, `leaderboard`, `events`, `playlist/{id}/scores` | public | частично (карта дня), волна 3 |
| Teams | `teams/{id}[/{ruleset}]` | public | есть |
| Search | `search?mode=user\|wiki_page` | public | есть (P48, P52) |
| Chat | каналы, сообщения, ЛС, presence | chat.* (bot-only) | недоступно без bot-клиента |
| Websocket | уведомления и чат в реальном времени | `*` или chat.read | недоступно без bot-клиента |
| Notifications | список / прочитано | `*` | недоступно |
| Favourites, ratings, score pins, blocks, reports, me/options, rooms join, solo scores | запись | `*` | недоступно |
| Downloads | `beatmapsets/{id}/download`, `scores/{id}/download` | `*` | недоступно |

## Волны

1. **Профиль и оценки** (сейчас): «Первые места», «Закреплённые», недавняя
   активность; оценки SS/S/A/B/C/D/F в стиле osu!lazer `DrawableRank`.
2. **Лента osu!** (поэтапно, решение 2026-10-08): changelog — готово в
   [P50](P50-osu-hub-changelog.md) внутри вкладки «osu!»; глобальные события —
   готово в [P51](P51-global-events.md); wiki — [P52](P52-wiki.md); остались сезонные фоны.
3. **Сообщество**: форум (разделы, темы, посты — только чтение), beatmap packs,
   мультиплеерные матчи и комнаты, моддинг-обсуждения карт.
4. **Карты и результаты**: результат игрока на сложности, звёзды с модами
   (`attributes`), лента последних результатов, история kudosu, пройденные карты.
5. **После решения P37** (вход на iOS): избранное, друзья, ответы на форуме.
6. **Только с bot-клиентом** (заявка в команду osu!, решение пользователя):
   чат и websocket. Уведомления и запись комментариев остаются недоступны.

Каждая волна — отдельная карточка со сверкой формата ответа, allowlist в
`osu_public_authorization_interceptor.dart`, семь локализаций, сборка и запуск
в симуляторе.

## Волна 1 — оценки и профиль

Оценки: `ppy/osu` (MIT) `osu.Game/Online/Leaderboards/DrawableRank.cs` и
`OsuColour.ForRank` (срез `7e25f11`). Плашка 2:1 со скруглением, фон — цвет
оценки с треугольниками на ±10 % яркости, буква — SS/S золотым градиентом
(#FFE7A8→#FFB800), серебряные XH/SH белым градиентом (#FFFFFF→#AFDFF0),
A #275227, B #553A2B, C #473625, D #512525, F #CC3333 на #3F3F3F.
Иконки сайта (`osu-web/public/images/badges/score-ranks-v2019/*.svg`) под
AGPL-3.0 — не берём без решения о лицензии проекта; рисуем кодом по lazer.

Профиль: `scores/firsts|pinned` — те же Score, пагинация limit/offset до 100
на страницу. `recent_activity` — Event[] (achievement, beatmapPlaycount,
beatmapset*, rank, rankLost, userSupport*, usernameChange), limit/offset, не
более 100 записей; `url` у событий относительные (`/b/…`, `/s/…`, `/u/…`).

### Реализация волны 1 (2026-10-08)

- `lib/src/_shared/ui/osu_grade.dart` — `OsuGradeBadge` (высота задаётся,
  ширина 2×), статический фон из треугольников, семантика «Оценка: Серебряная S»
  (`gradeSilver`). Профиль (счётчики оценок) 28, карточки 24, детали 32.
- `ProfileScoresType` += `pinned`, `firsts`; тот же Bloc/cache/пагинация.
- `lib/src/profile/activity/` — source/DTO/repository/Bloc/section; вкладка
  «Активность» в профиле, ленивая загрузка при первом открытии. Неизвестный
  тип события пропускается (не ломает список). `relativeTime` вынесен в
  `_shared/ui/relative_time.dart` (общий с комментариями).
- Сборка Xcode → Tracksu iPhone 17: успешно. GUI-проверка — пользователем.

### Доработка после проверки (2026-10-08)

- Оценки: пропорции сняты с сайта (32×16): заглавные 55 % высоты, центр на
  48 %, растяжение букв ×1.4, тёмная копия на 1/16 ниже для S/SS/F. Центровка
  по высоте заглавных Exo 2 (sCapHeight 690/1000), а не по строке текста.
  Иконки сайта не используются (AGPL), рисуем своим кодом.
- Вкладки профиля: Профиль / Результаты / Активность / Карты.
- Порядок «Профиля» как на сайте: шапка → друзья/подписчики на карты
  (`follower_count`, `mapping_follower_count`) → команда и группы → график
  рейтинга → карта дня → оценки одной строкой → «О себе» → статистика
  (уровень — тонкая строка внизу карточки) → очки → медали, ranked play →
  графики игр и повторов. `ProfileDetailsSections.parts` разбивает блоки.
