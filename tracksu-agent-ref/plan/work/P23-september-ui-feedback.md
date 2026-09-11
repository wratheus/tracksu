# P23 — обратная связь 10 сентября

2026-09-10 · in_progress · baseline `2722b7a`, чистый worktree на старте.

## Текущий срез

- [x] Главная делится GitHub Tracksu; классический selector подписан `ctd`.
- [x] Язык только в настройках, выбранный язык с флагом.
- [x] Keyboard/shell: убрать резерв bottom bar при клавиатуре; смена темы 280ms/easeInOutCubic, без анимации при disableAnimations.
- [x] Исправить HTTPS внешних картинок без обхода consent/сертификатов.
- [x] Сложности: до 12 wrapping chips, выбранная всегда видна; `+N` открывает полный lazy picker.
- [x] Score sheet: edge-to-edge cover в верхнем закруглении и minimum extent с учётом шапки.
  Уточнение пользователя: **не доли попаданий**, а шкала грейдов как в lazer.
  UiGradeGauge: толстое кольцо точности, тонкая шкала, грейд API в центре,
  labels вокруг (на узком экране/крупном тексте — легенда), отдельные hit counts.
  Шкала — lazer reference, не пересчёт серверного grade и не map completion.
  Виртуальная зона SS с 99% только для видимости, реальное SS требует 100%:
  это оговорено в tooltip/accessibility на семи языках.
- [x] Пустая daily challenge без стены нулей/служебных дат; точные большие числа
  в компактной читаемой верстке вместо непонятного сокращения триллионов.
- [x] Центрированная начальная загрузка медалей.
- [x] Memory page cache: profile (имя/ID/current + ruleset), beatmap (тип/ID),
  news feed/article, rankings (type/country/variant). Не более 40 snapshots,
  TTL 30 минут; всегда revalidate, только успешный ответ заменяет данные,
  ошибки сохраняют прежний snapshot. Новости/рейтинги кешируют первую страницу,
  не склеивают новые первые страницы со старой pagination.
- [x] Скелетоны этих четырёх разделов только при отсутствии snapshot, refresh
  не заменяет данные скелетоном. Primitives/recipes в tracksu_ui, static/reduced motion.
- [x] Rich-media memory LRU: 24 MiB/100 элементов, TTL 30 минут, только
  проверенные raster bytes, удаление плохого decode перед Retry. Стандартные
  аватары/баннеры используют существующий Flutter decoded image cache.
- [x] Очистка страниц и картинок из настроек, без logout/сброса preferences;
  уже открытые страницы/картинки не исчезают. Cache revision не позволяет
  нашим незавершённым запросам заново заполнить очищенный snapshot/cache.
  Identity revision сессии инвалидирует page cache при новом OAuth/logout,
  в том числе при смене аккаунта без signedOut. Rich cache очищается при revoke.

## Следующие связанные этапы, не объявлять реализованными

- [x] Расширить page snapshots/skeletons на scores/коллекции карт (11 сентября).
- [ ] Расширить page snapshots/skeletons на медали/spotlights
  и таблицу результатов карты. Их текущие route states сохраняются пока route жив.
- [ ] Disk cache/офлайн после перезапуска и измерение размера — отдельно; сейчас
  прямо раскрываем в настройках memory-only политику, не обещаем offline.
- [ ] Общий аудиоплеер: preview карты и поддерживаемые audio sources новостей;
  только явный Play, один поток, lifecycle/audio focus, loading/error/retry,
  проверка URL/форматов и внешнего media consent. Никаких произвольных iframe/JS.
- [ ] Liquid Glass — только позже по отдельному визуальному решению.
- [ ] Dynamic Island / Live Activities — future plan, без реализации в этом срезе.

UI kit владеет reusable chart/sheet, feature — семантикой данных и переходами;
загрузчик — сетью/отменой/ограничениями, настройки — сохраненным выбором.
Поэтапные локальные коммиты, без push. Format/analyze lib/packages/diff review;
никаких тестов/APK/запуска. Визуальное подтверждение — пользователь на телефоне.

## Причина media bug и источники шкалы

Проверено в закреплённом Dart SDK: custom HttpClient.connectionFactory заменяет
встроенный SecureSocket.startConnect. Старый код возвращал plain TCP для HTTPS.
Теперь проверяем DNS, соединяемся с проверенным IP и явно вызываем
SecureSocket.secure(host: uri.host): TLS/SNI/системная проверка сертификата,
без badCertificateCallback. Есть fallback между проверенными адресами при TCP
ошибке/таймауте; ограничения HTTPS/redirect/MIME/bytes/pixels сохраняются.

