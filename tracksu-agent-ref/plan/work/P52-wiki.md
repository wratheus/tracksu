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
  игнорируются. Pull-to-refresh, линия
  прогресса, «Поделиться» — статья на сайте. Внешние ссылки — в
  `WebPageScreen` (одна страница, ADR-009).
- Язык статьи — язык приложения (`effectiveLanguageCode`), из поиска — язык
  найденной статьи. Кэш статьи в `PageCache` по (язык, путь).
- Route `…/wiki?path=…&locale=…` в каждой ветке; путь и язык валидируются.

## Код

`lib/src/wiki/` — domain (`WikiParams`, `WikiArticle`, `WikiLinks`),
`WikiRepository`, `WikiArticleBloc`, `WikiSearchBloc`, `WikiScreen`,
`WikiSearchResults`, `WikiMain`; `ShareTarget.wiki`/`wikiSearch`;
`TracksuAppRouter.openWiki`. 8 строк в 7 языках.

## Доработки (2026-10-08)

- Ссылки на wiki из новостей, профилей, комментариев, changelog и команд
  открываются в приложении через `AppLinks.open`
  ([P53](P53-in-app-links.md), [ADR-009](../../decisions/ADR-009-single-page-viewer.md)).
- Контейнеры osu! (`::: Infobox`, `::: Notice`, …) рисуются рамкой-цитатой:
  `MarkdownContent` префиксует строки блока `> ` (вложенность до 4, код в
  ```` ``` ```` не трогается, незакрытый блок заканчивается с текстом).
  Сноски — как в GitHub Markdown.
- Встроенные контейнеры osu! (`CustomContainerInline` в osu-web):
  `::{ flag=NL }::` → эмодзи флага (без запроса картинки),
  `::{ user=2 }peppy::` и `::peppy::{ user=2 }` → ссылка на профиль (откроется
  в приложении); прочие атрибуты — просто текст. Код в ```` ``` ```` не
  трогается.
- Блоки разделены: `wiki/article/bloc/` и `wiki/search/bloc/`
  (`bloc.dart` / `event.dart` / `state.dart`).

## Проверка

Сборка Xcode → Tracksu iPhone 17 успешна. GUI — пользователь: поиск
«Hit object», открыть статью, картинки, таблица, переход по внутренней
ссылке, язык ru с откатом на en, «Поделиться».
