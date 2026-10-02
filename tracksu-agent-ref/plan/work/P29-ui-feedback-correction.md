# P29 — коррекция UI-обратной связи: аудио, изображения, ranking, skeleton

2026-10-02 · implemented in code / awaiting_manual_check.

## План локальных checkpoint-коммитов

Пользователь разрешил небольшие локальные коммиты проверенных исправлений;
прежний no-commit снят только для этих шагов. Push/deploy и существующий
untracked `ios/` исключены. Наличие коммита не означает пользовательскую приёмку.

- C1: public team endpoint allowlist и относящаяся документация.
- C2: общий skeleton/reveal/image fade, controls-only player, ranking UI и
  необходимые consumers; изменения shared API и consumers атомарны.
- C3: content image sizing/typed failures/lifecycle + locales, безопасная
  диагностика аудио и распознавание payload. Media data берётся из сохранённого
  проверенного pre-Ogg снимка; iOS Vorbis на этом checkpoint ещё ограничение.
- C4: iOS Vorbis→WAV, native decoder/dependency/license/cache integration,
  фактический playback873811 и MP3-контроль, финальные docs и lockfile.

Следующий отдельный срез: стабильная identity списка rankings при refresh.
URI→null image guard уже исправлен; историческую находку не исправлять повторно.

Локальные checkpoints на ветке `dev`, автор/committer проверены:
- `01f65e5` — public team endpoints.
- `f97bb56` — shared UI transitions и consumers.
- `f27ea82` — image failures/intrinsic sizing и pre-Ogg media snapshot.
- C4 Vorbis/dependency/licenses — атомарный commit финального снимка; его hash
  записывается в отдельный handoff после создания, без self-hash/amend цикла.

Каждый checkpoint содержит относящийся CHANGELOG и версию этой work card;
промежуточные документы не заявляют ещё не внесённый iOS decoder. Все source
bytes рабочего дерева сохранены при staged/index-only разбиении. `ios/` не staged.

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

#### Rankings: стабильная идентичность списка — исправление в коде

Статус: **awaiting_manual_check**. Исправление подтверждено чтением pinned
reconciliation source и техническими проверками; live identity ещё не измерена.

Граница: `lib/src/rankings/widgets/rankings_section.dart`, загруженная ветка
`SliverMainAxisGroup`. Дочерние элементы группы синхронизируются позиционно
(`MultiChildRenderObjectElement` → `Element.updateChildren`, pinned SDK 3.47.5,
`framework.dart` 4138–4320; `SliverMainAxisGroup` — обычный
`MultiChildRenderObjectWidget`, без своей diff-логики).

Разбор по исходникам, старый `[SliverPadding(list), UiSliverAutoLoad, footer]` →
новый `[refresh SliverToBoxAdapter, SliverPadding(list), footer]`:
- head: `SliverPadding` vs `SliverToBoxAdapter` — `canUpdate` false, остановка;
- suffix: footer `SliverToBoxAdapter` совпадает; затем `UiSliverAutoLoad` vs
  `SliverPadding` — не совпадает;
- middle: старые `SliverPadding` и `UiSliverAutoLoad` без key попадают в
  `deactivateChild`, хотя у строк внутри есть `ValueKey<int>(id)`: ключи строк
  не спасают, т.к. их родитель-список уничтожен.

Исправление: одна константная `ValueKey<String>('rankings-list')` на
`SliverPadding` — прямом потомке loaded-группы. Не на `UiSliverCardList`/строке,
без зависимости от state/query, без новых обёрток. С ключом старый элемент
попадает в `oldKeyedChildren` и находится по key в middle; обратный переход
(refresh-sliver исчез) разбирается так же.

Ручная проверка (parent, ещё не выполнена):
1. Parent устанавливает новый artifact только на существующий iPhone17
   `7150350D-89C4-44A6-AE44-146571C269DE` и открывает Rankings. Этот worker
   не устанавливал/не перезапускал app; уже установленная версия не содержит fix.
