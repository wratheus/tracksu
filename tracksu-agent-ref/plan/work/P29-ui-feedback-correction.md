# P29 — коррекция UI-обратной связи: аудио, изображения, ranking, skeleton

2026-10-02 · implemented in code / awaiting_manual_check.

## Состояние реализации

Исправления команд, shared UI transitions, content images и iOS Vorbis внесены
локальными коммитами `01f65e5`, `f97bb56`, `f27ea82`, `11b0eff`.
Сохранение списка rankings при refresh — `bb677d1`.
Общий статус: **awaiting_manual_check**; коммиты не заменяют приёмку.

## История correction 1

- **Аудио-форматы.** Preview CDN osu отдаёт `/preview/{id}.mp3` как Ogg Vorbis
  (`content-type: audio/ogg`; родитель проверил /preview/1, 239787, 1802801 —
  HTTP 200). Прежний гейт принимал только MP3 и всегда писал `.mp3`.
  `MediaDownload.detectAudio` теперь определяет формат по payload (MP3: ID3/frame
  sync; Ogg: страница BOS с Vorbis identification header), не по URL/Content-Type.
  Opus/FLAC/видео в Ogg отклоняются. Политики trusted host/redirect/TLS и лимит
  24 MiB без изменений.
- `MediaAudioFormat` (`mp3`/`ogg`) проходит через `MediaCacheRepository` →
  `CachedAudio.format`; файл на диске получает суффикс по формату. Логический
  ключ аудио (pins, coalescing, downloads) не зависит от формата; старые
  `*.mp3` в кэше индексируются как раньше. Revision guard, pins, clear,
  128 MiB / 500 файлов сохранены; при смене контейнера устаревший соседний
  файл удаляется.
- **Inline-изображение** (`content_image.dart`): всегда intrinsic aspect,
  `BoxFit.contain`; авторские width/height — только максимумы, никогда выше
  intrinsic, ширины колонки и высоты экрана. Растяжение/upscaling убраны
  (консервативное решение: возможное намеренное HTML-искажение не воспроизводится).
- **Placeholder:** ограничены обе оси (авторский aspect зажат в 1:4…4:1, высота
  ≤ min(50% экрана, 320), min 48), индикатор 32 px в слоте; после декодирования
  действует исходное соотношение.
- **Decode:** целевой размер = экран × DPR (2× запас под viewer), не больше
  источника, long side ≤ 4096 (preview 1024) и ≤ 8 Мпикс; убрана пикселизация
  высоких картинок от фиксированных 2048.
- **Ranking row:** аватар центрируется относительно строки «позиция + ник +
  метрика»; флаги вынесены в отдельную полосу ниже (min 44 для team target),
  поэтому ник не оказывается выше аватара.
- Сохранены: controls-only `UiAudioPlayer`, skeleton news/article.

## Доказательства

- До коррекции родитель: `flutter analyze` — exit 0; iOS build — exit 0.
- Скриншот «до» — реальный экран Search на iPhone 17 simulator.
- Последующие реальные format/analyze/build и проверки симулятора описаны
  ниже в разделах continuation/correction и финальном checkpoint.

## Открыто

- Первоначальный iOS Vorbis blocker закрыт последующим одобренным локальным
  декодированием: точный preview873811 играет на существующем iPhone17,
  pause/seek/resume и MP3-контроль подтверждены в финальном parent checkpoint.
  Сам AVPlayer оригинальный Ogg напрямую по-прежнему не декодирует.
- Ручной GUI QA: ranking row (обычная/узкая/большой шрифт), inline-изображения
  (20×20 с width 300/height 100, 1×4096), skeleton, плеер на обложках.
- Тесты и Android APK по поручению не запускались.

## Continuation: загрузка команды и согласованные переходы skeleton

Статус: **awaiting_manual_check**, не verified. Тесты по поручению не запускались.

- **Team load (root cause).** `OsuPublicAuthorizationInterceptor._accepts`
  (`lib/src/_core/network/osu_public_authorization_interceptor.dart`) не имел
  пути teams, поэтому `GET /api/v2/teams/{id}[/{ruleset}]` падал `StateError` до
  сети. Добавлен только
  `^/api/v2/teams/[1-9][0-9]*(/(osu|taiko|fruits|mania))?$` (https, host
  `osu.ppy.sh`, GET). Авторизация/host/префиксы не ослаблены. Гипотезы про DTO
  (statistics, null leader) не трогались, дефолты не добавлялись.
- **Skeleton.** `UiPageSkeleton` теперь `StatefulWidget` с ОДНИМ контроллером на
  страницу и одним `FadeTransition` (пульс 1.0 → 0.55, `UiMotion.skeletonPulse`).
  Reduced motion (`MediaQuery.disableAnimationsOf`) — статичен; `TickerMode`
  глушит тикер штатно. `UiSkeleton` отдельно остаётся статичным.
