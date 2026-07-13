# TSD → Tracksu: проверенный архитектурный референс

2026-09-04 · TSD: `/Users/aleksandrpavlenko/Projects/tsd`, HEAD `e2ce51a94`
(2026-09-01); рабочее дерево при сверке чистое. Tracksu:
`/Users/aleksandrpavlenko/Projects/tracksu`, Flutter app пока во вложенной `tracksu/`.

Сверка выполнена чтением исходников: root manifest/config/scripts, все девять
package manifests, bootstrap/DI, полный вертикальный срез free_tasks, router,
network/storage/UI/l10n, примеры общих моделей и native-конфигурация. Это не
полный аудит каждой feature TSD и не подтверждение сборки. Получение зависимостей,
генерация, analyzer, сборки и тесты не запускались; секреты/ignored files не читались.

## 1. Что действительно есть в текущем TSD

| Область | Проверенный образец | Вывод для Tracksu |
| --- | --- | --- |
| SDK/workspace | [pubspec.yaml](/Users/aleksandrpavlenko/Projects/tsd/pubspec.yaml), [.fvmrc](/Users/aleksandrpavlenko/Projects/tsd/.fvmrc) | Pub workspace `packages/*`, SDK ^3.13.0, Flutter ≥3.47.0, FVM 3.47.2; exact pin Tracksu проверяется на P02 |
| Tooling | [Makefile](/Users/aleksandrpavlenko/Projects/tsd/Makefile), [get.sh](/Users/aleksandrpavlenko/Projects/tsd/scripts/get.sh), [gen.sh](/Users/aleksandrpavlenko/Projects/tsd/scripts/gen.sh) | Один pub get из корня; root build_runner; не нужен цикл pub get по packages |
| Bootstrap | [main.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/main.dart), [app/main.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/app/main.dart) | Root initialization отдельно от root Bloc providers и экрана |
| DI | [container.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/_core/dependencies/container.dart), [scope.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/_core/dependencies/scope.dart) | `registerDependencies`, final DepsContainer, InheritedWidget DepsScope без обновлений; feature DI локальный |
| Feature entry | [free_tasks/main.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/free_tasks/main.dart) | `XxxMain` строит RemoteSourceImpl → RepositoryImpl → Bloc и один initial event в provider.create |
| Repository | [domain/repository.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/free_tasks/domain/repository.dart), [data/repository.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/free_tasks/data/repository.dart) | Interface и implementation разделены; repository возвращает typed модели |
| Remote source | [remote_source_impl.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/free_tasks/data/source/remote_source_impl.dart) | Endpoints/query и raw response extraction на внешней границе |
| State | [bloc.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/free_tasks/bloc/bloc.dart), [event.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/free_tasks/bloc/event.dart), [state.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/free_tasks/bloc/state.dart) | Одна Dart library, part files, sealed states/events, switch, sequential handler, addError со stack |
| Screen | [screen.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/free_tasks/widgets/screen.dart) | Экран отдельно от wiring; listener для side effects, builder для отображения |
| Navigation | [routes.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/_core/router/routes.dart), [NavigatorPage](/Users/aleksandrpavlenko/Projects/tsd/lib/src/_core/router/navigator_page.dart), [NavigatorModal](/Users/aleksandrpavlenko/Projects/tsd/lib/src/_core/router/navigator_modal.dart) | Центральный Navigator 1 facade, typed route params, общие transitions; это не go_router |
| Errors | [zoned_bloc_observer.dart](/Users/aleksandrpavlenko/Projects/tsd/lib/src/_core/middleware/observers/zoned_bloc_observer.dart) | Общая классификация/reporting, обработка auth errors; продуктовые реакции адаптировать |
| Android | [app/build.gradle](/Users/aleksandrpavlenko/Projects/tsd/android/app/build.gradle), [MainActivity.kt](/Users/aleksandrpavlenko/Projects/tsd/android/app/src/main/kotlin/com/lot/tsd/MainActivity.kt) | Явный namespace, Kotlin host, Plugin DSL; build scripts остаются Groovy |
| iOS | [project.pbxproj](/Users/aleksandrpavlenko/Projects/tsd/ios/Runner.xcodeproj/project.pbxproj), [Runner.xcscheme](/Users/aleksandrpavlenko/Projects/tsd/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme) | Есть FlutterGeneratedPluginSwiftPackage и prepare pre-action; фактическая SPM-интеграция |