2. Дождаться loaded с `items.isNotEmpty`, `nextPage != null`, `operation == null`,
   `failure == null`; auto-load должен быть mounted, но ещё не trigger. Снять
   identity реального `SliverPadding` с key `rankings-list`, его render object,
   дочернего `RenderSliverList` и одной видимой неизменной строки через live
   debugger/Inspector (не сохранять service capability URL).
3. Нажать видимую кнопку Refresh либо вызвать настоящий
   `RankingsRefreshRequested` через найденный живой Bloc, если кнопка вне экрана.
   Не emit fabricated states. Во время refresh одновременно добавляется leading
   progress и исчезает auto-load. Сверить те же element/render identities,
   отсутствие повторного cold reveal/перезагрузки аватара у сохранённой строки.
   Offset не должен сбрасываться в ноль; добавление progress меняет геометрию,
   поэтому абсолютная неподвижность строки на экране не обещается.
4. После настоящего success сверить обратный переход, затем обычную pagination.
   Для error/Retry повторить refresh при временной недоступности сети, восстановить
   сеть и Retry; не очищать auth/cache. Row identity ожидается только для того же
   id на том же индексе: внешний Padding в UiSliverCardList не keyed, поэтому
   перестановка данных может пересоздать карточку. Это не расширяется данным fix.
5. Проверить прежнее поведение смены фильтра/страны/типа: cache hit даёт
   Loaded(refresh) с другими items, cache miss — Loading и новый cold reveal.
   Сохранение дерева между Loaded и Loading/Failure не гарантируется этим fix.

Проверки оркестратора (pinned Flutter 3.47.5, все команды exit 0):
- `fvm dart format lib/src/rankings/widgets/rankings_section.dart` —
  Formatted 1 file (0 changed), 0.03 s;
- `fvm dart format --output=none --set-exit-if-changed
  lib/src/rankings/widgets/rankings_section.dart` — 1 file (0 changed), 0.02 s;
- `fvm flutter analyze --no-pub lib packages` — No issues found!, 2.6 s;
- `git diff --check` — без вывода;
- `fvm flutter build ios --simulator --debug --no-pub` — Xcode 15.1 s,
  `build/ios/iphonesimulator/Runner.app`.

Artifact: `/Users/aleksandrpavlenko/Projects/tracksu/build/ios/iphonesimulator/Runner.app`.
Developer team CLI (Claude Sonnet) завершился exit 0; команды с compound Bash
получили permission denial, worker использовал разрешённые Read/Edit/Write без
обхода approvals. Автотесты/harness/Android/device/signing не выполнялись.
Commit/push/deploy, staging и установка app не выполнялись; untracked `ios/`
не регенерировался/не удалялся. Build — только разрешённый simulator build.
Технические проверки не доказывают live element identity; общий P29 остаётся
awaiting_manual_check.

Свежий независимый read-only team reviewer (Claude Sonnet, exit 0, четыре
Flutter skills) подтвердил правильную границу ключа и forward/reverse переходы
по pinned SDK. Critical/high/medium находок нет. Два low-уточнения docs закрыты:
row identity только при том же id/индексе; cache hit Loaded(refresh) отличается
от cache miss Loading. Финальный свежий read-only audit exit 0 подтвердил
уточнения и отсутствие blocking findings; информационные замечания — краткий
комментарий и отсутствие запрещённого regression test. Первый reviewer не мог
запустить git diff (tools только Read/Grep/Glob); финальному передан точный
orchestrator-captured diff, проверены текущие исходники. Финальный reviewer не
перечитывал PLAYBOOK; правила/skills и NO TESTS были в полном task prompt.
Reviewer не запускал проверки и не заявляет live QA. Scope/diff независимо
сверены оркестратором: только три разрешённых tracked файла, index пуст,
HEAD остаётся `11b0eff7be9dfeb0cc1faf3d0aeab8641aa25988`, `?? ios/` сохранён.
Логи/reports/точный diff находятся в scratch с префиксом
`tracksu-ranking-identity-`; финальный reviewer log:
`/Users/aleksandrpavlenko/Documents/autonomous-ai-agents/pavlenko-agent-team/runs/3df9b8e9b5364dd1919a49f5d177baf1/stdout.txt`.
После docs-уточнений финальные format-check exit 0 (1 file, 0 changed),
analyzer exit 0 (No issues found!, 2.1 s), diff-check exit 0. Production correction cycles: 0;
один docs-clarification pass. Install/live QA остаётся на parent.