- **Reveal.** Новые публичные `UiReveal` (FadeTransition) и `UiSliverReveal`
  (SliverFadeTransition) в `packages/tracksu_ui/lib/src/widgets/reveal.dart`:
  один fade при монтировании (`UiMotion.reveal` 220 мс, `easeOut`), далее
  refresh/pagination/смена режима не повторяют анимацию, пока позиция в дереве
  стабильна. Ленивые slivers остаются ленивыми; без AnimatedSwitcher, таймеров и
  искусственных задержек. Токены `UiMotion` добавлены в `tokens.dart`.
- **Применено:** news (список/статья), team, profile, rankings, beatmap,
  medals. Не тронуты (не просто): spotlights, profile scores/beatmaps секции,
  beatmap leaderboard.
- **Изображения.** `UiImage`: синхронный кадр показывается сразу, асинхронный
  проявляется `AnimatedOpacity` поверх цвета placeholder (reduced motion —
  без анимации). `ContentImageView.preview`: без начального spinner'а, цвет
  placeholder → `UiReveal` декодированного кадра; ошибка/retry сохранены.
  Жизненные циклы запросов и ограничение decode не менялись.
- **Аудио не затрагивалось:** нативный Vorbis на iOS 27 по-прежнему не
  воспроизводится, это открытый вопрос; успех аудио не заявляется.

Проверки разработчика: `fvm dart format` (13 файлов, exit 0), `fvm flutter
analyze --no-pub lib packages` — «No issues found!», exit 0. Не выполнялись:
тесты, сборка, симулятор.

Блокер: активный Xcode не содержит GUI `Simulator.app` (`open -a Simulator`
не работает); доступны только `simctl boot/launch/screenshot`, а к приложению
подключается websocket-отладчик Flutter.

### Correction1: правки по ревью

- `UiReveal`/`UiSliverReveal`: `didChangeDependencies` сначала проверяет reduced
  motion. Если он включён во время fade — контроллер сразу ставится в 1
  (анимация останавливается, opacity 1); последующее выключение reduced motion
  завершённую анимацию не повторяет. Reveal по-прежнему одноразовый, жизненный
  цикл тикера не менялся. Добавлен `alwaysIncludeSemantics: true`, чтобы
  начальная opacity 0 не скрывала семантику загруженного контента.
- `ContentImageView.preview`: Retry показывается только при `uri != null`; при
  `uri == null` — неинтерактивная иконка `broken_image_outlined`, как в inline.
- Замечание: на тёплом дисковом кэше повторное декодирование может снова
  проигрывать fade — допустимо; синхронный `UiImage` и так показывается сразу.

### Фактические проверки родителя

- `fvm flutter analyze --no-pub lib packages` — No issues found, exit 0.
- `fvm flutter build ios --simulator --debug --no-pub` — exit 0 (Runner.app).
- Установлено и запущено на существующем iPhone 17; через router debugger
  (websocket) открыты team1 («mom?», лидер peppy, участники) и team2 («test»,
  taiko, нулевая статистика): реальный API + DTO + рендер загружены, проверено
  живым скриншотом.
- `timeDilation = 5` и очищенный `PageCache`; запись:
  `/Users/aleksandrpavlenko/.hermes/cache/scratch/tracksu-team-cold-slow.mov`.
- Ограничения: нативный GUI недоступен, навигация отладочная, не физические
  тапы; оценка видео движения ещё идёт, не все пути проверены. Аудио iOS
  (нативный Vorbis) не решено. Тесты не запускались.

### Correction2: прозрачность `UiImage`

- Регрессия (подтверждена ревью): асинхронный `UiImage` оставлял постоянный
  серый `ColoredBox` под прозрачным PNG, синхронный кэшированный — нет.
- Исправление (`packages/tracksu_ui/lib/src/widgets/media.dart`): после первого
  непустого кадра слой placeholder (простой цвет) гаснет, а изображение
  проявляется — два `AnimatedOpacity` в `Stack(fit: expand)` внутри уже
  ограниченного `SizedBox`. Постоянной серой подложки нет. Reduced motion:
  сразу финальный child (или серый цвет, пока кадра нет); переключение в
  процессе обходит fade. Синхронный кадр — без изменений, errorBuilder,
  `ResizeImage` (fit, лимит 2048) и размеры не менялись.
- Дополнительные живые проверки родителя (реальное приложение): team1 («mom?»)
  и team2 («test») загружены; холодный `PageCache` очищен, `mediaCache` очищен
  с ожиданием до `sizeBytes == 0`; `timeDilation = 5`; статья 1957
  («New Featured Artist: Nyxtoria») загружена с реальным API и изображением
  после очистки. Записи в scratch: `tracksu-team-cold-slow.mov`,
  `tracksu-news-cold-slow.mov`; контактные листы показывают skeleton, затем
  растущую opacity контента.
- Не доказано: frame-time/производительность, физические тапы, системный
  переключатель Reduce Motion вживую. Аудио в реальном приложении дало ошибку
  декодера -11800 — не решено.
- Разработчик: после правки запущены только format/analyze; финальные проверки
  родителя приведены ниже.