Шкала сверена с первичными исходниками, Flutter-код написан самостоятельно:
- https://github.com/ppy/osu/blob/master/osu.Game/Screens/Ranking/Expanded/Accuracy/AccuracyCircle.cs
- https://github.com/ppy/osu/blob/master/osu.Game/Rulesets/Scoring/ScoreProcessor.cs
- https://github.com/ppy/osu/blob/master/osu.Game.Rulesets.Catch/Scoring/CatchScoreProcessor.cs

## Ручная приёмка — открыта

### Дополнения 11 сентября — реализованы, ожидают ручной проверки

- UiSliverAutoLoad вместо load-more кнопок: scores/maps профиля, rankings, news.
  200ms debounce при попадании footer в cache extent; один dispatch на page key,
  продолжение при недостаточной высоте страницы, pause на скрытом route/TickerMode
  и app background. Timer отменяется при удалении/уходе от конца списка.
- `bloc_concurrency`: News — droppable; сменяемые queries scores/maps/rankings —
  concurrent + synchronous busy guard + generation/latest-wins. Не делаем sequential
  очередь устаревших фильтров. Повторный cursor/offset/page или отсутствие новых
  элементов при объявленном продолжении — invalid response с ручным Retry.
  Refresh failure не запускает paging. Данные не исчезают при ошибке догрузки.
- Cache scores/maps: key user/ruleset (scores)/type, первый успешный page snapshot,
  та же bounded LRU/TTL/session revision и clear protection. Не смешиваем новую
  первую страницу со старой догрузкой. При cold load общий статический skeleton.
- UiLoading — compact Column, кольцо 36px, скруглённые края, подпись снизу.
  Medals/spotlights центрируют весь блок; country sheet — SliverFillRemaining.
  Adaptive sheet не пытается подогнать высоту по растянутому loading viewport.
- OsuPlayerFlags объединяет country + team: 28×20, radius 4, gap 4, tooltip.
  Profile/rankings/spotlights используют общий player card; map leaderboard
  переносит country/team из user payload в карточку и sheet результата.
  Нет N+1 запросов или выдуманных команд; подробная affiliation в профиле остаётся.
- `pubspec_generator` 5.0.2 в build_runner, deterministic timestamp:false.
  Версия/build в About берутся из Pubspec.version; platform только package ID.
  Generated pubspec metadata коммитится, Envied-конфиг остаётся ignored.
  После изменения pubspec выполнять генерацию, native overrides не источник версии.

Проверить вручную: быстрый scroll/смена типа во время догрузки, подгрузка короткого
списка, ошибка/offline и Retry без цикла; вкладка под другим route/background;
повторный вход в scores/maps и clear cache; размер/скругление обоих флагов;
loading медалей и country sheet с большим шрифтом; About после смены версии.

Документация зависимостей: [pubspec_generator](https://pub.dev/packages/pubspec_generator),
[bloc_concurrency](https://pub.dev/packages/bloc_concurrency).

Текущий gate: format, build_runner generation, analyze lib/packages, diff review.
Тесты/APK/catalog/device не запускались. Audio и оставшееся cache coverage не закрыты.

Телефон: keyboard open/close и прокрутка к submit; новости covers/inline после
allow, revoke/retry; повторный профиль/режим offline и после cache clear;
смена аккаунта; chips 1/12/больше сложностей; sheet drag/landscape/крупный текст;
кольцо S/A/F/100%, длинные цифры; язык с флагом; medal loading по центру.
Наличие format/analyze не означает, что внешний вид проверен на устройстве.

## Проверки текущего среза

Scoped `fvm dart format`, `fvm flutter gen-l10n` (семь локалей, untranslated `{}`),
`fvm flutter analyze --no-pub lib packages` и `git diff --check` выполнены.
Review: cache keys/identity revision, только success writes, refresh failure,
clear during IO, отмена DNS/TCP/TLS/decode, bounds/cache eviction, sheet extent,
mounted/ownership. Анализатор — без замечаний. Тесты/APK/catalog не запускались.
Результат реализации — awaiting_manual_check; вся P23 остаётся in_progress
из-за отдельного audio этапа и расширения cache coverage.
