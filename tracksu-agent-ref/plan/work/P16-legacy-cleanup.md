# P16 — удаление неиспользуемого legacy

2026-09-06 · первый срез: удаление старого графа страниц и зависимостей.

## Границы до изменения

Исходная точка 813a11f: новые profile/rankings/beatmap/news routes подключены,
scoped analyze и debug APK проходят, ручная приёмка остаётся пользователю.
Дизайн/темизация на паузе. STITCH_DESIGN_PROMPT.md не относится к этому коммиту.

Проверен граф import/export/part отсюда: lib/main.dart → BootstrapApp → AppMain
→ appRouter → guest/profile, rankings/spotlights, beatmap, news и LoginScreen.
45 tracked Dart-файлов в старых pages/models/requests/widgets/utils недостижимы
из entrypoint и не имеют входящих импортов из сохраняемых файлов. Старые Home,
drawer, error, Cubit и widgets ссылаются друг на друга, но это отдельный граф.
Удаление только одного news-файла ломало бы его; удаление всего графа — нет.
Внешние Dart-consumers вне lib также проверены поиском импортов.
Ignored environment generation не читалась: при обходе это лист графа.

Сохраняем живые pages/authorization_page.dart и utils/color_contrasts.dart.
В этой части не переносим и не меняем их логику/цвета. Не удаляем assets,
не меняем подпись, OAuth, persisted tokens, preferences или .env.
Удаление старого UserSecureStorage — удаление неиспользуемого исходника,
а не очистка secure storage на устройстве.

Удаляем вместе со старыми consumers прямые app-зависимости
curved_navigation_bar, fluttericon, cached_network_image, audioplayers, provider.
Транзитивные зависимости HTML/Bloc могут остаться в lock; это ожидаемо.
Audio preview в текущем shell отсутствует и остаётся будущим P14.

## Критерии и откат

- Нет импортов удалённых файлов в сохраняемом коде.
- Проверка analyze всего lib и workspace packages, debug APK; без автотестов.
- Diff не меняет активные экраны/палитру; pub get не обновляет оставшиеся версии.
- Обновлены roadmap, README и changelog; ручной smoke — пользователю.
- Все удалённые файлы tracked и доступны в Git до этого коммита. Откат через
  revert scoped commit восстанавливает граф и manifest/lock, storage не мигрирует.

## Намеченные после первого среза части

1. Перенести и привести активную legacy authorization presentation к auth
   feature, сохранив текущий OAuth flow; отдельно разобрать её lifecycle/ошибки.
2. Сохранять clean analyze всего lib/packages при переносе авторизации.
3. Аудит usage/веса/прав assets без редизайна. Палитру и темы не менять до P07.

## Результат проверки

После удаления `fvm dart analyze lib packages/tracksu_network/lib
packages/tracksu_storage/lib` — No issues found. Offline pub get не изменил
версии сохранённых пакетов: удалены audioplayers и его 6 platform packages,
curved_navigation_bar/fluttericon; cached_network_image/provider стали transitive.
Форматирование не запускалось: сохраняемые Dart-файлы не редактировались.
Автотесты не запускались/не изменялись. Ручную приёмку P09–P13 не объявляем
выполненной: основание этого удаления — отсутствие достижимости и consumers,
по текущему поручению пользователя убрать legacy; не демонтаж активного пути.

Ручной smoke: guest → профиль/score/карта → назад; рейтинги/spotlights → игрок;
новости → статья → оригинал; account → браузерный вход/возврат и выход.
Внешний вид должен оставаться прежним. Assets, шрифты, токены и настройки
не удалены. Исторический player восстановим из Git при работе над P14,
если понадобится разобраться в старом поведении, а не держим dead code в app.

`fvm flutter build apk --debug --no-pub` успешно собрал APK после удаления
плагинов. `git diff --check` чистый. Прежнее предупреждение Gradle native access
на JDK 25 остаётся. В сохраняемых Dart-файлах ноль изменений; из legacy imports
остались только appRouter → authorization_page и AppMain/LoginScreen → palette.

## Второй срез — активная авторизация перенесена в auth

2026-09-06 · исходная точка 6c187ac. По отдельному подтверждению пользователя
перенесён живой сценарий, а не просто переименован файл. AuthMain собирает
локальный AuthorizationRepositoryImpl и AuthorizationBloc, переиспользуя общий
AuthRepository/transaction store/callback source. Screen передаёт lifecycle,
отображает sealed states и выполняет success navigation через listener/router.
Подписка и fallback timer принадлежат Bloc; pending store/browser/random state
и URI construction — repository. Client secret не передаётся в presentation.

Сохранены callback URL, scopes public identify, внешний браузер, формат storage,
10-минутный срок pending transaction, 2-секундная отсрочка ошибки после возврата
без callback, переход в guest shell с очисткой back stack. Cold callback
восстанавливает существующий state, не начинает новый login. Закрытие route
отменяет timer/subscription, но не удаляет pending transaction для cold callback.
Уже начатый обмен в общем AuthRepository не становится отменяемым этим переносом:
он может завершить сохранение сессии после закрытия экрана, но экран не навигирует.

Намеренные исправления при выделении состояний:

- preparing блокирует второй start до записи pending transaction;
- completing игнорирует дубли callback и не запускает повторный exchange;
- поздний отказ browser launcher не перезаписывает завершение callback;
- очистка pending awaited, исключения не остаются в unawaited Future;
- посторонние app links не отменяют ожидание; cold malformed callback — ошибка;
- callback проверяет стандартный HTTPS port; pending из будущего отклоняется;
- наружу уходят типизированные ошибки, не URL/code/token и тексты SDK исключений.

Старый LoginScreen и pages/authorization_page.dart удалены; пустая pages также
удалена. В UI сохранены палитра, кнопка и размеры отступов; вместо английских
литералов используются уже существующие en/ru строки. Генерация не требовалась.
Skills feature/Dart/UI/quality определили разделение ownership, listener и
проверки. Дизайн/UI kit и assets не затронуты.

Проверки: scoped format, `fvm dart analyze lib packages/tracksu_network/lib
packages/tracksu_storage/lib` — No issues found; debug APK (--no-pub) собран.
Прежнее Gradle native access warning остаётся. Автотесты не писали/не запускали;
живой OAuth на устройстве не проверен. Ручной checklist: вход с/без браузерной
сессии, быстрый callback, отмена/назад, retry, cold callback после закрытия app,
повтор callback, выход со страницы во время запроса и en/ru.

Откат — revert отдельного auth-refactor commit; storage schema неизменна.
Пользовательская правка пробелов pubspec.yaml и промпт Stitch в commit не входят.