### Checkpoint родителя — 2026-10-02

- После correction2: `fvm flutter analyze --no-pub lib packages` — No issues
  found, exit 0; `git diff --check` — exit 0;
  `fvm flutter build ios --simulator --debug --no-pub` — exit 0, Runner.app.
- Последняя сборка установлена и запущена на прежнем iPhone 17. По реальным
  запросам команды 2 переключены osu/taiko/fruits/mania: каждый результат
  `TeamLoaded`, `refreshing=false`, `failure=null`. Для команды 1 через
  существующий `TracksuAppRouter.openTeam` подтверждена identity `1:mom?`.
- Холодная загрузка команды и статьи записана с Flutter timeDilation=5;
  записи и контактные листы просмотрены. Видны skeleton и нарастающая opacity
  данных, у статьи также реальное изображение. Это не измерение frame-time
  и не гарантия отсутствия jank на всех устройствах. Скорость возвращена к 1.
- Финальная запись команды через facade: scratch
  `tracksu-final-team-cold-slow.mov`; статья последней сборки:
  `tracksu-final-cold-slow.mov` (командная часть этой записи не является
  проверкой cold-load: прямой debugger go между id сохранил старый detail;
  повторная проверка выполнена после ухода на Search через facade).
- Физических GUI-тапов не было: Simulator.app отсутствует, использованы
  Flutter attach/DDS WebSocket и simctl. Системный Reduce Motion вживую
  не переключался. Автотесты и Android APK не запускались, коммита нет.
- После двух correction-циклов свежий reviewer выявил остаточные находки:
  1. В rankings `SliverPadding(list)` без ключа может размонтироваться при
     одновременном добавлении refresh-индикатора и исчезновении autoLoad.
     Структура была такой до добавления reveal; исправление — стабильный
     ключ списка, отдельный следующий срез. Не заявлять все refresh-paths
     проверенными/без сохранённого долга.
  2. В `ContentImageView` при смене URI на null ранний return не обнуляет
     `_request`; старый уже декодируемый кадр может пройти identity guard.
     Нужна отдельная адресная correction; не расширяем завершённые два цикла.
- iOS-превью Ogg/Vorbis остаются BLOCKED: проверенный файл не открывается
  AVAudioFile/AVURLAsset, живое приложение выдаёт decoder -11800. Cache suffix
  сам по себе проблему не решает. Пользователь отклонил новый аудиобэкенд;
  зависимости не менять. Это не означает, что все аудиоисточники сломаны:
  дополнительная реальная проверка ниже отделяет MP3 от Vorbis.
  Полный P29 не принят и остаётся awaiting_manual_check.

### Новый обязательный debug-сценарий: изображения lifeline — 2026-10-02

- Пользователь приложил screenshot: в описании lifeline две картинки дают
  общий `contentImageFailed` и Retry. Это не доказательство неподдерживаемого
  формата; нужно установить конкретный источник и этап сбоя.
- Обязательный scope: реальный профиль lifeline (11367222), исходные HTML
  src, HTTP/redirect/DNS/TLS, лимиты файла/размера, сигнатура и Flutter decode,
  cache и lifecycle request identity. Не ослаблять SSRF/TLS/redirect-политику
  и не добавлять зависимости без отдельного решения.
- Первое изображение из публичного HTML: i.ppy.sh, HTTP200, image/png,
  2693906 bytes,960×1780; формат PNG уже есть в allowlist. Это самостоятельная
  транспортная проба, а не доказательство работы app pipeline.
- Добавлено в ручной simulator QA: reproduce → адресное исправление →
  проверка холодной загрузки/Retry/прокрутки того же профиля.
- Итог parent QA (2026-10-02): **клиентская обработка исправлена и проверена;
  исходные две картинки остаются upstream-unavailable**. На финальной сборке
  существующего iPhone17 обе реальные ContentImageView имеют
  `_ImageFault.unavailable`, retry=false, intrinsic=null; steady screenshot
  показывает компактные карточки с конкретным сообщением об источнике и без
  бессмысленного Retry/общего предположения о формате.
- Контроль здоровой PNG того же профиля: адресно удалена только её cache entry,
  readback перед запросом false; после загрузки true, live decode960×1780,
  intrinsic960×1780, fault=null. Это cold-fetch/decode-проверка, не claim полного
  offline/cache-render/всех форматов или FPS. Не очищались auth/другие media.
- HTTP404 подтверждён на обеих i.ppy.sh картинках, их cdn.discordapp.com
  originals и с browser User-Agent/Referer. Published ex expiry2024-07-17;
  это не доказательство удаления файлов. Нужны новые рабочие исходные ссылки
  или повторная загрузка автором профиля; клиент отсутствующие bytes не создаёт.
- Parent final checks после correction2: format/analyzer/diff-check и
  simulator build; analyzer `No issues found!`(2.7s), Xcode13.3s, exit0;
  final Runner.app установлен, latest appPID64910. Owned debugger остановлен,
  capabilities не записывались в reports. Автотесты запрещены/не запускались.
