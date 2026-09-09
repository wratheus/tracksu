# P11 — продуктовая доработка рейтинга

2026-09-09 · baseline 096a494 · awaiting_manual_check.

Один вертикальный коммит: аватары, позиция в выбранной таблице, метрика
по сортировке, отдельные ruleset/sort controls, страна с локальным поиском
и флагами, mania variants и lifecycle прокрутки. Spotlights — следующий
отдельный срез; новые API endpoints/scopes, страны как отдельный рейтинг,
friends, новые пакеты и хранение не входят.

Источник остаётся raw; repository разбирает DTO. API возвращает ranking/cursor,
размер страницы 50: позиция определяется исходной страницей/индексом до
дедупликации, не длиной клиентского списка и не global_rank пользователя.
При движении живого рейтинга уже показанные строки сохраняются; новые IDs
добавляются в серверном порядке, возможны пропуски позиций до refresh.
Аватар optional HTTPS, без credentials; ошибка картинки — штатный fallback.

Country picker: существующие локальные названия + коды bundled flags,
поиск по английскому названию/коду без сетевого запроса на ввод. Это каталог
выбора, не обещание рейтинга каждой страны: наличие определяет osu! API.
Никаких 7 копий списка стран/новой зависимости. Черновик поиска принадлежит
модалке, применяется только выбор; dismiss ничего не меняет.

Ruleset/sort меняются независимо; country сохраняется, 4K/7K сбрасывается
только при выходе из mania. Новый фильтр прокручивает к началу, refresh/append
и push/pop сохраняют scroll. Кэш каталога локален feature repository.

Проверки: только gen-l10n, scoped format, analyze lib packages и diff review.
APK/тесты не собирать и не запускать. Ручная приёмка пользователем:
фильтры на медленной сети, retry refresh/append, второй лист, back из профиля,
country search/clear/dismiss, недоступная страна, семь языков/крупный шрифт.
Откат — один scoped revert без миграции storage. README/CHANGELOG/ROADMAP вместе.

Контракт сверён по официальным исходникам:
[RankingController](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/RankingController.php),
[PAGE_SIZE](https://github.com/ppy/osu-web/blob/master/app/Models/Model.php),
[UserCompact](https://github.com/ppy/osu-web/blob/master/app/Transformers/UserCompactTransformer.php).

Реализовано: UI kit controls/cards, raw source → repository projections,
локальный каталог из asset bundle с feature-lifetime cache, lazy sheet/list,
отдельные состояния initial/refresh/append/error/end. Дубли исходной страницы
и неожиданный размер страницы считаются invalidResponse; cross-page дубли
не переносят уже показанного игрока в другую позицию.
Проверяем total перед вычислением позиции: если после сокращения таблицы
сервер мог прижать запрошенную страницу к последней, возвращаем invalidResponse,
а не выдаём повторную страницу за новые места. Полное обновление доступно.
Названия в существующем справочнике неполные: остальные bundled flag codes
показаны как коды. Полная локализация названий стран не заявляется.
Старый ручной input удалён, его неиспользуемые ARB hint/apply удалены;
country/invalid подписи оставлены для действующего UI-каталога.

Проверки: gen-l10n и format выполнены, analyze lib packages — No issues found.
APK, автотесты, живой API с токеном и устройство не запускались.
Ручная приёмка ожидается. Сторонние .gitignore/.metadata/analysis_options.yaml,
pubspec.lock и ios/test не менялись. Следом — Spotlights, затем P13/news.
