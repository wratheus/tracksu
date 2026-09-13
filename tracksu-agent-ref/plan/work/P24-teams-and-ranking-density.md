# P24 — команды, компактный рейтинг и доступ к настройкам

2026-09-13 · implemented / awaiting_manual_check · baseline `5c2e619`.

## Запрос и границы

Новая обратная связь пользователя имеет приоритет над оставшимся аудиоплеером P23:
настройки доступны не всегда; рейтинг слишком карточный, нужна жёлтая позиция
`#` и PP справа; нужна полноценная нативная страница клана/команды.
Здесь команда — API Team, а не staff-группа BNG/GMT. Staff-группы по-прежнему
ведут на сайт. Не добавляем чат, вступление, управление составом или BFF.

## Реализовано

- SettingsButton не зависит от `_busy` аккаунта/открытия своего профиля.
  Общая кнопка есть на главной, в рейтингах, spotlights, новостях/статье,
  профиле, медалях, карте и команде. Не требует входа или успешной загрузки API.
- OsuRankingRow: компактная строка, жёлтый `#rank`, аватар, ник, country/team
  flags; PP отдельной правой колонкой целым числом. Score-sort и spotlights
  используют тот же layout, но показывают свой score, не выдуманные PP.
- Профильный флаг и подробная affiliation, флаги в рейтингах/spotlights
  открывают нативную команду. Флаг остаётся 28×20; интерактивная область 44×44,
  tooltip/семантика и отдельный child tap не должны открывать игрока.
  Переходы через facade внутри текущей сохраняемой shell-ветки.
- Team: cover, flag, name/tag, created date, default mode, recruitment, free
  slots, roster count, leader и lazy roster. Участники показывают аватар, страну,
  online/last visit, supporter и полученные группы; открывают свой профиль.
  Удалённый лидер не ломает страницу, переход для него отключён.
- Статистика команды по четырём режимам: performance, play_count,
  ranked_score; optional rank отображается только если реально передан.
  Новый режим загружается с пометкой старых данных, а не подменой их значения.
- BBCode-описание проходит bounded adapter → общий HTML allowlist → ContentFrame.
  Поддерживаются текстовые стили, ссылки, изображения, списки, цитаты, code,
  box/spoiler. Неизвестные теги остаются текстом; raw HTML не исполняется.
  Нет WebView/JS/iframe. Картинки используют существующее разрешение и лимиты.
  Слишком большой/сложный документ не ломает команду: доступен оригинал.
- Remote возвращает raw map, DTO создаётся repository, sealed BLoC states/events,
  concurrent + generation/latest-wins + cancel IO. Refresh сохраняет успешные
  данные при ошибке. Общий memory PageCache по team/ruleset, cold skeleton,
  identity/clear revision сохраняются; дисковый offline не обещаем.
- Share команды и оригинал osu!, локализация на семи языках.
  Offline catalog дополнен ranking-row и BBCode-рецептами, не запускался.

## Проверенный контракт

`GET /api/v2/teams/{team}/{ruleset?}`, scope public. Режим по умолчанию задаёт
команда. Extended включает `leader`, `members`, `empty_slots`, `statistics`.
`members` не включает лидера; roster count вычисляется из реально полученного
списка + лидера, не является выдуманным server member_count.

Источники: официальные исходники osu-web, проверены 13 сентября:

- https://osu.ppy.sh/docs/
- https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/TeamsController.php
- https://github.com/ppy/osu-web/blob/master/app/Transformers/TeamExtendedTransformer.php
- https://github.com/ppy/osu-web/blob/master/app/Transformers/TeamTransformer.php
- https://github.com/ppy/osu-web/blob/master/app/Transformers/TeamStatisticsTransformer.php
- https://github.com/ppy/osu-web/blob/master/app/Transformers/UserCompactTransformer.php

В API-ответе нет website extraStatistics и индивидуальных PP каждого участника;
не делаем N+1 профильных запросов и не выдаём производные числа за API.
Доступные только сайту операции остаются за кнопкой «Открыть оригинал».
Исходники используются для проверки контракта, PHP-код не переносился.

## Проверка и ручная приёмка

Gate: gen-l10n, scoped format, `fvm flutter analyze --no-pub lib packages`,
diff review. По текущему запрету никаких тестов/APK/device/catalog запусков.

Фактический результат 13 сентября: gen-l10n завершён, scoped format завершён,
analyze lib/packages — `No issues found!`; `git diff --check` чистый.

Ручная проверка пользователем остаётся открытой:

- Settings во всех перечисленных разделах при API loading/error, после Back,
  переключения вкладок и reselect-to-root, входа/выхода из аккаунта.
- Ranking на 320–430dp и увеличенном тексте, длинном нике/номере/PP;
  в score-sort справа score, child team tap не открывает профиль.
- Team → участник → Back, смена вкладки со сохранением scroll/стека.
- Режимы быстро подряд; refresh/offline/retry, пустая статистика/нет обложки,
  удалённый лидер, unknown BBCode, изображения с разрешением и без него.
- Повторное открытие/clear cache во время запроса, share/original, семь языков.

Дальше — незавершённые пункты P23 (аудио и cache coverage), не считать их закрытыми.
