# P26 — общий foreground-аудиоплеер

2026-09-22 · реализовано, ручная приёмка открыта. Продолжение P23.

## Реализация

- `UiAudioPlayer` — чистый UI kit: компактная tonal-панель, Play/Pause/Replay,
  отмена loading, status/error, position/duration и native slider. Seek только
  после завершения жеста; disableAnimations отключает движущийся progress.
  Offline-пример добавлен в product catalog, каталог не запускался.
- `AudioPlaybackController` в DepsContainer, плагин создаётся только после Play.
  Единственный активный decoder; retirement/focus release сериализованы перед
  новой активацией. Owner token и generation не позволяют старой странице или
  позднему load включить/остановить новый трек. Подписки и таймеры закрываются.
- В карте читается `preview_url` из API (не выдумывается при отсутствии).
  Один preview на набор, не отдельный для каждой сложности. Artist/title — из API.
- ContentNormalizer переводит `<audio src>` / прямые `<source src>` в typed
  ContentAudio; максимум 32 аудиоблока на документ. При нескольких sources
  выбирается первый поддержанный. Audio URL не передаётся HtmlWidget.
  ContentFrame использует тот же плеер для новостей и других rich-content мест;
  без controller (catalog) сети нет. Неизвестные embeds ведут на оригинал.
- Пауза сохраняет позицию и освобождает decoder/network buffers; resume снова
  загружает тот же URL с initialPosition. Переключение route/branch освобождает
  источник; app inactive/background и interruption/headphones disconnect ставят
  паузу. Возврат/конец звонка не запускает звук автоматически.
- Активный inline-блок keep-alive в lazy-документе: прокрутка новости не обрывает
  трек. При удалении документа/сворачивании disclosure ресурс освобождается.
- Loading/buffering ограничены 25 секундами, ошибка показывает Retry. Ошибка
  плагина не попадает в OAuth-поток; при исключении в diagnostic идёт только
  обезличенный тип ошибки с исходным stack trace, не URL/текст platform error.
- `just_audio 0.10.6` и `audio_session 0.2.4` уже были transitive dependencies;
  добавлены как direct без обновления версий. Pubspec metadata перегенерированы.

## Сеть, разрешения и честные ограничения

- Только HTTPS/443, без credentials/query/fragment, MP3 с `b.ppy.sh/preview/ID.mp3`
  либо `assets.ppy.sh/artists/ID/...mp3`. Нет arbitrary third-party audio,
  локальных файлов, manifest/playlist URL, iframe/JS/video/WebView.
- Трафик воспроизведения обслуживает native media stack, не OAuth RestClient:
  без access token/cookies Tracksu/custom headers/локального HTTP proxy.
  Не отключаются TLS-проверки и не включается cleartext. Сетевые redirects и
  buffering контролирует плагин/платформа: это доверенный first-party media path,
  а не sandbox для произвольных пользовательских хостов.
- До Play виден локализованный notice о передаче IP аудиосерверам osu! и трафике.
  Play — явное действие на конкретном аудио, **не** расширение сохранённого
  разрешения на внешние картинки. Изменение image permission не включает аудио.
  Никакой prefetch/autoplay. Публичная policy/terms остаётся release gate P01.3.
- Нет скачивания/постоянного audio cache, фонового сервиса, очереди, notification
  controls, Dynamic Island или Live Activities. Уход с route сбрасывает позицию;
  app interruption/pause сохраняет её, пока живёт inline owner.
- Основная собираемая платформа проекта — Android. Native focus/lifecycle,
  воспроизведение и отображение требуют ручной проверки; iOS-target сейчас
  отсутствует, его готовность этим срезом не заявляется.

## Проверка

Только scoped formatter, gen-l10n, pubspec build_runner, статический анализ
`fvm flutter analyze --no-pub lib packages`, review diff/контрактов.
Анализатор: **No issues found (2.3s)**; `git diff --check` чистый.
Без тестов, APK, запуска приложения/каталога и прослушивания на устройстве.

Ручная приёмка:

- Play → pause → seek → resume → completion → replay на карте.
- Новость с несколькими audio: звучит один; при прокрутке продолжает играть.
- Быстрые Play/Cancel/другой трек/Back/смена вкладки во время загрузки.
- Отказ audio focus, звонок, снятие наушников, background: нет авто-resume.
- Offline/404/timeout → Retry; ошибка аудио не ломает текст/данные страницы.
- Крупный шрифт, семь языков, клавиатурная/accessible перемотка, reduced motion.

## Первичные контракты

- [BeatmapsetCompactTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/BeatmapsetCompactTransformer.php): preview_url.
- [Beatmapset](https://github.com/ppy/osu-web/blob/master/app/Models/Beatmapset.php): HTTPS MP3 preview URL.
- [News styling criteria](https://osu.ppy.sh/wiki/en/News_styling_criteria): audio/source с assets.ppy.sh/artists.
- [just_audio](https://pub.dev/packages/just_audio): lifecycle, completion, activation, native source и errorStream.
- [audio_session](https://pub.dev/packages/audio_session): music attributes, focus/interruption/noisy events.