## Пауза по требованию пользователя — 2026-10-02

**Работа остановлена. Не продолжать QA, сборки, staging или commit без нового
поручения пользователя.** Owned Flutter attach и simctl console-proxy остановлены.
Новые GUI-действия при фиксации паузы не выполнялись.

- Ветка `dev`, HEAD `11b0eff7be9dfeb0cc1faf3d0aeab8641aa25988`.
  Ранее созданы четыре локальных checkpoint-коммита: `01f65e5`, `f97bb56`,
  `f27ea82`, `11b0eff`. Push не выполнялся; `ios/` не включён.
- Новая ranking identity правка **не закоммичена**: три tracked изменения —
  `rankings_section.dart`, `CHANGELOG.md`, эта work card. Index пуст;
  существующий `?? ios/` сохранён. Source diff — комментарий и constant key
  на прямом list-owning `SliverPadding`, без изменений аудио/cache/native host.
- Child format/analyzer/diff/simulator build и независимый review прошли;
  parent повторил format (1 file,0changed), analyzer (No issues found!,1.4s)
  и diff-check. Parent установил artifact на существующий iPhone17
  `7150350D-89C4-44A6-AE44-146571C269DE`; app UI был виден на screenshot.
- Parent инструментально подтвердил реальные before/after refresh:
  Loaded,50items,nextPage2,operationnull,failure=null. Старые padding/list
  element+render объекты остались active с теми же identityHashCode:
  padding734806774/render797118051,list864695870/render715923808.
  Первая видимая строка (id7562902,тот же индекс) также осталась active,
  element identity2282216. Это не доказательство всех строк/перестановок.
- Первая выбранная строка после refresh оказалась unmounted; выбор был заменён
  на фактически видимую первую строку. Причина пересоздания той отдельной строки
  не установлена; общее сохранение всех lazy rows не заявляется.
- **Переходный кадр с simultaneous leading progress/trailing auto-load removal
  не зафиксирован.** Breakpoint не поймал нужную фазу; попытка read-only
  post-frame observer завершилась expression compilation error113, без
  добавления production instrumentation. Error/Retry, pagination/filter и
  полноценная GUI-проверка этой правки остаются открытыми. Это не app build error.
- Задержка parent QA возникла в debugger workflow: несколько попыток получения
  service URI/attach, ошибки параметров и watch-expression, повторный выбор
  объекта строки. Вместо продолжения инструментальной петли пользователь
  остановил работу и сменил метод UI-приёмки. Общий P29 awaiting_manual_check.

### Новый обязательный метод simulator UI QA

Пользователь требует управлять **реальным окном Simulator через компьютер**:
видимые GUI-клики курсором, ввод/скролл, сохранение screenshot после действий
и визуальный анализ. Прежний VM/DDS/Python recipe выше — исторический и
**не является дальнейшим планом UI-проверки**. Router/BLoC/widget вызовы через
сокеты не заменяют клики пользователя. Инструментальный debugger разрешается
только отдельным новым поручением, не как автоматический обход проблем GUI.

При возобновлении load `computer-use`; использовать доступный GUI input tool.
Уточнение пользователя: цель — **простота и скорость готового GUI workflow**,
а не обязательное движение физического OS cursor. Использовать рабочий режим
готового computer-use tool (background delivery/agent cursor допустимы, если
они действительно нажимают интерфейс Simulator и результат виден на screenshot).
Цикл: screenshot → click/type/scroll → screenshot → визуальная проверка.
При неудаче — новый screenshot и максимум одна простая корректирующая попытка,
далее сообщить блокер. Не тратить полчаса на написание собственного QA-кода,
настройку сокетов/debugger или инфраструктуры для проверки обычного UI-сценария.
Сейчас не проверять driver, не менять permissions/config и не запускать Simulator.
Правило сохранено в canonical `pavlenko-flutter-quality` (входит в CLI worker
prompt) и `tracksu-development`; developer/reviewer должны получить его.
Следующий шаг только после разрешения: реальная GUI-проверка Refresh/scroll/Retry
со скриншотами, затем решение о пятом локальном коммите. Не закрывать P29 автоматически.

