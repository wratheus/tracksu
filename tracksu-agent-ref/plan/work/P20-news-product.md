# P20 — продуктовый срез новостей

2026-09-10 · awaiting_manual_check · baseline `22eaef1`, чистый worktree.

## Scope

- Карточки с first_image@2x/first_image, локализованной датой и общими интервалами.
- Внешние обложки используют существующее разрешение ContentMediaController и
  bounded loader: без API credentials/cookies, с отменой при скрытии/выходе.
  Согласие одно на устройство, не отдельное для каждой новости.
- Читаемая шапка статьи, компактный refresh, сохранение paging/retry/scroll.
- Не дублировать первую картинку статьи: она уже находится в rich-content body.

Repository/DTO нормализуют URL, source по-прежнему возвращает raw payload.
Bloc владеет данными/пагинацией, UI — видимостью media и переходами.
Новых endpoints/scopes/dependencies/storage нет. Year search, comments и media
embeds не входят в срез; оригинал статьи остаётся доступен.

## Контракт и проверки

Официальный NewsPostTransformer проверен 10 сентября: first_image и
first_image@2x входят в основной response; content — include.
Источник: https://github.com/ppy/osu-web/blob/master/app/Transformers/NewsPostTransformer.php

Gate: scoped format, `fvm flutter analyze --no-pub lib packages`, diff review.
Тесты/APK не запускаются по решению пользователя. Ручная приёмка: разрешить/
отказать/отозвать картинки, ошибка картинки, возврат из статьи, пагинация,
refresh со старым контентом, длинные заголовки и семь языков.
Откат — revert локального коммита среза, без удаления пользовательских данных.

## Реализовано и проверено

Scope реализован. ContentImageView.preview переиспользует существующую
проверку raster/decode, ограничивает preview 1024 px; ContentMediaScope владеет
очередью на ленту (два запроса), учитывает route/branch/lifecycle/permission.
Загруженные превью сохраняются при перекрытии маршрута, незавершённые повторяются
после возврата. Отзыв разрешения удаляет изображения из ленты.
Нет новых ARB-строк: используются существующие переводы и locale-aware DateFormat.

- Scoped `fvm dart format` — выполнен.
- `fvm flutter analyze --no-pub lib packages` — No issues found.
- `git diff --check` и review ошибок/ownership/paging — выполнены.
- Тесты/APK/визуальный запуск не выполнялись по договорённости.

Ручной checklist выше остаётся открытым. Это не заявление о проверке на устройстве.