- Final reviewer217ba3405cee453ca7254de600eb27ca: нет critical/high внутри
  этого исправления; medium в другом avatar/cover provider `app_media.dart`
  (ещё теряет typed cause) записан отдельно, не исправлен новым scope.
  Low: opaque native descriptor Exceptions, wording других HTTP/TLS случаев,
  rare eviction races, VoiceOver/preview не проверены. Два correction-цикла,
  дальнейшего бесконечного repair-loop нет; общий P29 awaiting_manual_check.
- Доказательства: scratch `tracksu-lifeline-image-findings.md` и
  `tracksu-lifeline-final-errors-steady.png`. Поздние screenshots другого tab
  не выдаются за proof здорового About-photo; подтверждение PNG — live metadata.

### Точный пользовательский audio-repro: preview873811 — 2026-10-02

- Пользователь: `data-audio-url="https://b.ppy.sh/preview/873811.mp3"`,
  screenshot карточки quaver/dj TAKA/Fiery’s Extra с общей ошибкой playback.
  Сохранять URL/ID дословно, не подменять этот источник working MP3-контролем.
- GET: HTTP200, Content-Type audio/ogg,102823bytes; `file` определяет
  Ogg Vorbis,stereo44100Hz. Суффикс `.mp3` не соответствует содержимому.
- Native probe на существующем iPhone17: directURL AVURLAsset.playable=false;
  те же bytes с правильным локальным суффиксом `.ogg`: AVAudioFile
  com.apple.coreaudio.avfaudio code1685348671, AVURLAsset.playable=false.
  Значит ни downloadуспех, ни исправление расширения не доказывают playback.
- `ffprobe` отсутствует в доступном PATH; не объявлять его проверку успешной.
  Container/codec-проверка здесь основана на `file` и реальном nativeprobe.
- Текст «Проверьте соединение» на screenshot не отражает подтверждённый
  codec/container blocker этого источника. В controller причиной logged failure
  и decoder stage уже разделены, но UI пока generic; отдельный follow-up
  typed error → корректный user message. Это НЕ исправление самого playback.
- Новый backend/decoder не добавлялся (пользователь отказал); восстановление
  старого working сценария требует подтверждения платформы старого приложения.
  Same-source live app playback и native AVPlayer success НЕ заявляются.

### Сравнение старого аудиопути — 2026-10-02

- Git `c52f495^`: `BeatmapPlayCubit` вызывал audioplayers
  `play(UrlSource(...))`, без собственного скачивания в этом контроллере.
  В этом дереве iOS-target отсутствует; фактическую платформу старого
  рабочего приложения ещё нужно уточнить, а не считать iOS доказанным.
- Прямая потоковая загрузка `b.ppy.sh/preview/1.mp3` через AVURLAsset на
  существующем симуляторе также дала `playable=false`; обход кэша не доказан
  как исправление. Accept `audio/mpeg` для preview239787 всё равно вернул
  Ogg/Vorbis (HTTP200, audio/ogg).
- Настоящий MP3 `assets.ppy.sh/artists/1/previews/518.mp3` скачан с официального
  источника: HTTP200, audio/mpeg. Нативный диагностический запуск декодировал
  PCM, AVPlayer показал position=3.6795s/rate=1.
- Через реальный общий `AudioPlaybackController.play` установленной сборки
  этот же MP3 скачан, закэширован и воспроизводился: `phase=playing`,
  `position=9503ms`, `duration=60000ms`, `nativePlaying=true`,
  `nativeState=ready`, `cache=true`. Это manual debugger invocation, не GUI-тап.
- Тем же контроллером preview239787 вернул `failed`, position=0; в live attach
  логах decoder -11800. Воспроизведение остановлено, attach закрыт.
- Новый бэкенд/зависимости/production-код не добавлены. Независимый read-only
  reviewer-deep выполнен через pavlenko-agent-team, exit0; сам проверок не
  запускал и файл отчёта из-за read-only роли не создал. Evidence родителя:
  scratch `tracksu-legacy-audio-findings.md`.

### Реализация: изображения lifeline — 2026-10-02

Причина по доказательствам родителя: две карточки — не декодер и не формат.
src `i.ppy.sh/da67fe48…`, `/74289613…` и исходный `cdn.discordapp.com` отдают
HTTP404 (`text/plain`, подписанные ссылки истекли 2024-07-17). Приложение
показывало общий текст «формат/размер» и Retry. Восстановление upstream-404
не заявляется; исправлено только поведение клиента.

- `ContentMediaLoader`: сохраняет типизированный `MediaDownloadFailure`
  (reason/status); `TimeoutException`→timeout, `SocketException`/`TlsException`/
  `HttpException`→connection, остальное — прежний default. Отмена запроса теперь
  `cancelled`. URL/хост/заголовки/платформенный текст не выходят из границы.
