# Как применяем пользовательские skills

2026-09-04 · для программы переработки Tracksu.

Четыре полных SKILL.md прочитаны при подготовке этого комплекта. Они перенесены
в общую папку без изменения содержания. Это правила будущей работы в пределах
выбранной части, не команда начать реализацию и не автоматическая установка.

## Обязательное исключение: никаких автотестов сейчас

Пользователь прямо исключил написание, изменение и запуск автотестов из
рефакторинга. Поэтому требования skills `mandatory tests`, targeted tests,
regression tests, mocks/fakes, golden, coverage и test CI **не выполняются**
на P00–P15. Существующие тесты тоже не «чинятся заодно». Всё это относится к
отдельному T01, только после нового явного выбора пользователя.

Из quality-процесса остаются чтение кода, проверка контрактов, lifecycle и diff,
а при реализации — format/analyze/build по scope. Поведение проверяет пользователь
вручную. Отсутствие автотестов не объявлять неожиданным blocker и не пытаться
обойти это правило созданием «проверочного» test harness под другим именем.

## Когда какой skill читать

| Skill | Когда нужен | Что берём |
| --- | --- | --- |
| [pavlenko-flutter-feature](../skills/pavlenko-flutter-feature/SKILL.md) | Foundation, перенос/добавление feature, repository/Bloc | Reuse-first; main/domain/data/bloc/widgets; явный DI; typed contracts; ownership и concurrency |
| [pavlenko-flutter-ui](../skills/pavlenko-flutter-ui/SKILL.md) | UI kit, экран, форма, локализация, список | Public UI API, themes/tokens, чистые builders, scope UI-state, layout/lifecycle и l10n |
| [pavlenko-dart-style](../skills/pavlenko-dart-style/SKILL.md) | Любое изменение Dart-кода | SDK/analyzer style, types/nullability, sealed/final, errors/async, imports и constructors |
| [pavlenko-flutter-quality](../skills/pavlenko-flutter-quality/SKILL.md) | Review и handoff каждой реализации | Проверка diff, errors, race/lifecycle, scope и реальные результаты проверок; без test-разделов |

Обычный порядок для вертикального среза: feature → dart-style → ui (если есть UI)
→ quality. Для чистого UI: ui → dart-style → quality. Для документации skills
служат источниками правил, их команды build/get/gen не запускаются.

## Как адаптируем к Tracksu

- `tsd_*` в примерах означает роль пакета. В новой app используем согласованный
  собственный prefix: `tracksu_*` пока рабочее обозначение до нейминга P01.1.
  Импортировать корпоративные tsd packages или копировать их исходники не требуется.
- Skills рекомендуют `data/repository_impl.dart` и remote source рядом.
  В TSD встречаются `data/repository.dart`, `data/source/` и разные исторические
  раскладки. Для новой Tracksu выбираем одну схему из TSD_REFERENCE, а не
  воспроизводим все варианты сразу. Пустые слои/файлы не создаём.
- Структура presentation — `bloc/` + `widgets/`; слой остаётся логическим,
  отдельная папка с названием `presentation` не нужна.
- `DepsContainer/DepsScope`, локальное wiring в `XxxMain`, navigation facades
  и public barrels сохраняются. Controller вводится для долгоживущей координации,
  а не поверх каждого repository. Use case — только для реальной политики.
- `sequential()` — начальный вариант для упорядоченных команд. Быстрый поиск,
  ruleset/query и pagination требуют собственной явно описанной политики;
  она важнее механического применения одного transformer ко всем событиям.
- Request options не теряются внутри data/transport. Но TSD `showLoader` не
  переносим в domain Tracksu: локальные loading/refresh/pagination задаёт Bloc.
  Параметры запроса в repository — бизнес-намерения, не HTTP/UI переключатели.
- Ошибки сохраняют stack trace; общий observer/reporting не должен одновременно
  с локальным экраном показывать второе сообщение. В логи не попадают токены,
  callback codes, headers и содержимое защищённого хранилища.
- UI skill требует shared-компоненты. До P07 мы их ещё создаём; после P07
  используем существующий `tracksu_ui`, не плодим вторую design system.
  Feature cards и app-level shared scenarios не становятся частью базового UI kit.
- P07: короткие именованные конструкторы — `UiText.bodyMedium/titleLarge/...`
  для всех Material TextTheme presets, `UiText.metric`, `UiButton.primary/...`.
  Семантика, tokens и theme — общие владельцы внешнего вида. Локальная
  кастомизация не превращается в копирование TextStyle/цветов по всем страницам.
  Простые native controls используют общую Material theme; обёртка нужна
  для устойчивого поведения/семантики, а не только для префикса Ui.
- Правило короткого API распространяется на UiSurface.card/outlined/tonal/inset,
  UiFrame.body/scroll, UiModal.confirm/destructive/info/selection и UiIconButton.
  Для сборки страниц сначала читать recipes в packages/tracksu_ui/README.md.
  Новый общий вариант сопровождается примером каталога; не создавать вторую
  реализацию modal/container в feature и не наращивать универсальный набор flags.
- `Row/Column.spacing` и Padding вместо пустых SizedBox-разделителей;
  SizedBox для constraints/размеров и shrink допустимы. Шкала spacing единая;
  исходная skill-шкала 5/10/15/20/30 — стартовый вариант для design tokens.
- `context.t`, ARB и все согласованные языки обязательны для нового UI.
  Не держать временные английские/русские строки в widget в ожидании «дня перевода».
- ARB оформляем по [Flutter-guidelines policy](LOCALIZATION.md), не по TSD:
  английский шаблон с descriptions/typed placeholders, семь полных каталогов,
  generated output не правим руками. Эта пользовательская policy выше примеров skills.
- Старые адаптеры разрешены только для конкретного legacy consumer с условием
  удаления. Это обоснованный migration boundary, а не вечная compatibility framework.
- Hardware scanner, RFID/BLE, терминальная vibration policy и server-driven UI
  из TSD не относятся к Tracksu. Не создавать похожие контроллеры «для соответствия».
- `make get/gen` использовать только после появления этих команд в Tracksu
  и проверки их содержания; инструкции TSD местами устарели. Генерацию запускать
  при изменении inputs, результаты не править вручную. Тестовые команды исключены.
- Приватный `analyzer_lichi` не переносим: основа — пользовательский YAML и
  [подготовленная policy Tracksu](../standards/CODE_STYLE.md), подключаемая на P02 для app и
  packages. SDK/analyzer policy имеет приоритет над примером синтаксиса из TSD
  или skill; несовместимости решаем явно, не снижаем строгость ради миграции.
  Formatter закрепляется SDK, style lint не заменяет архитектурное/UI review.
- Repo rules TSD действуют при чтении TSD: работа там read-only, без ignored
  secrets/build caches. Его git/CI правила не означают разрешение или запрет
  любых действий во всех других проектах. В Tracksu применяются собственные
  правила и конкретное поручение пользователя; локальные плановые коммиты разрешены.

## Перед передачей результата

Назвать применённые skills, если они определили существенное решение. Указать
scope, изменение поведения, фактические технические проверки и ручной checklist.
Не писать «тесты прошли»: они не запускались по договорённости. Новые вопросы
и unrelated bugs записать отдельно; не расширять scope на несогласованную архитектуру.