Дальнейшая сверка начинается с этих файлов, а не с повторного обхода всего TSD.
При изменении reference checkout записать, какие решения он затронул.

## 2. Пакетная часть

Все девять package manifests используют `resolution: workspace`. Корневой
pubspec подключает их обычными version constraints; отдельные path overrides
не служат основой этого monorepo. Есть root `pubspec.lock` и public package barrels.

| TSD package | Ответственность по исходникам | Цель для Tracksu и момент появления |
| --- | --- | --- |
| [tsd_network](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_network/pubspec.yaml) | RestClient/DioRestClient, response/options, typed exceptions | `tracksu_network`, P06; собственный лёгкий REST, выбор http/Dio открыт, переносим границы, не весь клиент |
| [tsd_models](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_models/pubspec.yaml) | Shared data models, meta/collection, без Flutter dependency | `tracksu_models`, P06 по потребности; общие ID/Ruleset и согласованные понятия, не все feature DTO |
| [tsd_storage](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_storage/pubspec.yaml) | Typed preferences + flutter_secure_storage | `tracksu_storage`, P08; token store, настройки, миграция старых ключей |
| [tsd_ui](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_ui/pubspec.yaml) | Themes, UiText, buttons, fields, loaders, images, extensions | `tracksu_ui`, P07; один UI kit, зависимости только для реальных компонентов |
| [tsd_l10n](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_l10n/pubspec.yaml) | Flutter localization, ARB, context.t | `tracksu_l10n`, обязательная P07.1; не переносить список языков TSD автоматически |
| [tsd_utils](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_utils/pubspec.yaml) | Helpers, в том числе Flutter/intl | `tracksu_utils` только при реальном reuse; этот пакет не считать автоматически pure domain |
| [tsd_device](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_device/pubspec.yaml) | Android plugin для терминалов, barcode/RFID | Не нужен для текущего scope |
| [tsd_ble](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_ble/pubspec.yaml) | Android BLE plugin | Не нужен для текущего scope |
| [tsd_code_generator](/Users/aleksandrpavlenko/Projects/tsd/packages/tsd_code_generator/pubspec.yaml) | Генерация изображений barcode | Не Dart codegen; не нужен Tracksu |

`tracksu_*` — рабочая карта ролей. На P01.1 выбрать окончательный package prefix
после нового нейминга; не создавать пакеты сейчас, чтобы затем массово переименовать.

У каждого будущего внутреннего package: `publish_to: none`, SDK constraints,
`resolution: workspace`, единый analyzer policy и узкий `lib/<package>.dart`.
Зависимости декларируются непосредственно там, где используются. Не рассчитывать
на транзитивную доступность Flutter/Dio через соседний package.

Низкоуровневые packages не импортируют `package:tracksu/src/...` и друг друга
циклически. UI kit принимает display values/callbacks, не знает repositories,
session или osu! endpoints. Models не импортируют network/storage/UI. Если helper
требует Flutter, pure domain не должен тянуть его только ради одной функции.

UI kit не равен `lib/src/_shared`: последнее — место общих сценариев приложения
и composition, например app-level modal. Widget, нужный одной feature, остаётся
в её `widgets/`. Каждая feature не превращается в отдельный Pub package.

## 3. Единый шаблон новой feature

