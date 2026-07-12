# Зависимости: удаление лишнего и лёгкий REST-клиент

2026-09-04 · статус: планирование, зависимости приложения не изменены.

Это детализация существующих P02–P08 из [плана](../plan/DETAILS.md), не новая
параллельная очередь. Удаление выполняем небольшими частями по
[регламенту коммитов](../workflow/PLAYBOOK.md), вместе с документацией.

## Обязательная карта замен

Версии ниже — текущие declarations legacy, а не версии для новой app.

| Зависимость | Решение и замена | Когда |
| --- | --- | --- |
| `curved_navigation_bar: ^1.0.3` | Удалить. Навигационный компонент своего UI kit на Flutter primitives; штатный NavigationBar — кандидат, дизайн решаем на P07. Сохранить tab/back behavior, состояние вкладок и accessibility, не воспроизводить старую анимацию автоматически | P07, при переносе app shell/navigation |
| `fluttericon: ^2.0.0` | Удалить. Единый semantic icon API в UI kit, небольшой согласованный набор SDK icons/собственных разрешённых assets вместо зависимости на весь каталог | API — P07; profile consumers — P09/P10; удаление после последнего consumer |
| `cupertino_icons: ^1.0.5` | Удалить. Использовать ту же icon policy; не добавлять обратно ради одного значка | P02 после полного поиска usages либо P07, если обнаружатся consumers |
| `flutter_native_splash: ^2.2.13` | Удалить генератор и его YAML-конфиг после переноса splash в поддерживаемые Android resources. Если iOS вернётся в scope, добавить его resources в P04 | P03; P04 только при возврате iOS |
| `flutter_launcher_icons: ^0.10.0` | Удалить генератор и legacy `flutter_icons` config после подготовки native icon resources и инструкции их обновления. Наличие Android icon обязательно | P03, с учётом naming/assets P01.1 |
| `http: ^0.13.5` | Старую версию не переносить в целевой stack. Выбрать актуальный совместимый `http` либо Dio; поверх выбранного транспорта — собственный небольшой REST-клиент. Удаление самого `http` условно, в отличие от пяти строк выше | Критерии — P02/P05; решение и клиент — P06; auth wiring — P08 |

На момент чтения: `home_page.dart` импортирует curved_navigation_bar,
`user_widget.dart` — fluttericon/FontAwesome5, `requests.dart` — http.
Поиск `CupertinoIcons` в `tracksu/lib` usages не показал; перед удалением
перепроверить весь актуальный source/config, а не полагаться на старый аудит.
Оба генератора сейчас объявлены в dependencies, их конфигурации находятся
в pubspec. Простое перемещение в dev_dependencies не завершает задачу удаления.

Исходные файлы: [pubspec](/Users/aleksandrpavlenko/Projects/tracksu/tracksu/pubspec.yaml),
[навигация](/Users/aleksandrpavlenko/Projects/tracksu/tracksu/lib/src/pages/home_page.dart),
[профиль](/Users/aleksandrpavlenko/Projects/tracksu/tracksu/lib/src/widgets/user_widgets/user_widget.dart),
[старые запросы](/Users/aleksandrpavlenko/Projects/tracksu/tracksu/lib/src/requests/requests.dart).

## Иконки и splash: что не теряем при удалении генераторов

- До замены собрать inventory ресурсов и ссылок manifest/theme/asset catalog.
  Сохранять source artwork и воспроизводимые размеры/варианты; не удалять
  generated native resources только потому, что удаляется package-генератор.
- Android: подготовить согласованные launcher/adaptive resources и настройки
  launch theme для выбранных OS. iOS: AppIcon asset catalog и launch screen.
  Проверить day/night, clipping, первый кадр и отсутствие старого брендинга.
- Пользователь вручную проверяет cold launch и иконку на обеих платформах.
  Signing, applicationId/Bundle ID и upgrade identity не менять ради assets.
- Для обычных и брендовых значков составить карту старый символ → новый asset.
  Разрешения/attribution проверяются отдельно; удаление font package не даёт
  права автоматически скопировать его glyphs. Старый MyFlutterApp/font asset
  — отдельный inventory, не удаляется по совпадению темы «иконки».
