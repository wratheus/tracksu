# Tracksu — детали этапов

Редакция 12 · 2026-09-04. Содержание работ, не реестр текущих статусов.

Очередь, статус и следующая выбранная часть — [ROADMAP](ROADMAP.md).
Рабочий процесс и шаблон карточки — [регламент](../workflow/PLAYBOOK.md).
Читать только разделы, указанные для выбранного ID в очереди, а не весь файл каждый раз.
Внешние версии и правила ниже отражают предыдущий аудит; перед реализацией
затронутой части перепроверяем их на дату работы. Это не подтверждение совместимости.

<a id="baseline"></a>

## Что есть сейчас

### Инструменты и платформы

- Dart SDK ограничен `>=2.18.2 <3.3.0`; актуальный Flutter/Dart не сможет
  разрешить такой `pubspec` без миграции.
- Android использует Gradle 7.4, AGP 4.1.3, Kotlin 1.6.21, legacy `apply from`
  Flutter Gradle script, Java 8 и `targetSdkVersion 33`.
- Legacy baseline использовал `com.sgoollreps.tracksu`. P03.1 переключил
  applicationId, manifest package и Kotlin MainActivity на
  `io.github.wratheus.tracksu`; Java-файлов в `android/app/src` нет. В legacy
  AGP ещё нет explicit Gradle `namespace`: он будет задан при clean Gradle
  rewrite после P02. Java 8 здесь означает JVM target, а не язык MainActivity.
- iOS — старый CocoaPods-проект c deployment target 9.0 и legacy Xcode build
  settings. Bundle ID в проекте: `com.sgoollreps.tracksu`.
- Команда `flutter` отсутствовала в PATH первоначальной проверки, но FVM и SDK
  установлены: найдены 3.41.9, 3.47.0 и 3.47.2. В SDK 3.47.2 файл версии Dart
  содержит 3.13.2. Проект пока не закреплён за SDK; analyze/test/build в рамках
  планирования не запускались. Эти установленные версии — кандидаты для P02,
  совместимость plugins ещё предстоит проверить.
- Локальный `authentication.dart` намеренно не закоммичен, но импортируется из
  исходников. В чистом checkout это сейчас ошибка компиляции.
- При первоначальном аудите был шаблонный Counter test; сейчас он удалён
  в пользовательском worktree вместе с desktop/web файлами. Это чужие изменения,
  их не восстанавливаем и не включаем в подготовку. T01 по-прежнему отложен.
- README сообщает об удалении приложения из Play; актуальную причину и
  возможность обновления существующей карточки нужно проверить в Console.
- В pubspec указан `Exo2-italic-VariableFont_wght.ttf`, а имя файла содержит
  `Exo2-Italic`. Это нужно исправить при проверке assets на case-sensitive CI.

### Код и риски

- В `lib/src/requests/requests.dart` соединены HTTP, OAuth, JSON-маппинг,
  бизнес-логика и визуальные `Color`. Экранные Cubit'ы напрямую читают secure
  storage и вызывают эти глобальные функции.
- Запросы запускаются прямо из `BlocBuilder.build` (User, Rankings, News,
  Beatmap). Любой лишний rebuild способен повторно начать загрузку. `build`
  должен быть чистой функцией от state.
- `UserWidget` — 2043 строки; ещё 723 строки содержит один виджет вкладок
  пользователя. Это основной источник дублирования и непроверяемости.
- Экранные Cubit'ы получают `BuildContext` и делают навигацию. Так UI-состояние
  и навигация оказываются смешаны.
- Есть `SingleChildScrollView + ListView(shrinkWrap: true,
  NeverScrollableScrollPhysics())` на крупных списках. Такой layout измеряет
  весь список и является вероятной причиной лагов.
- В цикле обработки рейтинга используется `length - 1`; последний элемент
  каждой страницы рейтинга стабильно теряется. Остальные коллекции нужно
  изучить по коду и передать пользователю ручные сценарии проверки.
- В проигрывателе создаётся `Timer.periodic` каждые 50 мс, без гарантированного
  `close/dispose`, а длительность превью зашита в 10 секунд.
- В stdout пишутся access и refresh токены. Это надо удалить до любого
  тестирования на реальном аккаунте.

<a id="p00"></a>

## Неподвижные данные, которые нельзя потерять

До редактирования Android/iOS создать закрытый inventory (не коммитить секреты)
и отметить владельца каждого пункта:

| Что сохранить | Где проверить | Зачем |
| --- | --- | --- |
| Android application ID `com.sgoollreps.tracksu` | `android/app/build.gradle`, Play Console | Обновление существующего приложения, а не новый package |
| Release keystore, alias и пароли | безопасное хранилище; `key.properties` в git не хранить | Подписывать обновления того же приложения |
| Upload key и app signing key, включён ли Play App Signing | Play Console → App integrity | Эти ключи могут различаться; upload-key APK не обязательно обновит установленную Play-версию |
| Play Console, SHA-1/SHA-256 и service integrations | Play Console / сервисы | Не сломать выпуск и связанные API |
| Apple Team, Bundle ID, provisioning, сертификаты, App Store Connect | Apple Developer / App Store Connect | Собрать обновление с тем же идентификатором |
| iOS capabilities, entitlements, privacy strings, URL schemes | старый Xcode project и Apple portal | Восстановить только реально нужное |
| OAuth app: client ID, redirect URI, scopes, владельца | osu! account settings | Не потерять login и не утечь секретом |
| подпись, иконки, splash и version history | текущие проекты / store listing | Сохранить узнаваемость и возможность update |

Сделать защищённую резервную копию keystore и экспорт сертификатов. Проверить
её следует пробной подписью, а не предполагать, что файл «где-то есть».