```text
lib/src/profile/
  main.dart                 ProfileMain, локальная сборка зависимостей
  domain/
    repository.dart         abstract interface ProfileRepository
    route_params.dart       ProfileParams с ID/ruleset
    models/                 только локальные понятия и инварианты
  data/
    repository_impl.dart    final ProfileRepositoryImpl
    source/
      remote_source.dart
      remote_source_impl.dart
    dto/                    только при нужном wire/domain разделении
    mappers/                только при реальной сложности mapping
  bloc/
    bloc.dart
    event.dart              part of bloc.dart
    state.dart              part of bloc.dart
  widgets/
    screen.dart             Scaffold, listener, state rendering
    ...                     небольшие компоненты feature
```

В самом TSD naming data-файлов местами различается. В новом Tracksu фиксируем
`repository_impl.dart` и `data/source/`, не создаём и `repository.dart`, и
`repository_impl.dart` с одинаковой ролью. Маленькая feature без remote source
не получает пустые data/domain каталоги для симметрии.

DDD здесь — названные понятия, инварианты, контракт repository и ответственность
feature. Не нужна обязательная цепочка из use case/proxy/base repository вокруг
каждого GET. Долгоживущий SessionController обоснован; controller поверх любого
одиночного Bloc — нет.

Виджет получает Bloc/модель, Bloc — domain interface, repository implementation —
источники. `XxxMain` может видеть обе стороны, потому что собирает граф.
`_core/dependencies`/router — также integration layer, не «чистый domain».

## 4. Что сохраняем из подхода TSD

- Явные зависимости через constructors. Shared infra создаётся один раз;
  feature-local объекты — в main, не все repositories регистрируются глобально.
- DepsScope выдаёт стабильный контейнер, не рассылает каждое обновление session
  по всему дереву. Изменения session слушает только нужный потребитель.
- Bloc events/states — sealed hierarchy, exhaustive switch, part-файлы.
  Имена включают feature. Стартовое событие не отправляется на каждом build.
- Public barrel imports между packages, typed params и центральные navigation
  facades. Navigator/BuildContext не попадают в Bloc или repository.
- UI primitives/themes и semantic text — в одном package. `context.t` — доступ
  к локализованным строкам; `Row/Column.spacing`/Padding — layout spacing.
- Владельцы ресурсов явные: кто создал Bloc/controller/subscription/player,
  тот отвечает за close/dispose. Async completion после закрытия не меняет UI.
- Новый Dart-стиль: final/const, abstract interface, sealed, switch expressions,
  строгие типы/nullability, constructors/classes в стиле поддерживаемого SDK.
  Синтаксис TSD виден в event/state/models; применяем после pin на P02, не к
  ещё не мигрированному legacy SDK.

## 5. Где адаптируем осознанно, а не копируем буквально

1. **Domain и wire models.** В free_tasks repository contract есть
   `RestClientOptions`, а модели умеют fromJson. Это рабочая практика TSD, но
   не строгая transport-free граница. В Tracksu сохраняем организацию feature,
   а wire DTO/decoder оставляем в data; общие чистые модели — в models/domain.
   Не создаём второй идентичный класс без нужды: отдельный mapper/decoder тоже
   может сохранить границу. UI-флаг `showLoader` в domain не переносим.
2. **Loading и ошибки.** Не воспроизводим глобальный overlay на каждый запрос,
   полноэкранный error при refresh или повторный snackbar от observer/listener.
   Первая загрузка, content, refresh и pagination имеют разные состояния.
3. **Concurrency.** sequential подходит для последовательных операций, но поиск
   и смена ruleset должны игнорировать устаревшие результаты. Refresh/pagination
   не создают дубли; ответы прежней session не меняют новую. Политика записана
   до реализации, а не выводится из названия Bloc.
4. **UI effects.** Listener из TSD — образец места эффекта, не гарантия его
   однократности. Navigation intent не должен оставаться в content так, чтобы
   последующий emit снова открывал страницу. Выбираем consume/listenWhen/effect
   контракт для конкретной feature без нового универсального framework.
5. **Rebuild.** AnimatedBlocBuilder использует AnimatedSwitcher; сам по себе
   не уменьшает перестройки. Узкие selectors, независимые секции, стабильные
   list keys и локальный progress обязательнее общей анимации целого экрана.