- `ContentImageView`: приватный `_ImageFault` (unavailable 404/410, blocked и
  null-адрес, unsupportedFormat, tooLarge, network 408/429/5xx/connection/
  timeout, unknown). Retry только для network/unknown. Сообщение зависит от
  вида сбоя; unknown сохраняет прежний `contentImageFailed`.
- Ошибка inline компактна (иконка вместо авторского/16:9-плейсхолдера);
  layout загруженного растра (downscale-only) не тронут. Превью остаётся
  ограниченным 16:9, без нерабочего Retry для терминальных сбоев; иконка с
  Semantics-сообщением.
- Request identity: `_load` сначала отменяет и обнуляет старый запрос и
  сбрасывает ошибку, затем ветка null-URI; устаревшие результаты/ошибки не
  применяются (guard `_request == request`). Кэш вытесняется только при
  фактической ошибке декодирования полученного растра и только для URI этого
  запроса; сетевой 404 и лимит размера кэш не трогают.
- l10n: 4 ключа (`contentImageUnavailable/Network/Format/TooLarge`) во всех 7
  ARB, `fvm flutter gen-l10n`. Форматы, лимиты 64/40Mpx/16MiB, DNS/TLS/SSRF/
  redirect и аудио не менялись.
- Проверки: `fvm dart format` (изменённые), `gen-l10n`, `fvm flutter analyze
  --no-pub lib packages` — без замечаний, `git diff --check` — чисто.
  Реальная simulator-проверка и независимое ревью — за родителем.
  P29 в целом остаётся awaiting_manual_check; аудио и прочие находки открыты.

#### Lifeline images — correction 1 (2026-10-02)

- Классификация декодирования сужена: `corrupt` выставляется только если сам
  `ImageDescriptor.encoded` отклонил полученные байты (rethrow из этой стадии).
  Аллокация `ImmutableBuffer`, `instantiateCodec`, `getNextFrame`, масштаб и
  контекст больше не считаются порчей: это `unknown` (Retry), кэш сохраняется.
  Предел: публичный API Flutter не даёт типизированной ошибки порчи данных,
  стадия `encoded` — единственное (косвенное) свидетельство; сообщения платформы
  не разбираются и не логируются. `invalidFormat` из транспорта и `tooLarge`
  остаются терминальными.
- `ContentMediaLoader.load`: закрытый загрузчик или `repository == null` теперь
  даёт `blocked` (терминально, без Retry) вместо `cancelled`; активная отмена
  запросов в полёте (`cancel`/`close()`) по-прежнему `cancelled`, guards
  идентичности запроса не менялись.
- Превью с retryable-сбоем: Retry обёрнут в `Semantics(label: fault.message)`;
  видимый текст и размеры успешного изображения не менялись.
- Не заявляется восстановление исходных изображений (HTTP404 остаётся
  unavailable/noRetry/compact). Транспорт, парсер, лимиты и форматы не менялись.
- Проверки: format (0 changed), `analyze --no-pub lib packages` — без замечаний,
  `git diff --check` — чисто.

#### Lifeline images — correction 2 (2026-10-02)

- `ContentMediaSuspended` (content-local, без URL): закрытый/без repository
  `ContentMediaLoader` и `close()` активных запросов завершают запрос этим
  исходом (приватный `ContentMediaRequest._fail`). Обычный `cancel()` для
  замещённого/disposed запроса остаётся `cancelled`, идемпотентно.
  `MediaFailureReason` и аудио не менялись.
- `_ImageFault.suspended` (не retryable, компактно, без Retry): новый ключ
  `contentImagePaused` ("Image loading is paused.") во всех 7 ARB, `gen-l10n`.
  Автоматический reload при новом loader (didUpdateWidget) сохранён; валидное
  декодированное изображение переживает inactive-состояния.
- Эвристика порчи на стадии `ImageDescriptor.encoded` ловит только `Exception`;
  `Error` (OOM/StateError/TypeError) -> unknown/Retry, кэш сохраняется. Предел:
  непрозрачный нативный `Exception` по-прежнему считается порчей по стадии;
  строки не разбираются, типизированной ошибки движка нет.
- 404/410, invalidFormat, tooLarge, downscale/cache и URI-null guards не менялись.

### iOS Ogg/Vorbis: одобренный декодер — 2026-10-02

Статус: **awaiting_manual_check**. Пользователь явно одобрил: «Да, добавь
поддержку Ogg/Vorbis и проверь этот файл на iPhone 17». Это заменяет прежний
отказ от нового аудиобэкенда/зависимостей выше. just_audio, контроллер, UI и
контракт `CachedAudio` (path/format/release pin) не менялись.

- **Зависимость:** `audio_decode: 1.3.5` (точная версия; MIT, Yusuf Ihsan
  Gorgel). Build hook (`hooks`/`native_toolchain_c`; в lock добавлены
  `native_toolchain_c` 0.19.4 и `process` 5.0.6) компилирует vendored
  stb_vorbis v1.22 (MIT или Unlicense) и minimp3 (CC0) в
  `audio_decode.framework`; `@Native` резолвится через Flutter native assets.
  Pod/plugin/правки `ios/` не нужны. Альтернативы: `audio_decoder` использует
  платформенные кодеки (Vorbis на iOS нет), SoLoud/FFmpeg — несоразмерный
  второй player stack.