- Описать обновление icon/splash без этих двух генераторов в README/технической
  документации P02.1. Новый generator/package или собственный сложный pipeline
  не добавлять автоматически вместо удалённого.

## Собственный REST-клиент: объём решения P06

Из TSD берём границу RestClient, DI и типизированные ошибки. Не назначаем
Dio обязательным только потому, что он в tsd_network. До реализации записать
короткий ADR: требования текущих osu! endpoints, выбранный transport и почему
его достаточно. Сравнить стоимость необходимого wrapper-кода и поддержки,
а не объявлять вариант «лёгким» только по числу прямых dependencies.

`http` позволяет строить композицию вокруг Client; Dio предлагает готовые
interceptors, cancellation и timeout-настройки. Проверить нужные возможности
на выбранных версиях/адаптерах; не считать, что отмена возможна только в Dio.
Официальные описания: [http](https://pub.dev/packages/http),
[Dio](https://pub.dev/packages/dio). SDK-вариант навигации:
[NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html).

Минимальный scope:

- Один небольшой transport contract и одна реализация в network package.
  Не писать собственный HTTP engine и не поддерживать две реализации «на будущее».
  Клиент создаётся через DI P05.1, имеет явного владельца/close, не создаётся в build.
- Корректное формирование URI/query, headers и только нужных методов/body types;
  JSON/form encoding по подтверждённым контрактам API/OAuth. Base URI и auth
  credentials ограничены своим origin; bearer token не отправляется на произвольные
  URL картинок/новостей или внешний redirect. Не отключать TLS verification.
- Timeout, typed response с нужными status/headers, transport errors со stack
  trace. DTO/endpoint mapping — feature data; repository переводит ошибки в
  domain Failure. Dio/http types, JSON и transport options не попадают в Bloc/domain.
- Отмена запроса, где её поддерживает выбранный adapter, плюс обязательное
  игнорирование устаревшего ответа по query/session. Timeout ожидания не считать
  доказательством прекращения сетевой операции. Дедупликация зависит от сценария,
  универсальный request scheduler не нужен.
- Ограниченная политика 429/Retry-After и transient failures. Без бесконечных
  retries и автоматического повторения любого POST/token exchange. В P06 описать
  границы replay; auth/session P08 добавляет один shared refresh на параллельные
  401, ограниченное повторение допустимого запроса и защиту от refresh-loop.
  Отмена/истёкшая session не перезапускаются retry-цепочкой.
- Логи без tokens/codes/secrets, заголовков авторизации и полного тела ответов.
  Клиент не управляет snackbar, navigation, глобальным loader или analytics UI.

Не переносим заранее весь TSD RestClientOptions/response model, showLoader,
серверные envelope/error codes, корпоративные headers, upload/download/multipart,
offline queue, transport cache, certificate pinning или interceptor framework.
Добавлять capability только с конкретным consumer/требованием. Cache policy
остаётся у repository, auth/session — у своего владельца; интерфейсы этих
границ не превращаются в единый «умный клиент на всё».

## Безопасное выполнение и готовность

Для каждой замены планировать checkpoint: минимальная замена и consumer →
ручная проверка пользователя → удаление оставшегося legacy/package/config.
Неразделимые правки manifest/resources делать атомарно; независимые UI/native/
network задачи не склеивать в один dependency cleanup commit.

При переходе на Dio прежний http может временно остаться только у явно
перечисленных legacy consumers с этапом удаления. При выборе http обновить его
до совместимой версии и убрать прямые вызовы из feature UI/старого requests
после переноса consumers. Не требовать отсутствия транзитивного http в lockfile,
если он нужен другому оставшемуся пакету: различать свою dependency и чужую.

Готовность: пять исключаемых packages не используются и не объявлены ни в app,
ни в своих workspace packages; лишние imports/config/scripts удалены, native
resources сохранены, icon/navigation replacement проверен пользователем.
Выбор http/Dio зафиксирован, новый REST path отделён от UI/domain, временные
consumers учтены. Lockfile обновляется package manager, не ручным вырезанием.
Diff/format/analyze/build — по scope; автотесты не писать и не запускать до T01.
Сейчас package removal, генерация, сборка и реализация клиента не выполнялись.
