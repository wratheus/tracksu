# P52 — osu! wiki (волна 2, этап 3)

2026-10-08 · решение пользователя: wiki — третьей вкладкой поиска; Markdown
через пакет `markdown` и общий конвейер ([ADR-008](../../decisions/ADR-008-unified-rich-content.md)).
Статус: awaiting_manual_check. Часть [P49](P49-api-coverage.md).

## API (osu-web, срез 8d395f2)

- Статья: `GET /api/v2/wiki/{locale}/{path}` — без токена
  (`NO_TOKEN_REQUIRED`), WikiPage: `title`, `subtitle`, `markdown`, `path`,
  `locale`, `available_locales`, `tags`. 404 → повтор на `en`.
  Allowlist: `^/api/v2/wiki/[a-z]{2}(-[a-z]{2})?/.+$`.
- Поиск: `GET /search?mode=wiki_page&query=&locale=&page=` (scope public),
  `{wiki_page: {data: WikiPage[], total}}`, 50 на страницу.
- Относительные ссылки и картинки osu-web разрешает от URL статьи как каталога
  (`relative_url_root` = wiki_url(path, locale)); у нас база
  `https://osu.ppy.sh/wiki/{locale}/{path}/`. Картинки `…/img/x.png` сайт
  перенаправляет в `/wiki/images/…` (`WikiController`).

## Поведение

- Поиск → «Игроки / Карты / Вики»; поле «Статья вики», подсказка до двух
  символов, debounce общий, подгрузка страниц в конце, «Поделиться» —
  поиск wiki на сайте.
- Статья: подзаголовок (раздел), заголовок, пометка «Перевода пока нет —
  показана английская статья», тело в `ContentFrame` (картинки по общей
  настройке медиа, таблицы, код, цитаты, списки). Ссылки на другие статьи
  wiki (`/wiki/…`, с языком или без) открываются в приложении, якоря `#…`
  игнорируются, прочее — во встроенном браузере. Pull-to-refresh, линия
  прогресса, «Поделиться» — статья на сайте.
- Язык статьи — язык приложения (`effectiveLanguageCode`), из поиска — язык
  найденной статьи. Кэш статьи в `PageCache` по (язык, путь).
- Route `…/wiki?path=…&locale=…` в каждой ветке; путь и язык валидируются.

## Код

`lib/src/wiki/` — domain (`WikiParams`, `WikiArticle`, `WikiLinks`),
`WikiRepository`, `WikiArticleBloc`, `WikiSearchBloc`, `WikiScreen`,
`WikiSearchResults`, `WikiMain`; `ShareTarget.wiki`/`wikiSearch`;
`TracksuAppRouter.openWiki`. 8 строк в 7 языках.

## Не сделано

- Ссылки на wiki из новостей, профилей и комментариев пока открываются в
  браузере; перехват в приложение — отдельной правкой.
- Контейнеры osu! (`::: Infobox`, `::: Notice`) выводятся обычным текстом,
  без рамок; сноски — как в GitHub Markdown.

## Проверка

Сборка Xcode → Tracksu iPhone 17 успешна. GUI — пользователь: поиск
«Hit object», открыть статью, картинки, таблица, переход по внутренней
ссылке, язык ru с откатом на en, «Поделиться».