- **Лицензии:** MIT LICENSE пакета Flutter собирает сам; он не воспроизводит
  тексты кодеков, поэтому `assets/licenses/audio_decode_codecs.txt` (тексты из
  исходников stb_vorbis.c/minimp3.h) зарегистрирован в `register_licenses.dart`
  → About → Licenses.
- **Модель:** `MediaAudioFormat {mp3, ogg}` — только принятые сетевые payload.
  Приватный `_AudioFile {wav, mp3, ogg}` — дисковые контейнеры; WAV пишет только
  локальный декодер, скачанный WAV по-прежнему отклоняется `detectAudio`.
  iOS (`Platform.isIOS`): Ogg → `vorbisToWav` → `<hash>.wav`; MP3 и Ogg на
  других платформах — прежний нативный путь.
- **Upgrade кэша:** найденные `.mp3`/`.ogg` классифицируются по первым 512 байтам
  (`detectAudio`), не по суффиксу; неопознанные удаляются и скачиваются заново.
  Ogg на iOS (включая legacy `.mp3` с Ogg внутри) читается с диска и
  декодируется; WAV заменяет исходник (соседние контейнеры удаляются). Учёт
  байтов, pins, expiry 7 дней, 500 записей/128 MiB, `.part`-cleanup, coalescing
  и revision guard прежние; regex индексации дополнен `wav`.
- **Preflight до native decode** (`vorbis_wav.dart`, не парсер-фреймворк): весь
  файл — страницы `OggS` v0 без хвоста; один serial, без повторного BOS
  (chained/multiplexed отклоняются), sequence подряд, флаг continuation строго
  соответствует незавершённому пакету, EOS на последней странице, последний
  пакет завершён. Identification-пакет один на странице 0 (lace 30, как требует
  stb): version 0, каналы 1..2, 8000..48000 Гц, block exponents 6..13,
  log0 ≤ log1, framing; comment/setup начинаются с типа 3/5 + `vorbis`.
  Лимиты: encoded ≤ 24 MiB (`MediaDownload.maxAudioBytes`), granule EOS
  ≤ 45 с, PCM bound = аудиопакеты × ¾·blocksize_1 × каналы × 2 ≤ 16 MiB.
  Обоснование ¾: stb `vorbis_finish_frame` возвращает right−left, left ≥ 0,
  right ≤ (3·n − blocksize_0)/4 (`vorbis_decode_initial`) — и при поддельных
  prev/next флагах. После decode: каналы/частота совпадают с заголовком,
  фактические PCM bytes ≤ bound, иначе `invalidFormat`. Фактическая длительность
  проверяется после decode: принимается только результат ≤ 45 с. Поддельный
  granule может заставить декодировать больше 45 с до отказа; жёсткий pre-decode
  лимит относится к PCM bytes, а не к времени CPU/длительности. Превышение
  лимитов — `tooLarge`.
- **Выполнение:** `compute` (фоновый isolate), ровно один decode одновременно
  (цепочка `_decoding`); revision/closed/clearing check перед стартом и после.
  Isolate не убивается во время синхронного FFI; `clear()` дожидается его через
  `_pending`, `dispose()` не ждёт, но результат отбрасывается. Файлы пишет только
  главный isolate внутри `_serial` после check. Нет диска или запись не удалась —
  для Vorbis на iOS `MediaDownloadFailure` (стрим URL всё равно не играет), а
  не ложный успех. Ошибки — только категории, без URL.
- **Реальный файл:** read-only разбор scratch `tracksu-preview-873811.ogg`
  (байты `https://b.ppy.sh/preview/873811.mp3`): 102823 bytes, 12 страниц,
  1 serial, 537 пакетов (534 аудио), 2 ch/44100 Hz, log 8/11, granule 445410
  (10,1 с); bound 3,28 МБ при факте ≈1,78 МБ — preflight проходит.

Проверки разработчика (exit 0): `fvm flutter pub get`; `fvm dart format`
изменённых Dart-файлов; `fvm flutter analyze --no-pub lib packages` — No issues
found; `fvm flutter build ios --simulator --debug --no-pub` — Runner.app,
внутри `audio_decode.framework`, `NativeAssetsManifest.json` с
`package:audio_decode/src/bindings.dart` для ios_arm64/ios_x64, notice-asset
в bundle; `git diff --check`.

Остаточные риски / не проверено:
- Разработчик не заявлял playback при handoff; последующая parent-проверка
  ниже подтверждает реальное воспроизведение 873811 и MP3-контроль518.
- Аллокации setup-header (codebooks) внутри `stb_vorbis_open_memory` ограничены
  только внутренними проверками stb и размером входа, не нашим bound; вход —
  только trusted ppy.sh. Пиковая нативная память decode ≈ 3×PCM (рост
  удвоением) + копия входа, плюс Dart-копии PCM и WAV.
