# P34 — Карта дня (Daily challenge) на главной

2026-10-04 · implemented in code / awaiting_manual_check.

## Цель и границы

Показать текущую карту дня osu! на главной (решение пользователя: «карта
дня очевидно на главную») и отдельную страницу с картой и рейтингом дня.
Scope: `lib/src/daily`, SearchHome, router, public allowlist, ARB, тест
декодера. Серии игрока (daily streak) в профиле, история прошлых дней и
вход пользователя не входят.

## Контракт osu-web (проверено по исходникам 2026-10-04)

- `GET /api/v2/rooms?category=daily_challenge&mode=active&limit=1` —
  `Multiplayer\RoomsController@index`, scope `public`. Для ответа с
  комнатами нужен заголовок **`x-api-version: 20240529`** или новее;
  приложение по умолчанию шлёт 20220705, поэтому remote source ставит
  версию **только для этого запроса** (`OsuApiHeadersInterceptor` не
  перезаписывает заданный заголовок). Ответ — JSON-массив комнат
  (`RoomTransformer`) с includes `current_playlist_item.beatmap.beatmapset`,
  `difficulty_range`, `host`, `playlist_item_stats`; на будущее декодер
  принимает и объект `{rooms: [...]}`.
- В комнате: `id`, `category`, `starts_at`, `ends_at`, `participant_count`,
  `current_playlist_item` (`beatmap_id`, `ruleset_id`, `required_mods[]`
  с `acronym`, `beatmap` с `version`, `difficulty_rating`, `beatmapset`).
- `GET /api/v2/rooms/{room}/leaderboard` → `{leaderboard: [...], user_score}`;
  строка — `accuracy` (0..1), `attempts`, `completed`, `pp`, `total_score`,
  `user_id`, `user` (`country`, `cover`, `team`). Эндпоинт **не описан** в
  официальной документации — риск изменения без объявления.
- Нет активной комнаты (между днями, сбой у osu!) — это пустой ответ,
  а не ошибка: главная ничего не показывает, страница — «Сейчас карты дня
  нет».

Источники: ppy/osu-web `routes/web.php`, `Multiplayer\RoomsController`,
`Models\Multiplayer\Room::search`, `Transformers\Multiplayer\RoomTransformer`,
`Multiplayer\PlaylistItemUserHighScore` (лидерборд);
https://osu.ppy.sh/docs/index.html (rooms index).

## Решение

- **Главная.** Под карточкой поиска — `DailyChallengeCard`: обложка с
  превью-плеером, метка «Карта дня» и «Осталось N ч M мин», название,
  артист, иконка режима, звёзды (цвет osu!), сложность, обязательные моды,
  число участников. Тап — страница карты дня. Загрузка — скелет, ошибка —
  тихий `UiNotice` с «Повторить», отсутствие карты — ничего. Главная
  тянется вниз для обновления, прогресс — линия под app bar.
- **Страница** `…/daily`: та же карточка, «Открыть карту»
  (`openBeatmap(BeatmapDifficultyParams(beatmapId, ruleset))`), «Рейтинг
  дня» строками `OsuRankingRow` (позиция по порядку API, компактный общий
  счёт, точность в подписи, тап — профиль в режиме карты дня, флаг
  команды — страница команды). Pull-to-refresh, прогресс под app bar,
  при сбое обновления — прежние данные и предупреждение.
- **Bloc** `DailyChallengeBloc(withLeaderboard)`: на главной лидерборд не
  грузится. Повторный запрос во время загрузки отбрасывается (`droppable`).
- `OsuStarBadge` вынесен из экрана карты в `osu_badges.dart` для повторного
  использования.
- Allowlist публичного клиента: `^/api/v2/rooms(/[1-9][0-9]*/leaderboard)?$`.

## Исправление 2026-10-04: красный экран на главной

`BlocProvider(create: createDailyChallengeBloc)` передавал в фабрику
контекст `create`, а она вызывала `DepsScope.of(context)` —
`dependOnInheritedWidgetOfExactType` в `create` запрещён (assert provider:
«Tried to listen to an InheritedWidget in a life-cycle that will never be
called again»), блок не создавался и главная падала. Теперь фабрика
принимает `DepsContainer`, а `DepsScope.of` вызывается с контекстом
`build`, как в остальных `*Main`.

## Тесты

`test/src/daily/repository_test.dart`: разбор комнаты (режим, моды, даты,
участники), объектная форма, «нет карты» → null, сломанный контракт →
`FormatException`, порядок и значения лидерборда.

## Проверка пользователем

- Главная: карточка под поиском, время до конца, моды, превью играет.
- Тянуть главную вниз: линия под app bar, карточка обновляется.
- Тап по карточке → страница: «Открыть карту» ведёт на нужную сложность
  и режим; строки рейтинга открывают профиль; флаг команды — команду.
- Без сети: на главной тихое предупреждение с «Повторить».

Исполнитель не запускал format/analyze/tests (проверку делает
пользователь); приложение собирается через Xcode.

## Возврат

Удалить `lib/src/daily`, секцию и BlocProvider в SearchHome, route `daily`,
regex в allowlist и ключи `daily*`. Кэш и auth не затронуты.