Для Play App Signing сравниваем сертификат выдаваемого пользователям APK с
app signing certificate; отдельно проверяем upload certificate для AAB.
Порядок описан в [Android signing documentation](https://developer.android.com/studio/publish/app-signing).
Снять максимальный versionCode из используемых store tracks: значение `+6` в
pubspec не подтверждает актуальный номер последнего опубликованного билда.

Это сохранение возможности продолжить старый продукт, а не запрет ребрендинга.
Новые публичные имена выбираются отдельно. До решения P00/P01.1 существующие
applicationId/Bundle ID/ключи остаются baseline, даже если магазин сейчас недоступен.

<a id="p01-1"></a>

## Новый нейминг и путь публикации — P00 / P01.1

По скриншотам пользователя от 2026-09-04: Tracksu (`com.sgoollreps.tracksu`)
имеет статус «Удалено Google», последнее обновление — 29 января 2023.
Профиль SgoollReps обозначен как корпоративный; в уведомлении указано удаление
профиля и приложений 7 октября 2024 из-за непрохождения подтверждения в срок.
Это наблюдение по скриншоту, не полный разбор account enforcement. Статус другого
приложения osu! Track не переносим автоматически на Tracksu.

Пользователь хочет новое имя разработчика и/или продукта. Это отдельная задача
позиционирования, не способ обойти ограничения аккаунта. Пропуск verification
и ребрендинг решаются независимо: сама смена названия не подтверждает владельца.
[Правила Google о verification](https://support.google.com/googleplay/android-developer/answer/14177239?hl=en).

- **P00:** выяснить точный статус/причины в доступных уведомлениях и допустимые
  действия через verification/support. Сохранить старую карточку, ключи и историю.
  Не считать доказанным ни восстановление аккаунта, ни обязательность нового.
  Тип аккаунта должен соответствовать реальному владельцу. Обращения в поддержку,
  регистрация, перенос и изменения аккаунта выполняются только отдельным поручением.
- **P01.1:** выбрать, что переименовываем: продукт, developer brand или оба.
  Подготовить варианты, проверить совпадения, права/ассоциацию с osu!, читаемость
  на целевых языках; отдельно проверить доступность нужных доменов/контактов.
  Сейчас конкретное имя не выбиралось и домены не регистрируются.
- Зафиксировать карту: product display name, публичное developer name, реальный
  владелец аккаунта, Dart package prefix, Android namespace/Kotlin package,
  Android applicationId, Apple Bundle ID, OAuth app display name/redirect URI.
  Это разные поля, не один глобальный search/replace.
- `tracksu_*` в этом плане — рабочий prefix; окончательный выбрать до создания
  packages на P02/P06/P07. Старое имя repo/папки документов пока не переименовываем.
- Обновить по выбранным частям app labels, иконку/splash, About, README, screenshots,
  store listings, privacy/support контакты и OAuth consent display. Названия и
  документы согласовать с правами на brand/assets, не выдавать app за официальную.
- Если допустимо продолжить старую карточку — новый display name не требует
  автоматически нового applicationId. Если осознанно выбираем новый app ID,
  это отдельная установка: нельзя обещать обычное обновление и автоматический
  доступ к прежнему локальному хранилищу. Описать повторный login/перенос данных
  и новый release path; сохранить прежние ключи. Namespace можно менять отдельно.
  [Android: application ID и namespace](https://developer.android.com/build/configure-app-module).

Текущее направление P00: новый Android developer account, прежние signing keys
потеряны; будущие Android `applicationId`, `namespace` и Kotlin package выбраны
как `io.github.wratheus.tracksu`. Старую identity сохраняем как исторический
baseline, но не обещаем update-path. Скриншот владельца от
2026-09-04 подтверждает удаление старого developer profile и запрет публикации
из него; новый release планируем только через новый account и новый application
ID. Reset upload key не выполняем автоматически и не решает удаление account.

Публичное product/developer name, iOS Bundle ID, OAuth display/redirect и Dart
package naming всё ещё решаются на P01.1. Не выполнять global search/replace
`com.sgoollreps.tracksu` до P03: выбранная technical identity применяется там
вместе с чистым Android template и новой подписью.

**Критерий P01.1:** есть выбранные имена, карта переименований и документированное
решение по технической identity. Если store-вопрос ещё открыт, не менять ID;
независимые архитектурные части можно готовить, но выпуск не объявлять готовым.

<a id="p06"></a>

## Целевая архитектура — P01 / P06

Организация и проверенные примеры — [TSD](../reference/TSD.md), обязательные
границы Clean/DDD, Bloc и UI — разделы 7–9 [регламента](../workflow/PLAYBOOK.md).
Здесь остаётся целевая карта Tracksu и решения, необходимые перед созданием пакетов.

```text
<flutter-workspace>/
  pubspec.yaml              workspace: packages/*
  pubspec.lock              единый resolution
  .fvmrc
  analysis_options.yaml
  Makefile, scripts/
  lib/
    main.dart
    src/
      _core/dependencies/   DepsContainer, DepsScope
      _core/router/         AppRouter, NavigatorPage, NavigatorModal
      _core/middleware/     session/error integration
      _shared/              общие app-level сценарии, не второй UI kit
      app/                  root providers, app settings
      session/              общая сессия и её lifecycle
      profile/              пример одной feature
        main.dart           ProfileMain: Source → Repository → Bloc
        domain/             repository.dart, route_params.dart, models/
        data/               repository_impl.dart, source/, dto/, mappers/
        bloc/               bloc.dart + part event.dart/state.dart
        widgets/            screen.dart, локальные компоненты
      auth/, rankings/, beatmaps/, news/
  packages/
    tracksu_network/        transport, options, network exceptions
    tracksu_models/         только действительно общие чистые модели
    tracksu_storage/        typed preferences и secure token storage
    tracksu_ui/             единый UI kit, theme/tokens
    tracksu_l10n/           ARB, Flutter localization generation
    tracksu_analytics/      чистый контракт клиента/событий, без Firebase SDK
    tracksu_utils/          только подтверждённые общие helpers
```

Это целевая карта, не команда создать все пустые пакеты. Workspace на P02,
network/models на P06, analytics contract на P06.1, UI на P07, l10n на P07.1,
secure storage на P08; utils — по
реальной необходимости. Каждый package использует `resolution: workspace`,
узкий `lib/tracksu_*.dart` и `publish_to: none`; чужие `src/` не импортируем.
Flutter workspace расположен в корне repository; это решение закреплено на P02.
На P01 определяем только будущую package graph и границы package/feature, не
возвращаясь к механическому переносу root, CI или assets.

На P01/P06 определить владельцев общих понятий `UserId`, `BeatmapId`,
`BeatmapsetId`, `Ruleset`, `Score` и `Mod`: feature не импортирует внутренние
data/presentation соседней feature. Общие контракты доступны через узкий public
API или обоснованный shared domain; складывать весь domain в `core` нельзя.
Проверку направления imports включить в review/CI.


Базовый вариант моделей — ручные immutable классы/decoder, без обязательного
Freezed/json_serializable; генерация только под конкретную повторяющуюся задачу.
Не строить get_it/injectable/router framework по привычке. P06 реализует лёгкий
REST-клиент по [карте зависимостей](../standards/DEPENDENCIES.md), не весь tsd_network.

<a id="p05-1"></a>

## DI и bootstrap по TSD — P05.1

**Результат:** единая понятная точка создания общих зависимостей, доступ к ним
из composition layer и локальная сборка feature. Отдельный шаг после P05 и до
P06/P06.1; инфраструктурные клиенты и repositories затем подключаются к нему,
не принося каждый свой способ DI.

Образцы уже проверены в TSD: `lib/main.dart`,
`lib/src/_core/dependencies/container.dart`, `scope.dart`, `lib/src/app/main.dart`
и `lib/src/free_tasks/main.dart`. Ссылки и границы переноса — reference/TSD.md.

- Зафиксировать карту зависимостей и lifetime: app-wide infra, session-owned
  ресурсы и route/feature-local объекты. Для каждого — кто создаёт, использует,
  закрывает и что происходит при logout/повторном входе.
- `registerDependencies()` асинхронно создаёт уже нужную общую инфраструктуру
  в явном порядке и возвращает готовый `DepsContainer` с final-полями и
  типизированными зависимостями. Не держать полусобранный контейнер с nullable
  полями, заполняемыми из разных экранов, и не заводить пустые регистрации впрок.
- `DepsScope` — стабильный InheritedWidget по TSD: доступ через `of(context)`
  в composition/UI boundary, `updateShouldNotify: false` для неизменной identity
  контейнера. Это не глобальный state manager: session/locale/theme обновляются
  через своих владельцев и узкие подписки, а не заменой всего контейнера.
- Bootstrap отвечает за однократную инициализацию, начальный экран ожидания,
  ошибку запуска и осмысленный retry. Не запускать registerDependencies из build,
  не создавать параллельные попытки при повторном нажатии. При неудачной/отменённой
  инициализации освободить созданные ресурсы; завершение после dispose не меняет UI.
- `AppMain` размещает только действительно глобальные providers. `XxxMain`
  собирает local SourceImpl → RepositoryImpl → Bloc из общих клиентов;
  первоначальное событие отправляется один раз в provider.create. Перестройка
  экрана не создаёт новый HTTP client, repository или Bloc без смены их владельца.
- Bloc/repository/source получают конкретные зависимости через constructor,
  не весь DepsContainer. Domain не импортирует scope/Flutter и не ищет сервисы
  самостоятельно. Не вводить get_it/injectable, service locator, DI codegen
  или вторую DI-систему ради соответствия названию Clean.
- Creator отвечает за close/dispose. Заимствованный app-wide клиент не закрывается
  отдельной feature; BlocProvider.value не передаёт владение чужим Bloc.
  Предусмотреть освобождение subscriptions/controllers и корректный порядок
  закрытия. Logout очищает session-owned данные/ресурсы, а не пересобирает всю app.
- На P05.1 подключить только существующие зависимости shell и один доступный
  consumer. HTTP/repositories добавляются на P06, analytics — P06.1, session/
  secure storage — P08. Не писать заранее все эти реализации ради DI; временный
  legacy bridge допустим только с конкретным consumer и условием удаления.
- Обновить архитектурную документацию P02.1: схема bootstrap, ответственность
  контейнера/scope, пример добавления shared dependency и feature-local wiring.

**Критерий готовности:** зависимости прослеживаются по constructors; у ресурсов
есть один владелец; bootstrap не повторяется из-за rebuild; один consumer работает
через новый DI без второго параллельного владельца состояния. Исполнитель проверяет
diff/format/analyzer и сборку по scope, пользователь — запуск, ошибку/retry и
переоткрытие consumer вручную. Автотесты и DI test harness не добавляются.
Сейчас только план: исходники DI ещё не создаём.

<a id="p07"></a>

## Design system и UI kit

UI kit создаётся до массового переноса экранов, но не как месячный каталог из
сотни гипотетических компонентов. Сначала делаем tokens и 8–12 примитивов,
затем дополняем kit только после второго повторного использования.

- **Foundation:** semantic colors для light/dark theme, typography scale,
  spacing, radius, elevation, icon size, motion, breakpoints и состояние
  loading/disabled/error. Никаких scattered `withOpacity`, magic numbers и
  прямых цветов osu! в feature widgets.
- **Primitives:** публичные semantic-компоненты `tracksu_ui` в стиле TSD:
  `UiText`, `UiTextField`, button/ink button, image/avatar, surface/card,
  loader/empty/error. Точные имена фиксируем в P07, не заводим параллельные
  семейства `Ui*` и `App*` для одной ответственности.
- **Patterns:** sliver list, paged list, filter sheet, profile header,
  score/beatmap card. Patterns собираются из primitives и не знают об endpoint.
- **Дизайн-документация:** каталог примеров (Widgetbook или отдельная
  demo-route), состояния компонентов для ручного просмотра пользователем.
  Golden tests относятся к отложенному T01.
- **Доступность и локализация:** text scaling, screen-reader labels, contrast,
  touch targets, focus/keyboard и reduced motion. Строки вынести в ARB; набор
  языков согласовать на P01. Даты хранить как время, форматировать в UI с locale;
  числовые значения и проценты не превращать в строки в domain.
- **Адаптация:** согласовать телефон/планшет/landscape, safe areas, клавиатуру,
  длинные username/title и ошибки загрузки изображений. Feature cards остаются
  в feature, пока их повторное использование не требует общей абстракции.
- **Analytics hooks:** кнопки, icon/ink buttons, tabs, toggles, selectable tiles
  и submit-действия поддерживают единый optional interaction callback. Привязка
  типизированного события к нему делается общим helper из P06.1, без ручного
  `FirebaseAnalytics.logEvent` в каждом onPressed. Сам UI kit не знает Firebase,
  названий продуктовых событий или пользовательских данных.

Экран строится из feature patterns и UI kit, а не из 2 000 строк вложенных
`Container`. Это одновременно уменьшает дублирование, rebuild surface и цену
редизайна.

<a id="p07-1"></a>

## Обязательная локализация — P07.1 и каждая feature

Полноценной локализации в старом приложении нет; это необходимая часть нового
продукта для других рынков, а не необязательная полировка. Архитектуру готовим
до переноса auth/profile; UI kit содержит локализуемые контракты, не зашитый язык.

1. На P01 выбрать рынки и языки первой версии, базовую locale и fallback.
   Предложение для старта — английский и русский; список ещё требует выбора
   пользователя. Архитектура допускает добавление языка без переписывания UI.
2. На P07.1 создать собственный l10n package по TSD: ARB, `l10n.yaml`,
   AppLocalizations generation, delegates/supportedLocales и `context.t`.
   Генерацию включить в понятную команду tooling; generated outputs не править.
3. Описать определение языка: явный выбор пользователя → подходящий язык
   системы → fallback. Режим «системный» и сохранённый выбор — отдельные значения.
   Реализовать смену языка и восстановление предпочтения. На P07.1 достаточно
   узкого settings-store контракта; на P08 подключить общую storage реализацию
   и миграцию, не создавать второй вечный StorageController.
4. Каждая P08–P14 сразу переносит свои тексты в ARB для всех выбранных языков:
   кнопки, ошибки, loading/empty, фильтры/rulesets/mods, accessibility labels,
   validation, OAuth/cancel/retry и объяснения разрешений. Не оставлять
   «временные» строки в widgets и не склеивать предложения из фрагментов.
5. Использовать placeholders, plural/select, locale-aware даты, время, числа
   и проценты. Domain возвращает значения и типизированные причины ошибки,
   не локализованные строки. Не переводить пользовательские имена, названия
   карт и чужой контент API так, будто он уже предоставлен на выбранном языке.
6. UI kit не зависит от глобальной app localization: текст и semantic labels
   передаются явно; app/feature выбирают перевод. Компоненты выдерживают длинные
   строки, text scaling и локализованные ошибки без fixed-width допущений.
   Directional layout применять там, где важны start/end; RTL-языки — по scope.
7. На P15 локализовать карточки магазинов, screenshots, About/privacy/support
   материалы и native permission descriptions для рынков релиза. Переводы UI
   и юридических текстов проверяет человек; машинный черновик не объявлять
   подтверждённым. Внешняя OAuth-страница не становится нашим переводимым UI.

**Результат P07.1:** работает localization infrastructure, fallback и выбор
locale в минимальном shell; есть правила ключей/placeholder и подключённые
переводы shell/UI states. Каждая feature имеет собственный l10n acceptance пункт.
Пользователь вручную проверяет переключение, fallback, длинные строки и сохранение
языка после подключения storage. Автотесты локализации тоже остаются в T01.

<a id="p06-1"></a>

## Firebase Analytics и единый клиент действий — P06.1

**Цель:** базовые действия удобно подключаются к аналитике через один контракт,
а не через разрозненные вызовы Firebase по всему UI. Клиент сам добавляет
разрешённый контекст, проверяет payload, учитывает отключение сбора и изолирует
ошибки SDK. Это продуктовая аналитика, не профилирование производительности.

Локальный Lichi просмотрен как дополнительный образец именно аналитики:
`FirebaseAnalyticsService` → `FirebaseAnalyticsEvents`, зависимости через scope,
feature-обёртки вроде AuthAnalytics. В базовом UiButton автоматического tracking
нет; общий hook всех интерактивных компонентов — новая задача Tracksu.
Файлы и ограничения переноса записаны в reference/TSD.md, раздел 8.
Основной архитектурный референс приложения остаётся TSD.

### Архитектура и удобство подключения

- На P06.1 создать небольшой `tracksu_analytics` с чистым `AnalyticsClient`,
  типизированными событиями/параметрами и no-op реализацией. Prefix уточняется
  на P01.1. Firebase adapter и app-level wiring — в `_core/analytics`, клиент
  передаётся через DepsContainer. Domain и UI kit не импортируют Firebase SDK.
- Общий binding/helper превращает typed событие feature в interaction callback
  компонента. На P07 все применимые UI primitives поддерживают одинаковый hook;
  на P08–P14 feature передаёт действие и разрешённый контекст в одной точке.
  Не нужен свой wrapper с повторной логикой для каждой кнопки или отдельный
  ручной вызов клиента рядом с каждым onPressed. Компонент без hook работает
  без аналитики и Firebase, в том числе в UI-каталоге.
- Схема событий и стабильные action/screen IDs задаются явно. Не выводить имя
  события из переведённой надписи, runtimeType виджета, пути с user ID или текста
  поля. UI-компонент сообщает факт взаимодействия; feature определяет его смысл.
- Реестр событий хранит: цель измерения, имя/тип, место и момент отправки,
  владельца, allowlist параметров, privacy-категорию и необходимые dimensions.
  Новые имена/поля проходят review; SDK serialization/ограничения находятся
  только в adapter, не в widgets. Подходящие стандартные Firebase events
  используем по их назначению, остальные — собственные. Для custom parameters,
  нужных в отчётах, запланировать регистрацию dimensions/metrics.
  [Firebase: события и параметры](https://firebase.google.com/docs/analytics/flutter/events).
- Начальное покрытие: открытие экрана/вкладки, login requested/result/logout,
  profile refresh/retry, ruleset/filter change, открытие beatmap, внешней новости,
  preview start/stop, выбор языка/темы — только если эти действия есть в продукте.
  Не измерять каждую перерисовку, ввод символа, строку списка и тик player.

### Семантика и надёжность

- Tap/intent и результат операции — разные события. Кнопка login не сообщает
  `login_success`; его владелец отправляет результат после подтверждения сессии.
  У каждого события один владелец: UI hook либо feature обработчик, не оба сразу.
- Один принятый пользовательский action вызывает одну отправку из приложения.
  Rebuild, replay state, вложенные gesture handlers и повторный listener не
  должны дублировать её. Disabled-кнопка не отправляет tap. Защита от дублей
  не подавляет два самостоятельных повторных действия пользователя.
  Это не обещание exactly-once доставки на сервер.
- Screen views регистрировать из выбранной точки navigation lifecycle; не
  дублировать автоматические и ручные события. Названия маршрутов нормализовать,
  исключив ID, query и callback-параметры; открытие/возврат имеют заданную семантику.
- Отправка не ждёт сеть и не задерживает действие/навигацию; исключение SDK
  обрабатывает клиент, оно не ломает callback и не вызывает UI error/snackbar.
  App должна запускаться и работать при отключённой аналитике. Собственный
  бесконечный retry, polling или второй persistent event queue не строим.
- Общий контекст минимален: версия/build/environment, согласованный screen,
  ruleset/locale при необходимости. Динамический контекст фиксируется на момент
  действия; не хранить BuildContext или весь state в клиенте. Логи dev очищаются
  от чувствительных данных; выключенная аналитика не накапливает события
  «до согласия», чтобы отправить их позже.

### Privacy, окружения и проверка

- До включения согласовать, что собирается и зачем, retention, рынки/consent,
  способ отказа и privacy/store disclosures. Настроить сбор на уровне SDK/native
  до инициализации согласно выбранной политике: одного no-op wrapper недостаточно,
  поскольку SDK имеет автоматически собираемые события. Предусмотреть отключение
  сбора и восстановление выбора пользователя; устойчивое хранение подключить на P08.
  [Firebase: Android collection controls](https://firebase.google.com/docs/analytics/android/configure-data-collection),
  [iOS collection controls](https://firebase.google.com/docs/analytics/ios/configure-data-collection).
- Не отправлять OAuth tokens/codes, username, email, поисковые строки, полный URL,
  raw JSON, сообщения серверных ошибок или произвольные DTO. Постоянный device ID
  и связывание событий с osu! user ID по умолчанию не нужны; их нельзя переносить
  из Lichi автоматически. Ads/attribution/IDFA и другие провайдеры не входят в
  запрос базовой аналитики; отдельно проверить автоматический сбор SDK.
- Разделить dev/debug и production: по умолчанию dev — no-op, при ручной проверке
  пользователя — отдельная согласованная Firebase-конфигурация/DebugView.
  Разработка не засоряет production отчёты. Нужные Firebase app registrations
  привязать к окончательным Android/iOS IDs, не копировать настройки Lichi.
  Консоль, создание ресурсов и включение реального сбора сейчас не трогаем.
- Порядок: P06.1 — клиент/adapter/registry/privacy policy и одна узкая привязка;
  P07 — одинаковые hooks UI kit; P08 — сохранение выбора и session events;
  P09–P14 — согласованные действия каждой feature; P15 — итоговый обзор покрытия
  и disclosures. Пока среда/consent не готовы, интеграция использует no-op.
- Ручная проверка пользователем: событие и разрешённые параметры видны в DebugView,
  нет дубля после rebuild, disabled action молчит, отказ выключает сбор, сбой
  аналитики не мешает основному сценарию. Автотесты не пишем и не запускаем.
  [Firebase DebugView](https://firebase.google.com/docs/analytics/debugview).
- В документации P02.1 поддерживать analytics event catalog и пример подключения
  нового действия; изменения схемы отражать в CHANGELOG, когда они значимы.
  Crashlytics, Performance Monitoring, BigQuery, Remote Config и BFF автоматически
  к этой задаче не добавляются.

**Критерий P06.1:** определены и реализованы в выбранной части контракт, adapter,
no-op, безопасный контекст и единая привязка; поведение вручную подтверждает
пользователь при наличии разрешённой конфигурации. При её отсутствии факт доставки
остаётся непроверенным. Сейчас только добавлен план — SDK не подключался и события
не отправлялись. Критерий P07: подключение к типовой кнопке/вкладке использует
тот же контракт без обращения к Firebase и без копирования tracking-кода.

## Общие стандарты

Кодовый стиль и подключение analyzer — [CODE_STYLE](../standards/CODE_STYLE.md).
Обязательные удаления пакетов и минимальный REST scope — [DEPENDENCIES](../standards/DEPENDENCIES.md).
Правила применяются в соответствующих этапах; их списки здесь не дублируются.

## Подробное содержание работ

<a id="p01"></a>

### P00/P01. Baseline и продуктовый scope

**Результат:** обратимый старт и список того, что приложение вообще должно
делать в первом релизе.

- Уточнить в этом документе платформы, минимальные OS и функции первого релиза:
  guest просмотр, OAuth login, профиль, рейтинги, beatmap, news и решение по
  preview-аудио. Новую копию общего плана не заводить.
- Утвердить архитектурные решения одной страницей (ADR): Clean/DDD rules,
  event-based Bloc, DI boundary, router, UI kit, codegen и strategy для
  feature-by-feature strangler migration. Это защитит от нового слоя
  «архитектуры ради архитектуры».
- Использовать уже выполненную сверку reference/TSD.md и правила standards/SKILLS.md:
  утвердить package graph, расположение workspace, route фасады и явные отличия
  от TSD. Не повторять чтение с нуля, но перепроверять затрагиваемый образец,
  если checkout TSD изменился.
- Нарисовать user journeys и screen map до UI kit: launch/session restore,
  guest, OAuth login/cancel/error, profile, rankings/filter/page, beatmap,
  news, audio, logout. Для каждого указать loading/empty/offline/401/429/error
  state.
- Составить начальный design inventory: все цвета, отступы, типографика,
  controls, card variants, icons, breakpoints и assets. Он станет входом в
  tokens/UI kit, а не поводом копировать текущую вёрстку 1:1.
- Собрать доступные скриншоты ключевых экранов и записать 5–10 ручных сценариев
  для пользователя. Это исходное описание поведения при переносе.
- Зафиксировать текущую ветку/тег и завести отдельную migration-ветку. Не
  переписывать историю и не удалять старые native folders вне Git.
- Уточнить удаление профиля/Tracksu в Google Play по приложенным скриншотам и
  доступный путь verification/support; отдельно выяснить статус App Store.
  Определить нужные платформы. Если desktop/web не являются продуктом, не
  тратить первый цикл на их восстановление.

**Критерий готовности:** есть inventory подписи, user-flow/screen map,
архитектурные ADR, UI inventory и путь назад к текущему коду.

<a id="p02"></a>

### P02. Воспроизводимый современный shell

**Результат:** чистый checkout собирает пустую/минимальную оболочку без секрета
в исходниках.

- Выбрать и закрепить Flutter через FVM (`.fvmrc` или равнозначная конфигурация);
  CI и локальная машина используют одну версию. SDK уже есть локально, поэтому
  сначала проверяем установленные кандидаты и матрицу совместимости plugins.
- Подготовить Pub workspace по TSD: root resolution/lockfile, package manifests,
  единые SDK constraints и analyzer policy, public barrels. Пакеты наполняются
  в своих частях P06–P08, без массового переноса legacy. При смене app root —
  отдельная P02-подзадача на paths/scripts/assets/CI, без изменения поведения.
- `make get` должен вызывать один `fvm flutter pub get` из workspace root.
  Генерацию подключать лишь для реально введённых inputs (ARB и при необходимости
  build_runner); проверять покрытие packages, не копировать устаревшие инструкции
  из TSD CLAUDE.md. Не добавлять Melos или корпоративный CI include без задачи.
- Создать `AppConfig` и template локальной конфигурации без значений. До BFF
  `--dart-define`/CI secret допустимы, чтобы secret не попадал в git, но это не
  делает его секретом в mobile-бинарнике; риск должен быть зафиксирован в ADR.
- Поднять SDK constraint до версии, совместимой с выбранным Flutter, затем
  использовать `flutter pub get`, `dart fix --dry-run`, `flutter analyze` и
  сборку затронутой платформы по необходимости. Тестовые команды не запускаем.
- Подключить [подготовленную Dart 3.13+ policy](../standards/CODE_STYLE.md): совместимый
  flutter_lints в dev_dependencies, один корневой analyzer config, проверенное
  наследование app/packages и formatter выбранного SDK. Подключение и scoped
  механические исправления планировать небольшими коммитами отдельно от
  смыслового рефакторинга. Активный legacy config сейчас не заменяется.
  Реализация UI kit относится к P07.
- Обновлять зависимости группами (сначала Flutter tooling и plugins, затем
  UI) с `flutter pub outdated`; не делать blind `upgrade --major-versions`.
- На P02 начать dependency inventory по standards/DEPENDENCIES.md; отделить обязательные
  удаления от выбора http/Dio и распределить native/UI consumers по P03/P04/P07.
  Само обновление SDK не означает разрешения удалить ещё используемый package.
- Оставшиеся тесты не трогаем до T01; пользовательские удаления не восстанавливаем.
- Добавить технический CI: format check, analyze, Android debug build.
  Unit/widget/integration/golden jobs и тестовые зависимости сюда не входят.
  iOS build можно добавить на macOS runner после появления подписи/симулятора.

**Критерий готовности:** версии закреплены, сборка проходит, analyzer чист или
его известные предупреждения записаны; тестовая инфраструктура не добавлялась.

<a id="p02-1"></a>

### P02.1. README, документация проекта и CHANGELOG

**Результат:** новый разработчик понимает назначение и текущее состояние продукта,
как подготовить окружение и запустить доступную сборку, где искать архитектуру
и что изменилось между версиями. Речь о README самого репозитория, а не только
о README папки `tracksu-agent-ref`.

- Переработать корневой README: согласованные название/позиционирование,
  unofficial status, возможности и ограничения текущей версии, поддерживаемые
  платформы/языки, актуальные screenshots и статус распространения. Не выдавать
  roadmap за уже реализованные функции и не оставлять неработающие store badges.
- Добавить onboarding разработчика: расположение Flutter workspace, закреплённый
  FVM/SDK, необходимые инструменты, получение зависимостей, локальная конфигурация
  по template без секретов, команды генерации/запуска/сборки и частые проблемы.
  Документировать только реально введённые команды, отмечая непроверенные шаги;
  тестовые инструкции сейчас не внедрять, T01 явно обозначить как отложенный.
- README оставить короткой точкой входа со ссылками. В технической документации
  описать package graph/public API, feature-layered структуру, DI/Bloc/state
  ownership, навигацию, UI kit, локализацию, OAuth/API v2, storage migration и
  Android/iOS build/release. Разделы наполнять при реализации соответствующих
  частей, а на P02.1 создать навигацию и описать доступное состояние.
- Для packages добавлять README об ответственности, public API, зависимостях
  и необходимых get/gen командах по мере их появления. Ключевые архитектурные
  решения хранить в коротких ADR; не дублировать большие инструкции между
  корневым README и каждым package.
- Разделить документацию текущего продукта и подготовительный комплект
  `tracksu-agent-ref`: он хранится в репозитории, но остаётся roadmap/рабочим
  журналом, а не README реализованного продукта. Будущая документация
  описывает реализованное состояние, не дублирует этот комплект.
  Определить понятные разделы/ссылки;
  не создавать второй независимый roadmap и не публиковать локальные пути как
  единственный способ прочитать документацию проекта.
- Завести корневой `CHANGELOG.md`: `Unreleased`, затем версии с датами выпуска
  и значимыми изменениями (Added/Changed/Fixed/Removed/Security по необходимости).
  Отдельно отмечать breaking changes, минимальные OS, изменения OAuth/API и
  последствия для локальных данных. Не копировать в него весь git log или
  запланированные работы. Старую историю восстанавливать только по подтверждённым
  релизам/коммитам; неизвестные версии и даты не выдумывать.
- На P15 сверить README/screenshots/ссылки с выпускаемой сборкой, собрать release
  notes из CHANGELOG, заменить Unreleased на фактическую версию/дату только при
  соответствующем выпуске. Публикация остаётся отдельным действием пользователя.

**Критерий готовности P02.1:** README описывает актуальный bootstrap, есть карта
документации и правила CHANGELOG. Ссылки проверены, секретов нет, планируемое
отделено от работающего. Дальнейшие P03–P15 обновляют свои разделы по факту;
пункт документации входит в карточку каждой части. Сейчас только планируем
эту работу — README приложения и CHANGELOG ещё не переписываем.

<a id="p03"></a>

### P03. Android — пересоздать build layer, не application identity

**Результат:** современная Android-сборка сохраняет существующий package и
подпись.

- В отдельном scratch-проекте с тем же Flutter сгенерировать Android template,
  сравнить с текущим и перенести структуру, а не вручную латать AGP 4.1.3.
- Использовать актуальный template Flutter с declarative Plugin DSL, а не
  `apply from: .../flutter.gradle`. Подобный DSL рекомендован Flutter для
  проектов, созданных до Flutter 3.16.
- Подбирать AGP/Gradle/JDK именно из template выбранного Flutter. Не пинить
  случайные «самые новые» версии: например, AGP 9.2 требует JDK 17 и Gradle
  9.4.1, а Flutter 3.44+ отдельно требует миграции от Kotlin Gradle Plugin к
  built-in Kotlin для AGP 9+.
- Сохранить `applicationId`, package MainActivity, versionCode/versionName,
  icon, network permission и release signing. Обновить `compileSdk`/
  `targetSdk` до поддерживаемого выбранным toolchain уровня.
- Явно задать `namespace = io.github.wratheus.tracksu`; согласовать с ним
  `applicationId`, `package` MainActivity, путь
  `src/main/kotlin/io/github/wratheus/tracksu/`, ссылки
  на activity в main/debug/profile manifests и R/BuildConfig imports. Старые
  manifest package attributes обработать по новому template. Удалить устаревший
  template TODO про `com.example`, не переименовывая опубликованный app ID.
- Native host и новый platform code — Kotlin; Java-конверсия MainActivity не
  нужна, она уже Kotlin. Если появятся собственные plugins, их package/namespace
  получать из согласованной naming-схемы, не оставлять `com.example.*`.
  Kotlin DSL (`.gradle.kts`) и Kotlin source — разные решения: для build scripts
  следовать выбранному Flutter template. TSD сейчас использует Groovy Gradle,
  это не причина воспроизводить его переходные compatibility flags.
- Если захочется изменить технический namespace, оформить это отдельно от
  `applicationId` с точной картой переименований. Новый красивый app ID нельзя
  подставлять без решения о потере совместимости обновления старой установки.
- Удалить deprecated `lintOptions`, `kotlin-stdlib-jdk7`, Java 8 и legacy
  configuration только после зелёного debug/release build.
- Использовать штатный renderer выбранного Flutter. Проверить Impeller и
  предусмотренный Flutter fallback на поддерживаемых Android-устройствах;
  не фиксировать старый renderer для всей app как универсальное решение лагов.
  [Flutter Impeller](https://docs.flutter.dev/perf/impeller)
- Проверить итоговые native `.so` и упаковку APK/AAB на поддержку 16-КБ страниц
  памяти, затем запуск на соответствующем emulator/device. Нового Gradle самого
  по себе недостаточно для несовместимых native libraries из plugins.
  [Android 16-КБ compatibility](https://developer.android.com/guide/practices/page-sizes)
- Проверить edge-to-edge/insets, system back/predictive back, Android splash,
  внешние ссылки и возврат из browser. Минимальная OS и тестовые устройства
  фиксируются до UI-миграции.
- Перенести launcher icons/splash в собственные native resources по
  standards/DEPENDENCIES.md. Отказ от генераторов не удаляет иконку/launch screen;
  удаление общих packages/config согласовать с готовностью iOS на P04.

**Критерий готовности:** debug устанавливается на эмулятор; signed APK
проверяется через `apksigner`, AAB — инструментами для bundle. Update-тест
использует APK с совместимым app signing certificate. Для Play App Signing
финальную доставку AAB/upgrade через внутренний store track проверяем на P15.

<a id="p04"></a>

### P04. iOS/macOS — новый native shell и SPM

**Результат:** новый iOS host project, а не попытка оживить deployment target
9.0 и старый Pods setup.

- Legacy `ios/` удалён отдельным P00 commit после inventory и прямого решения
  владельца. При возвращении iOS в scope не восстанавливать его как основу:
  начать с чистого Flutter shell и при необходимости обратиться к Git history
  только за конкретной настройкой/asset.
- В отдельной ветке/каталоге с тем же Flutter создать чистый iOS shell,
  восстановить только Bundle ID, signing team, entitlements, Info.plist
  permissions, icons и минимально нужные URL/deep-link settings.
- Выбрать реалистичный minimum iOS deployment target по поддержке актуальных
  Flutter plugins и продуктовой аудитории; iOS 9 не переносить.
- Для Flutter 3.44+ предпочесть Swift Package Manager: Flutter перешёл на SPM
  как основную стратегию для native iOS/macOS dependencies, CocoaPods остаётся
  для обратной совместимости. Сделать чистый `pod`-free build на симуляторе и
  устройстве.
- Если конкретный plugin ещё не поддерживает SPM, сначала обновить или заменить
  plugin. CocoaPods допустим лишь как явно зафиксированное временное исключение,
  а не как причина оставить весь старый Runner.
- macOS либо включить в такой же SPM-proof, либо формально исключить из v1
  migration, чтобы не поддерживать полурабочую платформу.
- Сохранить Keychain access group/service/accessibility либо подготовить явную
  миграцию на P08. Проверить lifecycle/scene integration из template выбранного
  Flutter, штатный renderer, privacy manifests зависимостей и обработку callback
  при холодном запуске/возобновлении.
- Подготовить AppIcon/launch screen без flutter_launcher_icons и
  flutter_native_splash. После готовности Android и iOS убрать оба генератора
  и их YAML config, сохранить нужные assets и инструкцию обновления ресурсов.

**Критерий готовности P04:** simulator/device shell и локальная проверка signed
archive с прежним Bundle ID. Login и storage проверяются после P08; загрузка
в App Store Connect/TestFlight относится к подготовке beta на P15.

<a id="p05"></a>

### P05/P06/P08. OAuth и транспорт — security boundary до UI-рефакторинга

**Результат:** токены и сетевые ошибки не текут в логи, транспорт отделён от
Flutter-виджетов и управления состоянием экрана.

- Немедленно удалить текущие `print` access/refresh token и исключения, которые
  включают refresh token. В production использовать редактируемый structured
  logging без PII/credentials.
- **Решение текущей программы:** BFF не строим. В `flutter_secure_storage`
  храним access token, refresh token, expiry и минимальную session metadata.
  Client secret не коммитим и не логируем, передаём только через local/CI build
  configuration. Это защищает репозиторий и токены at rest, но не скрывает
  client secret от владельца мобильного бинарника — явно оставляем как debt.
- До внешнего тестирования зарегистрировать/перепроверить OAuth redirect URI,
  `public identify` scopes и владельца osu! приложения. `redirect_uri` должен
  совпадать с registered callback буквально; `state` генерируется криптографически
  случайно и валидируется при возврате.
- Исходники подтверждают: GitHub Pages был пустым callback landing page, code
  извлекался из URL WebView, token exchange выполнялся в Dart. Отдельного auth
  backend в index.html нет. Детали, хрупкий parsing и ограничения проверки
  live-сайта — reference/AUTH_CALLBACK.md; на P05 не исследовать всё заново без причины.
- Полностью убрать legacy WebView/GitHub Pages flow. При этом не следует делать
  «свою страницу входа» с osu! логином и паролем: credential/consent screen
  обязан остаться на домене osu!. Наш UI — это screen «Continue with osu!»,
  progress/error/cancel и post-login профиль. Сам авторизационный экран
  открывается в системной auth session (ASWebAuthenticationSession / Chrome
  Custom Tabs), не в `webview_flutter`.
- Отдельный auth spike проверит callback: принимаемый osu! custom scheme либо
  HTTPS Universal Link/App Link на контролируемом домене, возврат в Android и
  iOS, cancel и state mismatch. Свой entry UI и callback реализуем; необходимость
  собственной статической fallback-страницы решаем по выбранному flow. Старый
  Pages URL не остаётся обязательной зависимостью нового login-path; хостинг
  нового HTTPS-варианта ещё не выбран. HTML не хранит secret и не заменяет BFF.
- Legacy Pages source (`index.html` и `web_assets/`) удалён из repository по
  явному решению пользователя на этапе workspace migration. Это не доказывает,
  что внешний Pages deployment, OAuth registration или старые установки уже
  отключены: их не меняем до P05 и отдельного решения о cutover.
- Вынести в `AuthRepository`/`TokenStore`: expiry (`expires_in`), сериализацию
  refresh, один shared refresh на параллельные 401, logout/clear и typed
  `AuthFailure`. Не обновлять токен «на любой 400».
- На P06 выбрать http либо Dio и создать свой лёгкий REST-клиент через DI;
  заранее закреплённый http.Client больше не является решением плана.
  Минимальные возможности и границы — standards/DEPENDENCIES.md. Osu endpoints/DTO
  остаются в data, auth/session подключаются на P08, transport не знает UI.
- Обработать не только 401: timeout/offline, 403/scopes, 404/restricted user,
  429 с ограниченным backoff и Retry-After при его наличии, 5xx, invalid JSON.
  Ошибки `/me` не должны подменять текущего пользователя профилем Peppy.
- При смене аккаунта/logout отменять или игнорировать старые запросы, очищать
  session-scoped cache и данные в памяти. Auth callback проверяется при cold
  start, warm start, повторной доставке и закрытии auth session пользователем.
- Только после прохождения security/auth smoke reset client secret в osu!
  application, убрать старые local credentials и выпустить версию с forced
  re-login. Reset отключает уже выданные приложению токены, поэтому он должен
  быть осознанным release cutover, а не случайной настройкой в середине работы.

**Критерий готовности:** описаны login/cancel/expired token/refresh failure/
logout; реализация проверена статически и передана пользователю для ручного
подтверждения Android/iOS callback. Секретов нет в git, логах и примерах данных.

<a id="p08"></a>

### P00/P08/P15. Обновление уже установленного приложения — P00/P08/P15

Сейчас `UserSecureStorage` использует ключи `access_token`, `refresh_token`,
`user_me_avatar`, `user_me_username`. Secure storage уже существует; задача —
правильно перенести его на новые версии plugin и новый lifecycle сессии.

- Зафиксировать формат/настройки старого хранилища, версию Android encryption,
  iOS Keychain attributes и правила backup/restore. Проверить migration guide
  именно выбранной версии `flutter_secure_storage` перед major upgrade.
- Определить versioned migration: сохранение поддерживаемых значений, очистка
  устаревшей session metadata или явный повторный вход. Работа должна быть
  идемпотентной и выдерживать остановку приложения посреди миграции.
- Прогнать установку поверх последнего доступного release: валидная/истёкшая
  сессия, отсутствующие/нечитаемые записи, fresh install, backup restore.
  Нельзя требовать от пользователя «удалить приложение, чтобы заработало».
- Отдельно определить, какие данные сохраняются при logout и смене аккаунта.
  Кэш другого пользователя не должен отображаться новому пользователю.
- Возврат commit не откатывает изменённые данные на устройстве. Совместимость
  формата хранения и сценарий исправляющего релиза фиксируются отдельно.

<a id="api"></a>

### P05 и перенос feature. Контракт osu! API v2 и модели

**Результат:** API меняется в одном слое, а пользователь видит понятные ошибки
и актуальные данные.

Задействованы как минимум `/oauth/token`, `/users`, `/me`, user scores, news,
beatmap, beatmap scores, rankings и user beatmapsets. Большинство путей всё ещё
существуют, но модели и семантика менялись.

- Изучить контракт и обезличенные примеры JSON нужных endpoints: normal,
  empty, 401/429/5xx и отсутствующие optional поля. Примеры используются как
  документация; mock transport и автоматические проверки сейчас не пишем.
- Разрабатывать DTO/decoder каждой feature по подтверждённому контракту.
  Различать краткий и расширенный ответ User, Beatmap и Beatmapset. В 2023 году
  документация переименовала compact/extended типы; само переименование не
  доказывает изменение JSON, его проверяем по используемым endpoints.
- Заменить deprecated `key=username` при Get User: по текущей документации для
username нужен `@`-prefix. Учитывать username с цифрами, пробелами и URL
encoding; перечислить их в ручных сценариях.
- Явно решить, показываем ли legacy или lazer scores. Для beatmap scores
зафиксировать `legacy_only`, mode/ruleset и mods, а не молча полагаться на
server defaults. Проверить response на новые score поля.
- Явно выбрать `x-api-version` и соответствующие DTO; отдельно проверить
  идентификаторы legacy/lazer scores, формы mods и статистику для osu/taiko/
  fruits/mania. Не смешивать правила разных response versions в одном decoder.
- Определить источник истины для pp/accuracy/rank: отображать серверные данные,
  различать `null` и ноль, не добавлять локальный pp calculator в миграцию.
- Исправить все циклы с `length - 1`, pagination/cursor и empty collections.
- Ограничить параллелизм (например, mapper lookup у favourite beatmaps),
кэшировать неизменяемые справочники и показывать partial/empty state вместо
общего exception dialog.
- Записать cache policy каждого repository: ключ (ID/ruleset/filter/session),
  TTL, предел размера, refresh/invalidation. Offline UX сначала может состоять
  из последнего доступного content и retry; отдельная offline database не
  добавляется без продуктовой необходимости. Не делать новый user lookup,
  когда стабильный user ID уже известен.
- Для new/unknown enum values предусмотреть безопасное отображение. Разделять
  beatmap ID и beatmapset ID, не переносить `dynamic`-поля из старых models.

**Критерий готовности:** repository/DTO соответствуют описанному контракту;
пользователю переданы ручные сценарии четырёх ruleset и ошибок. Результат
реального использования API подтверждает пользователь.

<a id="rights"></a>

### P01/P15. Rights, attribution и privacy review

**Результат:** продукт не выдаёт себя за официальный osu! client, не тащит в
релиз assets с неясными правами и честно объясняет обработку пользовательских
данных. Это product/legal review, а не юридическое заключение.

- Собрать `THIRD_PARTY_ASSETS.md`: для каждого bundled icon, flag, font, logo,
  splash image и пакета — source URL, owner, licence, allowed distribution,
  required attribution и решение retain/replace/remove. В README уже есть
  ссылка на `ppy/osu-resources`; этого недостаточно, так как в нём ресурсы и
  брендинг имеют отдельные ограничения.
- Не брать дизайн, game artwork, icons или другие resources из osu! репозиториев
  «раз они на GitHub». Проверить каждый asset; при неясном происхождении
  заменить его собственной/лицензированной альтернативой.
- Проверить выбранное новое название продукта/разработчика, store listing,
  iconography и тексты на trademark
  risk. На экране About/store page добавить понятное `Unofficial, not affiliated
  with osu!/ppy` и ссылки на osu! / API. Если использование marks необходимо
  для релиза, получить письменное разрешение или изменить branding до выпуска.
- Для данных beatmap показывать корректные title/artist/creator и ссылку на
  исходную страницу osu!. Не скачивать и не распространять музыку, обложки и
  user content как собственные bundled/offline assets; preview-аудио проходит
  отдельную проверку policy/terms и может быть исключено из первого релиза.
- Написать privacy notice до login: что хранится локально (OAuth tokens,
  минимальная session metadata), что отправляется в osu!, нет ли analytics,
  как работает logout/clear data. В app добавить About, Privacy и Terms links.
- Перед публичным релизом отдать итоговый inventory и store texts на короткий
  review владельцу/юристу либо запросить clarification у ppy по branding/API
  use. Не утверждать совместимость/лицензию без такого подтверждения.

**Критерий готовности:** нет asset без provenance, есть approved store/About/
privacy texts и явно принято решение по osu!/ppy branding и audio preview.

<a id="features"></a>

### P09–P14. Переписывать feature за feature, не весь `lib/` одновременно

Порядок выбран так, чтобы каждая новая feature могла жить рядом со старой, пока
не будет заменена полностью:

1. app bootstrap, router и foundation первого UI kit;
2. `auth` и session restore;
3. `profile` (профиль и user scores) — здесь уйдут два самых больших файла;
4. `rankings` с фильтрами, отменой старого запроса и пагинацией;
5. `beatmaps` и leaderboard;
6. `news`;
7. audio preview как отдельный controller/service с корректным lifecycle.

Для каждой feature:

- сначала repository и DTO по контракту;
- затем Bloc events/states и явные правила переходов;
- затем один UI flow с локальными подписками;
- сразу локализовать новый flow через P07.1 для всех согласованных языков;
- после проверки diff/analyzer/сборки переключить route для ручного просмотра;
- пользователь проверяет сценарий и сообщает о проблемах;
- только потом удалить соответствующий legacy screen/DTO/request code.

`BlocProvider` создаётся выше route, стартовое событие отправляется один раз
при создании (`..add(LoadRequested())`) или в `initState`, но не из `build`.
Навигация живёт в `AppRouter`/`NavigatorPage`/`NavigatorModal` и UI listener,
не в Bloc. По TSD базовая организация — центральный Navigator 1 facade с
typed params. Сохранение tabs/backstack и возврат OAuth — явные требования;
другой router вводим только если выбранный вариант их не покрывает, по ADR,
а не одновременно с переносом очередной feature.

Зафиксировать владельца и lifetime каждого Bloc: session, route, отдельная
секция. Переключение вкладок сохраняет scroll/query/ruleset; возврат с beatmap
в профиль сохраняет контекст. Маршруты принимают стабильные ID, не mutable
DTO/целые widgets. Dispose освобождает subscriptions, controllers и ресурсы.

HTML из новостей/профилей обрабатывается по явной политике: поддерживаемые теги,
запрет произвольных URL-схем, открытие внешних ссылок и fallback для битых media.
Загрузка HTML/images не должна блокировать весь profile state.

### Границы обновлений — для каждой feature

Применять разделы 8 и 13 [регламента](../workflow/PLAYBOOK.md): в карточке
показывать источник обновления, прежнего/нового владельца и затронутое поддерево.
При refresh сохранять content, ленивые списки и scroll. Проверка поведения —
пользователем; отдельный profiling/benchmark этап не вводим.

<a id="p15"></a>

### P15. Выпуск и сопровождение

- Актуализировать README, технические документы, screenshots и CHANGELOG;
  подготовить release notes по правилам P02.1, не объявлять релиз до его выпуска.
- Release checklist: versioning, signed Android/iOS archive, install-over-old
  build, fresh install, upgrade install, login/logout, offline/401/429, four
  modes, accessibility and deep link.
- На P00 сверить причину удаления из Play с Console; на P15 подготовить решение
  найденных замечаний, актуальные screenshots/description, privacy/data-safety
  сведения, зависимости privacy manifests и доступ reviewer к тестовому flow.
  Реальные требования stores перепроверять на дату выпуска.
- Сначала internal beta/TestFlight с согласованным кругом устройств и
  сценариями, затем ограниченный rollout. До загрузки подготовить пакет,
  наблюдаемые критерии остановки и исправляющий релиз. Это запланированные
  шаги; публикация и приглашение тестеров требуют отдельного действия.
- Перед rotation уточнить, перевыпускаем пользовательские tokens или общий
  OAuth client secret. Не смешивать с Android signing keys/Apple certificates;
  их обновление не является частью OAuth migration.
- Проверить события Firebase Analytics и privacy/consent по P06.1; реальный сбор
  включается только по принятой политике. Crash reporting — отдельное решение,
  не часть базовых action events; OAuth data/username не попадают в breadcrumbs.
- Dependabot/Renovate либо отдельная задача обновления Flutter/AGP/plugins/API
  contract. Автоматический тестовый контроль API относится к будущему T01.

<a id="t01"></a>

## T01. Автотесты — отдельная отложенная часть

Статус: `deferred`. Сейчас за неё не берёмся и не выполняем её параллельно с
рефакторингом. Точный объём определяется отдельно после выбора этой части
пользователем. Тогда можно рассмотреть DTO/repository/Bloc, widget/integration
и visual tests и соответствующий CI; состояние старых тестов перепроверить тогда.

До этого выбора не пишем тесты, mocks, test fixtures/harnesses и тестовые jobs,
не проводим массовую замену существующих тестов и не запускаем тестовые suites.
Демонстрационные данные UI при необходимости остаются частью каталога примеров,
а не основанием создавать тестовый framework. Ручная проверка — за пользователем.

## Внешние основания

- Flutter рекомендует declarative Gradle Plugin DSL для legacy проектов;
  template Flutter 3.16+ уже использует этот путь: <https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply>.
- Для AGP 9+ Flutter документирует переход от Kotlin Gradle Plugin к built-in
  Kotlin: <https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin>.
- Flutter 3.44+ использует Swift Package Manager как основную стратегию iOS/
  macOS dependencies; CocoaPods остаётся для compatibility:
  <https://docs.flutter.dev/packages-and-plugins/swift-package-manager>.
- Текущая документация osu! API v2, включая OAuth, endpoint contracts и breaking
  changes: <https://osu.ppy.sh/docs/>.
- osu! Terms/Copyright policy и ограничения использования user content:
  <https://github.com/ppy/osu-wiki/tree/master/wiki/Legal>.
- Проекты ppy отдельно предупреждают, что `osu!`/`ppy` branding защищён
  trademark law, а ресурсы имеют свою лицензию:
  <https://github.com/ppy/osu-resources>.
