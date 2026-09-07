# P07 — UI foundation, до переноса страниц

2026-09-07. Пользователь разрешил реализацию: Stitch — ориентир примерно на
60%, не точная спецификация. Разрешена осмысленная корректировка визуального
языка; сначала UI kit/шрифты/Material themes/feedback, затем страницы.

## Контракт и границы

Новый workspace package `tracksu_ui`: semantic tokens, dark/light ThemeData,
типографика, базовые компоненты и feedback surfaces. Зависит только от Flutter,
принимает локализованные строки/callbacks, не знает API/Bloc/session/router.
Ручной каталог запускается отдельным entrypoint без bootstrap/OAuth/network.
Это инструмент просмотра компонентов, не автоматический test harness.

Основной app entry и существующие страницы пока не переключаем на тему.
P07.2 router/back stacks, API/model expansion, Firebase, asset cleanup,
новые шрифтовые загрузки и перенос ARB в пакет вне этого среза.
Никаких автотестов. Формат, analyzer, сборка; внешний вид проверяет пользователь.

## Визуальные решения

- Из legacy `3218102^`: Exo 2, сливовый #2A243A, тёплые поверхности,
  розовый #ED529A. Не переносим старые тени, мелкий текст и фиксированные высоты.
- Из Stitch Revision 2: спокойная matte-основа, компактная иерархия, округления.
- Убираем декорации ради декораций: псевдо-статусы LIVE/PRO, капс везде,
  микроподписи на двух языках, огромные hero-числа для каждой метрики.
- Exo 2 используем из существующего приложения; системные CJK fallback,
  без скачивания новых шрифтов. Проверка прав на поставку остаётся P01.2.
- Масштабируемые Material primitives с кастомной темой вместо собственной
  реализации gesture/focus/semantics. UI skill определяет эту границу.

## Commit plan

1. `feat(ui): establish themed component foundation and manual catalog`:
   пакет + Material themes + компоненты + каталог + package docs, workspace
   registration, исправление регистра пути существующего italic font.
   Проверки format/analyze/build. Возврат: адресный revert; данных не меняем.
2. После ручной оценки: корректировки foundation, предметные визуальные
   primitives по нуждам страниц; затем отдельные срезы переноса страниц.

## Готовность и ручная проверка

- Тёмная/светлая темы: текст, кнопки/поля, выбранные/disabled/loading состояния.
- Confirm возвращает true только по подтверждению; dismiss/back — false;
  cancel не вызывает бизнес-действие. Snackbar не накапливает очередь ошибок.
- Sheets скроллятся с клавиатурой и крупным шрифтом; длинные подписи переносятся.
- Семь локализаций доступны каталогу; пакет не содержит текстов фич.
- Основное приложение остаётся на прежнем entrypoint, сценарии не меняются.

## Прогресс

Прочитаны текущие план/skills, UI package TSD (read-only), legacy palette/card
из Git и HTML четырёх ключевых Revision 2 экранов Stitch. Даже Revision 2
содержит неподтверждённые PKCE/osu://callback/seasonal peak — не переносим.
Рабочее дерево при старте чистое. Flutter 3.47.2 / Dart 3.13.2 подтверждены.
Технические результаты и handoff дополняются по факту.

### Завершённый checkpoint

Созданы theme/tokens, все 15 именованных Material UiText presets + metric,
пять именованных вариантов UiButton, UiSurface/UiSearchField/UiNotice/UiLoading,
snackbar и typed modal/confirm API. Font: Exo 2 в заголовках/метриках, системный
body/CJK fallback. Исправлен регистр пути существующего italic asset.
Добавлены восемь строк каталога на каждый из семи языков и generated output.
Каталог — `fvm flutter run -t lib/ui_catalog.dart`, без сети/сессии.
Использует тот же Android app ID; отдельно установку не выполняли.

Проверки 2026-09-07:

- `fvm flutter pub get --offline`: успешно, новых сторонних зависимостей нет.
- `fvm flutter gen-l10n`: успешно, untranslated report `{}`.
- `fvm dart format packages/tracksu_ui/lib lib/ui_catalog.dart`: выполнено.
- `fvm dart analyze lib packages/tracksu_ui/lib packages/tracksu_network/lib packages/tracksu_storage/lib`:
  No issues found.
- `fvm flutter build apk --debug -t lib/ui_catalog.dart`: успешно, 29,1 с.
- `fvm flutter build apk --debug --no-pub -t lib/main.dart`: успешно, 10,1 с.
- `git diff --check`: успешно. Сохранилось прежнее предупреждение Gradle/JDK
  о native access; сборке не мешает. Автотесты не писались и не запускались.

На устройстве каталог не открывался: внешний вид, контраст, крупный шрифт,
клавиатура, TalkBack и жесты sheet ждут ручной проверки, не объявлены verified.
Основное приложение остаётся на старой теме. Последний собранный APK — основной
entrypoint; каталог запускается указанной командой, без удаления данных.

Оставшаяся работа: предметные primitives (flags/rulesets/grades/images),
композиции empty/error, theme persistence, P07.2 navigation, затем перенос
страниц. Общий UI kit не объявляется полностью законченным по одному checkpoint.
Правило именованных constructors сохранено в standards/SKILLS.md.