## Возобновление по новому поручению — 2026-10-02

Пользователь: «окей пусть продолжат работу». Пауза выше — исторический checkpoint;
разрешено продолжить ограниченную GUI-проверку ranking correction. Использовать
готовый computer-use tool для настоящего окна Simulator: screenshot → действие
→ screenshot → визуальный анализ. Не открывать VM/DDS, не писать QA-скрипты,
не вызывать router/BLoC/widget APIs вместо жестов. По следующему явному поручению
пользователя создан отдельный `Tracksu iPhone 17`, iOS27.0,
UDID `569DF6F0-7902-4C25-B818-935EB8C8688F`. Использовать только его для
дальнейшего Tracksu QA. Устройство booted; текущий Runner.app установлен,
launch exit0 (PID97381); наличие app независимо проверено get_app_container.
GUI-проверка ещё не выполнена. Старый iPhone17 и его данные не изменялись;
auth/cache между устройствами не копировались. Не пересобирать без конкретной
необходимости.
После одного простого корректирующего повтора при блокере — отчёт, не длинная
настройка инфраструктуры. Worker сохраняет доказательства и actual gaps;
parent решает о локальном checkpoint commit после readback. Push/deploy/ios
по-прежнему исключены; общий P29 остаётся awaiting_manual_check.

### Короткая GUI-попытка на dedicated device — 2026-10-02

Статус: **BLOCKED / awaiting_manual_check**, не GUI verified.

- Загружены computer-use, Tracksu/team и четыре canonical Flutter skills.
  `computer_use(capture, app=Simulator)` вернул 0×0, no on-screen window,
  без screenshot/элементов; `list_apps` не содержит Simulator.
- `xcode-select -p`: `/Applications/Xcode.app/Contents/Developer`.
  Единственная простая корректирующая попытка — открыть установленный
  Simulator.app с `-CurrentDeviceUDID 569DF6F0-7902-4C25-B818-935EB8C8688F` —
  остановилась на проверке отсутствующего
  `/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app`
  (exit 1; open не выполнялся). Spotlight-поиск точного bundle identifier
  `com.apple.iphonesimulator` не дал результата; discovery по /Applications
  также не нашёл Simulator.app. Это блокер GUI host, не ошибка Runner build.
- Dedicated `Tracksu iPhone 17` по simctl остаётся Booted. Только с него снят
  framebuffer screenshot (exit 0), сохранён и визуально просмотрен:
  `/Users/aleksandrpavlenko/.hermes/cache/scratch/tracksu-ranking-gui-blocker-dedicated.png`.
  На изображении штатный Search / Find player, пустое поле Exact username or ID,
  выбран ctd; в нижней панели есть Rankings. Нет видимого permission/auth dialog
  или app error. Framebuffer не является screenshot окна Simulator/доказательством
  GUI-кликов; по нему невозможно проверить эффект Refresh.
- Реальных кликов Rankings/Refresh, scroll/pagination не выполнено: окна для
  готового GUI tool нет. Loaded-content retention, repeated cold skeleton,
  scroll reset, transient refresh и Retry/error остаются GUI gaps. Никаких
  утверждений об internal identity по screenshot не делается; прежняя VM
  проверка остаётся отдельным историческим свидетельством.
- После блокера остановились без repair/install/driver/permissions detour,
  VM/DDS/сокетов, QA automation, build, изменения auth/cache/native host,
  source fixes, staging/commit/push. Старый личный simulator не использован.
  Изменены только эта card и относящийся CHANGELOG; source correction сохранён.