- Bound консервативен: поток с большой долей коротких блоков может быть
  отклонён раньше 45 с (для превью ~10 с запас ≈5×).
- `lib/src/_core/config/pubspec.yaml.g.dart` не регенерирован (build_runner
  запускает envied над `.env`); в runtime используется только `Pubspec.version`.
- Android/APK, автотесты, физическое устройство — не выполнялись по поручению.

#### Ogg/Vorbis — correction 1 и фактические проверки оркестратора

Статус: **awaiting_manual_check**. Свежий reviewer-deep подтвердил обход PCM
bound через страницы с нулём сегментов: stb оставляет старую lacing table.
Исправлено до native call: `segments == 0` отклоняется. Дополнительно проверяются
положительное число кадров и фактический предел 45 с после decode. Четыре
слота теперь охватывают весь payload lifetime (cached read/download → очередь
decode → atomic write), а не только транспорт. Cached Ogg читается через
открытый `RandomAccessFile` с проверкой длины ≤ 24 MiB до аллокации и закрытием
в `finally`; oversized/unreadable payload скачивается заново.

Claude developer-deep внёс эту correction, затем достиг session limit (exit 1).
Это сбой доступности CLI, не сборки. Настроенный Codex verifier `gpt-5.6-high`
тоже вернул exit 1: HTTP400, модель не поддерживается ChatGPT account.
Глобальная конфигурация/авторизация не менялись. Свежий независимый review
выполнен с invocation-only `gpt-6-sol` через установленный team prepare,
четыре Flutter skills и **read-only sandbox**, exit 0. Отдельных регрессий
MP3, legacy Ogg, slots, pins и stale-write guards не найдено. Его замечание
про 45 с принято как уточнение политики: это post-decode acceptance limit,
а pre-decode packet bound — 16 MiB. Это не гарантия hard CPU timeout или
полностью ограниченного codebook allocator.

Проверки оркестратора после correction (все exit 0):
- `fvm dart format` четырёх изменённых handwritten Dart-файлов —
  Formatted 4 files (0 changed), 0.03 s;
- `fvm flutter analyze --no-pub lib packages` — No issues found!, 3.9 s;
- `git diff --check` — без вывода;
- `fvm flutter build ios --simulator --debug --no-pub` — Xcode 11.3 s,
  `build/ios/iphonesimulator/Runner.app`.

Native framework подтверждён: simulator arm64/x86_64, min iOS 15.0,
SDK 27.0; host minimum также 15.0. Manifest содержит правильный @Native asset
ID, notice asset упакован. Это не проверка вызова декодера/звука в живом app.

Артефакт:
`/Users/aleksandrpavlenko/Projects/tracksu/build/ios/iphonesimulator/Runner.app`.
Отчёт/точные логи:
`/Users/aleksandrpavlenko/.hermes/cache/scratch/tracksu-ogg-correction1-report.md`,
`tracksu-ogg-correction1-{format,analyze,diff-check,build}.log` в той же scratch.
Независимое review:
`/Users/aleksandrpavlenko/.hermes/cache/scratch/tracksu-ogg-codex-final-review-report.md`.
После уточнения документации выполнен ещё один свежий read-only audit
(`gpt-6-sol`, exit 0): дополнительных critical/high/medium находок нет;
замечание о duration limit закрыто точным описанием pre/post-decode политики.
Отчёт: `/Users/aleksandrpavlenko/.hermes/cache/scratch/tracksu-ogg-final-audit-report.md`.
Сверка исходного baseline: 36 посторонних tracked diffs идентичны,
неожиданных новых tracked diffs вне scope нет.
Один correction-цикл; автотестов/harness, Android/device/signing, регенерации
ios, очистки auth, commit/push/deploy не было.

#### Parent live playback подтверждён — 2026-10-02

Последний Runner.app установлен на существующий iPhone17
7150350D-89C4-44A6-AE44-146571C269DE (appPID3189,VMport55241).
Реальная обработка preview873811: скачанные/закэшированные Ogg bytes →
локальная WAV → существующий just_audio, без подмены source.

- Native state ready/playingtrue, position503→3253ms,duration10100ms.
- Pause:3552ms; после ожидания остаётся3552ms. Seek paused на1000ms и
  resume:playing3252ms. Повторный playback использует тот же WAV cache.
- MP3-контроль518:playing752→3252ms,duration60000ms,исходный.mp3путь.
- Проверена исходная карточка **quaver/djTAKA/Fiery’sExtra** в Maps профиля
  lifeline: вызван реальный Play с её owner token; owns(owner)=true,
  playing1013→4763ms,Duration10100ms,нативный ready/playingtrue.
  Screenshot показывает Pause/прогресс без старой красной ошибки;
  затем preview завершилось штатно на10100ms.
