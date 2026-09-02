# Tracksu

Неофициальный Flutter-клиент для просмотра статистики osu!. Проект проходит
поэтапную переработку; это рабочая Android-версия, не готовый новый релиз.

## Что сейчас доступно

- Старт без авторизации: поиск игрока по имени или ID, статистика четырёх режимов.
- Для числового имени — префикс `@`, например `@12345`; без него число означает ID.
- Обновление профиля с сохранением данных, сообщения об ошибках и повтор.
- Лучшие/последние успешные результаты игрока: отдельное обновление,
  подгрузка страниц, название карты/сложность при наличии данных.
- Карты профиля: most played, избранные и категории маппера; независимые
  refresh/load-more/retry, без загрузки тяжёлых обложек.
- Переход из результата или карты к набору: название, автор, список сложностей,
  звёзды/длительность и публичные top scores выбранной сложности.
- Дополнительный вход через браузер osu!, свой профиль и локальный выход
  через меню аккаунта справа сверху.
- Английский/русский интерфейс нового профиля и сохранённый выбор языка.

Рейтинги, новости и audio ещё
находятся в legacy-коде и не объявляются готовыми функциями нового shell.
Beatmap пока без audio, фильтров mods и персональных таблиц. Сначала восстанавливаем эти
сценарии; UI kit/единые темы отдельно планируем и согласуем с assets и
osu!-стилем. Нынешнее оформление временное.

## Локальный запуск

Требования: FVM, Flutter **3.47.2** / Dart **3.13**, Android SDK, JDK **25**.
Android использует AGP **9.3.2**, Gradle **9.7.1**, JVM target **21**,
compileSdk **37**, minSdk **26**. Pub workspace находится в корне.

1. Установить закреплённый Flutter: `fvm install`.
2. Создать локальный `.env` по `.env.example` и заполнить
   `OSU_CLIENT_ID` / `OSU_CLIENT_SECRET`. Не коммитить и не публиковать значения.
3. Получить зависимости и сгенерировать конфигурацию/локализацию:

```sh
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter gen-l10n
fvm flutter run
```

После изменения .env повторить build_runner. Generated environment ignored;
его не редактируем вручную. Envied затрудняет чтение строки, но не делает
client secret недоступным в binary. Перенос на BFF предусмотрен отдельно.

Для пользовательского OAuth зарегистрированный callback должен точно совпадать:
`https://wratheus.github.io/oauth/osu/callback/`. Android App Links дополнительно
требуют корректного fingerprint подписи на внешнем Pages hosting. Локальный
debug keystore на другом компьютере может иметь другой fingerprint.
Guest client-credentials flow браузер/callback не использует.

## Структура и проверки

- `lib/src/_core` — bootstrap/DI, router, network policy, l10n/config.
- `lib/src/profile` — Main → source/repository → Bloc → widgets;
  source возвращает raw payload, repository создаёт DTO/domain.
- `lib/src/auth`, `lib/src/session` — OAuth и пользовательская сессия;
  гостевой token cache изолирован и хранится только в памяти.
- `packages/tracksu_network` — REST поверх http, interceptors/options/payload.
- `packages/tracksu_storage` — secure tokens, callback transaction и locale.
- Старые `pages/models/requests/widgets` удаляются по мере замены consumers,
  а не используются как архитектурный образец для новых features.

```sh
fvm dart analyze lib/src/profile lib/src/guest lib/src/auth lib/src/session lib/src/_core packages/tracksu_network
fvm flutter analyze --no-pub
fvm flutter build apk --debug
```

Полный analyzer пока выявляет legacy debt; локальный clean gate не означает
clean всего репозитория. Автотесты сейчас намеренно не пишутся и не запускаются:
поведение проверяется вручную.

APK: `build/app/outputs/flutter-apk/app-debug.apk`.
Все variants пока используют **debug signing**; это не production-конфигурация.
Новый ID: `io.github.wratheus.tracksu`. Старое обновление приложения/подпись не
гарантируются. iOS host удалён, будет создан отдельно после Android.

## План и документация

Начинать с [активной очереди](tracksu-agent-ref/plan/ROADMAP.md).
[Карточка профиля и ручная проверка](tracksu-agent-ref/plan/work/P09-profile-explorer.md),
[реализованная основа](tracksu-agent-ref/plan/IMPLEMENTED.md),
[правила работы](tracksu-agent-ref/workflow/PLAYBOOK.md),
[CHANGELOG](CHANGELOG.md). Документация хранится только в этом репозитории.

## Источники и права

Проект не является официальным приложением osu! и не заявляет одобрения ppy.
Используемые источники:
[osu! API](https://osu.ppy.sh/docs/index.html),
[osu-resources](https://github.com/ppy/osu-resources),
[osu!](https://github.com/ppy/osu).
Упоминание источника не заменяет лицензию: аудит происхождения, прав и веса
bundled assets остаётся отдельной задачей P01.2 перед выпуском.
