# P28 — media cache и обратная связь 22 сентября

2026-09-23 · implemented / awaiting_manual_check.

## Сделано

- `MediaCacheRepository` — единственный владелец дискового кэша публичных
  изображений и поддержанных MP3. UI kit получает данные/callbacks, не HTTP.
- `AppMedia.image` подключает cache и настройку ко всем сетевым аватарам,
  обложкам, флагам команд и медалям; rich reader использует тот же repository.
- Картинки включены по умолчанию. Предыдущий явный отказ не сбрасываем;
  Settings позволяет выключить/включить. Первое consent-окно P18 больше не нужно.
- Плеер внутри artwork в картах профиля, spotlights, деталях и score sheets,
  только при наличии поддержанного URL из API. Общий `BeatmapCover`, короткий
  `UiAudioPlayer.overlay`, интерактивный `UiModal.scrollable.coverAction`.
  Прямые MP3-ссылки и audio/source news-блоки проходят один allowlist/плеер.
- Навязчивый сетевой абзац у Play удалён во всех семи локалях; краткая информация
  о сети, IP и локальном кэше остаётся рядом с настройкой изображений.
- Возврат на корень Search освобождает disabled guard даже при reset ветки
  router, не завершившем старый push Future. Устаревший finally не сбрасывает
  новую навигацию.
- Флаги страны/команды 30×20 (+2 px), одинаковое скругление; командный hit target
  44 сохраняется. Ranking row выравнивает их по низу аватара; radius аватаров
  пропорциональный 16%, а не фиксированный 16 px на маленьких картинках.
- 224 именованных флага имеют полные en/ru/de/fr/es/ja/zh названия из CLDR 48.2.0,
  локализованные picker/выбранное значение; поиск также по коду. Служебный `__`
  не считается страной. Unicode notice включён в assets/LicensePage.

## Контракт кэша

- `getApplicationCacheDirectory()/tracksu_media_v1`, SHA-256 URI + тип файла,
  без отдельного URL index, OAuth tokens, cookies или API JSON на диске.
- Целевой бюджет 128 MiB / 500 готовых файлов, expiry семь дней **от записи**,
  не продлевается чтением. Проверка при старте и доступе, не фоновый таймер.
- LRU внутри процесса; после перезапуска порядок по времени записи.
  Аудиофайл удерживается до dispose native decoder; image read тоже pinned.
  Закреплённые файлы/ошибка файловой системы могут временно превысить бюджет;
  освобождение pin и следующие операции повторяют eviction.
- Дедупликация одинаковых запросов, максимум четыре загрузки одновременно,
  общий timeout 40 s на активную загрузку. MP3 ≤24 MiB, raster ≤16 MiB;
  изображения проверяются до decode (до 40 млн пикселей, сторона ≤16384).
- `.part` → atomic rename только по завершении; startup убирает свои partial
  файлы. Очистка инвалидирует revision, отменяет активные/устаревшие очереди,
  дожидается завершения и не допускает repopulation старым ответом.
- Выход из view отменяет его применение ответа; уже запрошенное публичное
  медиа может докэшироваться. Opt-out отменяет image transport; cache clear
  отменяет всё. Нет speculative audio fetch или autoplay.
- При недоступном диске проверенные изображения могут отображаться из bytes;
  audio может использовать HTTPS streaming fallback. Это best-effort cache,
  не гарантированная offline download library. ОС вправе очистить cache.
- Settings показывает байты **готовых файлов** в MiB и размер перед очисткой;
  после успешной очистки файлов — 0. Не выдаём heap/Flutter cache за disk bytes.
  Play останавливается перед удалением, аккаунт/настройки не затрагиваются.
- Page snapshots остаются прежними: 40 элементов, 30 min, memory-only,
  identity/revision guard, stale-while-revalidate, ошибка не затирает данные.

## Загрузка изображений

Первичные osu! CDN используют платформенные DNS/TLS (в том числе при VPN),
не произвольный pinning всех IP. Их redirects ограничены теми же хостами.
Произвольные rich-image хосты сохраняют проверку всего DNS-ответа и подключение
к проверенному public IP с TLS hostname/SNI. HTTPS/443, bounded redirects,
без cookies/OAuth/referrer. Нет bypass сертификатов или JS/WebView.

PNG/JPEG/GIF/WebP распознаются по байтам, а не только Content-Type; compressed
HTTP responses распаковываются с лимитом результирующих байтов. Это исправляет
известные ограничения старого loader, но не обещает загрузить удалённый,
заблокированный провайдером или неподдержанный ресурс. Rich GIF/WebP пока static.

## Проверки / приёмка

Выполнены format, `fvm flutter analyze --no-pub lib packages`, review lifecycle,
cache/clear races, DTO/domain propagation, l10n и diff. Генерация l10n/pubspec;
добавленные direct crypto/path_provider используют уже закреплённые версии.
Тесты не писались/не менялись/не запускались. APK/catalog/device не запускались.

Ручная проверка пользователем:

1. Найти двух игроков подряд, Back и повторный тап Search; кнопка не зависает.
2. После включения картинок: новости/статья/аватары/баннеры, off → on и reboot;
   при прежнем сохранённом отказе один раз включить в Settings.
3. Play в карточке/деталях/sheet/статье, второй трек, pause/seek/retry, смена
   вкладки/background. Повторное Play использует уже готовый файл.
4. Рост cache size; очистка во время загрузки/Play; затем повторная загрузка.
5. Узкий экран и крупный текст: flags/avatar/rank/PP, overlay slider/sheet.
6. Страны/поиск/selected label на семи языках.

P01.3 обновлён фактическим data inventory, но политика ещё не опубликована.
Отдельное согласие до подключения аналитики остаётся обязательным.
Background audio, Dynamic Island, Liquid Glass, BFF — не scope P28.

## Источники

- [CLDR 48.2.0](https://github.com/unicode-org/cldr-json/tree/48.2.0/cldr-json/cldr-localenames-full)
  — локализованные названия, provenance/license в `assets/licenses/unicode_cldr.txt`.
- [path_provider](https://pub.dev/packages/path_provider) — app cache directory.
- [just_audio](https://pub.dev/packages/just_audio) — воспроизведение файла;
  experimental LockCachingAudioSource/local HTTP proxy не добавлялись.
- [HttpClient.connectionFactory](https://api.dart.dev/dart-io/HttpClient/connectionFactory.html)
  — контракт custom connection; TLS проверяется по имени хоста.