6. **Storage/session.** Typed secure storage TSD — полезный образец. Для osu!
   отдельно нужны access/refresh/expiry, refresh single-flight, logout и старые
   preferences; не копируем `StorageController.clear()` как blanket wipe
   настроек. Session — один владелец, не глобальный mutable User DTO.
7. **Routes.** TSD facade остаётся базой. Внешний URI — недоверенный input:
   OAuth callback и deep links валидируются до typed params, без небезопасных
   casts/raw maps. Не копируем весь route list, server route intents или
   scanner route observers. Tabs/backstack отдельно проверяет пользователь.
8. **Packages и UI dependencies.** TSD использует material_ui и private lints.
   Наличие зависимости не означает, что она обязательна для Tracksu. До принятия
   проверить назначение, доступность, лицензию и совместимость. Не переносить
   корпоративные assets, сетевые контракты, branding, scanner/BLE/AAR.
   Для analyzer уже выбрана собственная база: пользовательский YAML и его
   [адаптация под Tracksu](../standards/CODE_STYLE.md). Берём общую workspace policy как в
   TSD, но не приватный analyzer_lichi; подключение выполняется на P02.
   Для сети действует [минимальный scope](../standards/DEPENDENCIES.md): одна реализация
   собственного REST-клиента поверх выбранного http или Dio. UI dependencies и
   native generators удаляются по той же карте, не заменяются копией всех пакетов TSD.
9. **Native build.** В TSD есть переходные `android.builtInKotlin=false` и
   `android.newDsl=false`, аппаратные AAR и signing release для разных variants.
   Их не копируем. Новый Tracksu shell берём из выбранного Flutter template,
   сохраняем свою identity и используем только необходимые интеграции.
10. **Tests.** TSD и skills содержат test-подход. Пользователь его сейчас
    исключил: никакого переноса test dependencies/CI и запуска tests до T01.

## 6. Tooling, локализация и native: код важнее старого описания

- В CLAUDE.md TSD описаны циклы pub get по пакетам и slang. Сейчас `get.sh`
  вызывает один `fvm flutter pub get`, а `tsd_l10n` содержит ARB, `l10n.yaml`,
  `flutter: generate: true` и AppLocalizations. Для Tracksu берём текущий вариант
  Flutter l10n, не добавляем slang по устаревшему тексту.
- `gen.sh` сейчас запускает root build_runner. Это не доказательство, что одна
  команда уже явно покрывает каждую будущую package generation задачу Tracksu.
  Для ARB предусмотреть проверенную команду в l10n package; scripts обновлять
  по фактическим inputs. Generated файлы не править вручную.
- Checked model examples — ручные классы/fromJson; root build_runner связан
  в том числе с envied/pubspec generation. Freezed не назначается обязательным
  выбором. `tsd_code_generator` генерирует barcode, а не Dart models.
- TSD CI включает закрытую корпоративную конфигурацию. Для Tracksu создать
  собственный минимальный format/analyze/build workflow по доступной платформе,
  без копирования include/deploy/credentials и без tests. Makefile и scripts
  должны быть читаемыми и достаточными для нового checkout.
- iOS TSD содержит SPM, deployment target 15.6. Это snapshot, не автоматическая
  рекомендация такого min OS для Tracksu. На P04 — выбранный SDK, compatibility
  plugins, Xcode, signing и capabilities; сгенерированные package registrants
  не копируются из TSD.
- Android TSD: Kotlin MainActivity + Groovy Gradle, явный namespace. В Tracksu
  P03.1 уже применил Kotlin package `io.github.wratheus.tracksu`; explicit
  namespace/package wiring завершаем после P02,
  а не искать отсутствующую Java MainActivity. Kotlin source, Kotlin DSL,
  JVM target и app ID — четыре разных аспекта.

## 7. Где принимаем оставшиеся решения

- P00: store status, доступные ключи и данные; по скриншоту аккаунт удалён
  за пропущенное подтверждение. Не обещать восстановление/перенос без проверки.