- Реальный WAV переданный плееру:PCM16,stereo44100Hz,445410frames,
  ненулевой сигнал. Это не dummy-файл. Использован live debugger над
  настоящими API/UI callbacks; physical tap/субъективное прослушивание и
  акустическая запись simctl video не заявляются.
- Parent format4files0changed,analyzer No issues found!(2.7s),diffcheck — exit0.
  После QA stop()→idle,position0,playernull; owned debugger отключён,
  app оставлен установленным. Auth/остальной cache не очищались.
- Доказательства в scratch: `tracksu-ogg-parent-playback-report.md`,
  `tracksu-ogg-live-observations.json`, `tracksu-ogg-quaver-playing.png`,
  `tracksu-ogg-quaver-playing.mov` (визуальный прогресс, не audio recording).

**Блокер воспроизведения именно873811 исправлен и проверен на симуляторе.**
Общий P29 остаётся awaiting_manual_check: приёмка пользователем/другие UI
сценарии открыты. Ограничения PCM/длительности, native setup allocations и
отсутствие hardFFItimeout остаются документированными; allOggcodecs не обещаны.

#### Rankings: сохранение списка при refresh

Исправление внесено в `bb677d1`: постоянная `ValueKey<String>('rankings-list')`
на прямом list-owning `SliverPadding` в `rankings_section.dart`.
Одновременное добавление leading refresh sliver и удаление trailing auto-load
больше не должно пересоздавать родительский список из-за positional reconciliation.
Ключи отдельных строк ранее не защищали от удаления их родителя.

Гарантия ограничена loaded-поддеревом. Сохранение каждой lazy row при выходе
за viewport/cache extent, перестановке данных или Loaded→Loading/Failure
не гарантируется. Row identity ожидается для того же id на том же индексе.

Проверки pinned Flutter3.47.5:
- format:1file,0changed;
- parent analyzer:No issues found!(1.4s);
- diff-check:exit0;
- simulator debug build:exit0,Xcode15.1s;
- независимый review:critical/high/medium findings нет.

Инструментальная before/after проверка настоящего refresh сохранила sampled
list element/render и первую видимую строку с тем же id/индексом. Переходный
кадр во время refresh не измерен. Это частичное свидетельство, не GUI-приёмка.
Приложение установлено на отдельное iOS27.0 устройство; экран Search отображается.

Статус среза rankings: **done по решению пользователя** — исправление
`bb677d1` принято, дальнейшая GUI-проверка этого среза остановлена.
Прокрутка вниз/вверх и отображение строк второй страницы подтверждены через
Device Hub на выделенном Tracksu iPhone 17. Активные переходы refresh/pagination,
failed refresh/Retry и filter cache hit/miss не подтверждены; решение закрыть
срез не означает, что эти проверки пройдены. Общий P29 этим не закрывается.

#### Навигация, языки, media — 2026-10-02

Статус: **implemented + automated verified / awaiting_manual_check**.
GUI-приёмка не выполнялась; PASS не заявляется.

- Media (`app_media.dart`): исправные disk bytes больше не удаляются при
  ошибке декодера. Opaque Exception/Error codec/engine не доказывает порчу
  (download уже проверяет сигнатуру), поэтому → `unavailable`; превышение
  размеров → `tooLarge`; upstream `MediaDownloadFailure` (reason/status)
  пробрасывается без изменений с исходным stack trace. Сообщения платформы и
  URL в UI не попадают.
- Языки: в picker и в текущей настройке — автонимы (English, Русский, Deutsch,
  Français, Español, 日本語, 中文); «System» локализуется. Коды, порядок и
  persistence не менялись.
- `UiScrollToTop` (tracksu_ui): видимость вычисляется один раз за кадр из
  актуального состояния своего controller (не из устаревших notifications),
  корректно при замене длинного контента коротким и resize. Подключён к
  Поиску, Рейтингам (owned controller), Spotlights, Новостям/статье, карте и
  leaderboard, медалям, команде и каждой секции профиля (свой controller).
  Main scrollables с `primary: true` явно — на desktop route controller
  не наследуется автоматически.
- Reselect активной вкладки → прокрутка root к началу (см. NAVIGATION_SPEC);
  отложенный запрос отбрасывается, если вкладка уже сменилась.

Автотесты (новые): `test/src/_shared/media/widgets/app_media_test.dart`
(реальный `MediaCacheRepository` с mock cache dir: healthy PNG, decoder
Exception/Error без eviction, tooLarge, upstream identity),
`test/src/_shared/preferences/language_picker_test.dart`,
`test/tracksu_ui/widgets/scroll_to_top_test.dart`,
`test/src/guest/widgets/guest_shell_test.dart` (реальный GoRouter
StatefulShellRoute + GuestShell). Шаблонный `test/widget_test.dart` (counter)
падает независимо от этого среза.

Открыто для GUI: retap вкладки на root и с деталей; сохранение scroll другой
вкладки; появление/скрытие кнопки и отсутствие перекрытия navbar/player/safe
area; reduced motion; tooltip в семи языках; автонимы в picker/настройках;
ошибка аватара/обложки без потери кэша.
