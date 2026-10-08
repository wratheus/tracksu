# P55 — паки карт (волна 3, этап 2)

2026-10-09 · запрос пользователя: «паки сделаем, не знаю куда это сунуть и
как сделать лучше по дизайну». Статус: awaiting_manual_check.
Часть [P49](P49-api-coverage.md).

## API (osu-web `BeatmapPacksController`, срез 04643de)

- `GET /beatmaps/packs?type=&cursor_string=` — scope public, 100 на
  страницу, курсор. `BeatmapPack`: `tag`, `name`, `author`, `date`,
  `ruleset_id` (null — все режимы), `no_diff_reduction`, `url` (файл).
- Типы (`BeatmapPack::TYPES`): standard `S`, featured `F`, tournament `P`,
  loved `L`, chart `R`, theme `T`, artist `A` — буква начинает тег.
- `GET /beatmaps/packs/{tag}?legacy_only=0` — пак + `beatmapsets`
  (обычный Beatmapset, без сложностей) и `user_completion_data` (для гостя
  пусто; прогресс прохождения — после входа, P37).
- Allowlist: `^/api/v2/beatmaps/packs(/tag)?$`.

## Где и как

- **Главная**: полка «Паки карт» под картой дня — 7 плиток типа (иконка,
  название, строка описания, свой цвет-акцент, скосы как у сегментов),
  листается вбок от края до края. Плитки статичные, без запросов.
- **Список** (`…/packs?type=`): выбор типа (`OsuCategoryPicker`) с
  описанием типа, ниже строки паков — цветной чип тега, название, дата ·
  автор, иконка режима; подгрузка в конце, первая страница каждого типа в
  кэше сессии, смена типа отменяет прошлый запрос.
- **Пак** (`…/pack/{tag}`): шапка с градиентом цвета типа — тип, тег,
  название, дата · автор, режим или «Все режимы», число карт, «моды на
  упрощение не засчитываются»; дальше карты пака карточками → страница
  карты.
- Ссылки `osu.ppy.sh/beatmaps/packs[?type=]` и `/beatmaps/packs/{tag}`
  открываются в приложении; «Поделиться» — пак/список на сайте.
- Скачивание пака (`url`) не делаем: файл архива, приложению он не нужен.

## Код

`lib/src/packs/` — `domain/packs.dart`, `data/packs_repository.dart`,
`list/bloc/`, `pack/bloc/` (bloc/event/state), `widgets/`
(`BeatmapPacksShelf`, `BeatmapPacksScreen`, `BeatmapPackScreen`,
`pack_type_style.dart`), `main.dart`. 25 строк в 7 языках.