- P01/P01.1: новый нейминг продукта/разработчика, package prefix, расположение
  workspace, общие модели/границы, поддерживаемые языки и рынки; ADR отличий.
- P02: версии, workspace/lockfile/analyzer/scripts/CI. Сам просмотр TSD не
  доказывает совместимость plugins Tracksu с его version pins.
- P03/P04: native shells и окончательная техническая identity согласно P00/P01.1.
- P05: OAuth callback и контракт API; P05.1 — отдельная DI/bootstrap foundation
  по container/scope/app/main образцам выше. P06 подключает HTTP/repositories
  к готовому DI, P06.1 — analytics, P08 — session/storage.
- P07/P07.1: UI kit и обязательная localization foundation; P09–P14 — feature
  UI уже локализован, не откладываем весь перевод до релиза.

Очередь и статусы ведутся только в plan/DETAILS.md. Этот документ — карта
образцов и правил, не второй backlog и не разрешение начать все части.

## 8. Дополнительный референс: аналитика Lichi

По просьбе пользователя 2026-09-04 отдельно просмотрен analytics-срез
`/Users/aleksandrpavlenko/Projects/lichi`, HEAD `a0dcd0e50` (2026-06-29).
В checkout есть посторонние изменения Android/IDE; их не читали и не меняли.
Секреты, Firebase configuration и ignored files не открывались, сборки не запускались.
Этот референс дополняет TSD только в P06.1, не заменяет layout/DI/router Tracksu.

- [Firebase service/events](/Users/aleksandrpavlenko/Projects/lichi/lib/src/common/services/analytics/firebase_analytics_service.dart):
  общий service инкапсулирует SDK, фасад FirebaseAnalyticsEvents именует действия,
  initialize задаёт default parameters. Это основа идеи единого клиента.
- [Analytics contracts](/Users/aleksandrpavlenko/Projects/lichi/lib/src/common/services/analytics/analytics_service.dart):
  interface, semantic methods и no-op реализация для неподдерживаемого режима.
- [App dependencies](/Users/aleksandrpavlenko/Projects/lichi/lib/src/feature/app/models/app_dependencies_container.dart):
  общий и Firebase фасады доступны через контейнер, а не создаются в каждом widget.
- [AuthAnalytics](/Users/aleksandrpavlenko/Projects/lichi/lib/src/feature/auth/utils/auth_analytics.dart):
  пример небольшого feature-specific фасада. В Tracksu он нужен только там,
  где добавляет семантику; пустые proxy-классы для каждой кнопки не обязательны.
- [Share action](/Users/aleksandrpavlenko/Projects/lichi/lib/src/shared/product_card_viewer/widget/product_card_assets_carousel/share_button.dart):
  реальный consumer FirebaseAnalyticsEvents через AppScope.
- [UiButton](/Users/aleksandrpavlenko/Projects/lichi/lib/src/shared/ui/button.dart):
  общий onPressed wrapper обслуживает haptics, автоматического analytics hook
  в этом компоненте нет. Поддержка единого hook в Tracksu UI kit — новая цель,
  а не утверждение, что Lichi уже автоматически покрывает все компоненты.
- [AnalyticsFactory](/Users/aleksandrpavlenko/Projects/lichi/lib/src/feature/initialization/logic/analytics_factory.dart):
  есть no-op и выбор AppMetrica/Adjust по config/региону. Этот factory относится
  к общему analytics service; не доказывает consent gate Firebase service.

Берём фасад, централизованный контекст, DI и no-op. В Tracksu усиливаем типизацию,
общий UI binding, изоляцию ошибок SDK и однозначного владельца отправки. В Lichi
сервис добавляет device ID и логирует params; не переносим это автоматически.
E-commerce, Adjust/AppMetrica, рекламная атрибуция и региональные условия Lichi
не нужны базовой аналитике Tracksu. Правила privacy/consent принимаются отдельно;
само наличие выключаемого клиента не выключает автоматический сбор SDK.
