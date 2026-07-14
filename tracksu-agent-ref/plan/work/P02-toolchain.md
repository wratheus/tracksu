# P02 — toolchain and workspace decision

Статус: `in_progress` · 2026-09-04.

## Цель

Выбрать воспроизводимую связку Flutter/Dart/JDK и workspace root до любого
Gradle rewrite, package split или обновления зависимостей.

## Read-only inventory

| Область | Факт |
| --- | --- |
| Selected Flutter | `3.47.2` stable, локально установлен через FVM |
| Selected Dart | `3.13.2`, поставляется с Flutter 3.47.2 |
| TSD reference | `.fvmrc` закреплён на Flutter `3.47.2`; root SDK constraint `^3.13.0` |
| JDK | Локально доступен JBR `21.0.11`; shell default Java — 25, не используем его для Gradle без отдельной совместимости |
| Legacy Tracksu | Gradle 7.4, AGP 4.1.3, Kotlin 1.6.21, Java 8, imperative Flutter Gradle scripts |
| TSD Android snapshot | Plugin DSL, AGP 9.3.2, Kotlin 2.4.10, JVM 21, но также корпоративные AAR/signing/transition flags |

Команда `flutter --version` выполнилась на локальном SDK. Не запускались `pub get`,
analyze, format, build, tests или генерация; project dependencies не менялись.

## Принятое решение: toolchain pin

Flutter `3.47.2` закреплён в root `.fvmrc`; для Android Gradle выбираем JDK 21.
Это даёт Dart 3.13, совпадает с проверенным TSD toolchain и не требует скачивать
новый SDK. До P03.2 отдельно подтвердить фактические AGP/Gradle/Kotlin versions
из Flutter 3.47.2 template и совместимость выбранных Flutter plugins.

`pubspec.yaml` SDK constraints и `pubspec.lock` намеренно не менялись: старые
packages отсутствуют в local pub-cache и их совместимость с Dart 3.13 не
подтверждена. Их обновление и новый resolution будут отдельной P02 compatibility
группой, чтобы не фиксировать заведомо непроверяемое промежуточное состояние.

Не копировать из TSD: `tsd_device` AAR, `material_ui`, corporate analyzer,
release/debug signing, `logger.quiet`, release shrinking policy и временные
Kotlin compatibility comments. Берём только Plugin DSL, explicit namespace,
Kotlin host и принцип одной согласованной toolchain.

## Принятое решение: workspace root

Пользователь выбрал корень repository как Flutter workspace root. В отдельном
checkpoint перенесены `pubspec.yaml`, `android/`, `lib/`, `assets/`,
`analysis_options.yaml` и `tracksu-agent-ref/` из вложенной `tracksu/` в root.
Будущие внутренние packages будут располагаться в `packages/`.

Одновременно по явному решению пользователя удалены legacy GitHub Pages source:
`index.html` и `web_assets/Rolling-200px.gif`. Это не меняет OAuth registration,
DNS или внешний Pages deployment; новый auth flow всё ещё выбирается на P05.

## Следующие небольшие checkpoints после решения

1. `chore(toolchain): pin Flutter 3.47.2` — выполнен: `.fvmrc`, исключение
   локального `.fvm/` и документирование JDK 21; SDK constraints намеренно
   отложены до compatibility-группы.
2. `chore(workspace): establish selected root` — выполнен отдельным commit после
   обновления ссылок и документации.
3. `chore(android): regenerate modern Gradle layer` — clean template comparison,
   Plugin DSL, explicit namespace and new identity; без feature rewrite.
4. Compatibility groups for dependencies, analyzer policy and CI — отдельными
   commits после разрешения tooling.

## Проверки / возврат

Перед code changes проверить template diff, exact compatible toolchain и
affected paths. После каждого checkpoint — diff/format/analyze/build по scope,
но tests не пишем и не запускаем до T01. Любой toolchain commit обратим через
Git; signing/account/remote store actions не входят.
