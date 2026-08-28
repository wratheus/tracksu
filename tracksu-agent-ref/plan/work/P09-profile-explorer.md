# P09 — гостевой поиск и цельный профиль

## Цель и границы

Завершить один пользовательский сценарий: открыть приложение без входа,
найти игрока по имени/ID, посмотреть статистику четырёх режимов, обновить
данные и восстановиться после ошибки. OAuth остаётся дополнительным действием.

Исходный код: c3d9a79, чистое дерево. Сейчас поиск доступен только после входа;
смена ruleset загружает /me вместо выбранного игрока; запросы конкурируют;
refresh, типизированные ошибки и гостевой API-доступ не подключены.

## Реализация и коммиты

1. Цельный feature-коммит: Public API — отдельный client-credentials token в памяти, single-flight,
   обновление по expiry/однократному 401; не смешивать с пользовательской
   сессией. Repository профиля локален feature, владеет отменой запроса;
   source возвращает payload, repository разбирает DTO и ошибки.
   Main/bloc/widgets: гостевой поиск на старте, optional /me, latest-wins
   для поиска и ruleset, сохранение данных при refresh, retry, en/ru,
   sliver layout, fallback аватара. Source/repository cancellation и новый Bloc
   подключаем атомарно: прежние параллельные handlers не умеют обрабатывать отмену.
2. Документационный коммит: сверить очередь с кодом, вынести выполненную основу из активных задач,
   сохранить оставшиеся обязательства и фактические проверки.

Не входят: scores, редизайн/UI kit, BFF, iOS, analytics, релизные ключи,
миграция всех legacy features. Новых секретов и внешних настроек не создаём.
Временное хранение client secret в envied остаётся существующим риском P17.

## Ownership / проверки / возврат

Shared clients и public token repository создаёт DI; ProfileMain создаёт
source/repository/Bloc. Bloc отменяет чтение при новой цели и close.
Старые ответы не могут менять экран. Гостевой токен не пишет TokenStore.

Format, analyze и debug APK; автотесты не пишем и не запускаем (T01).
Ручная проверка пользователем: поиск без входа, имя/ID/@numeric-name,
четыре ruleset выбранного игрока, быстрые смены цели, refresh офлайн,
404/повтор, login → свой профиль → logout → гостевой поиск, back во время
загрузки, en/ru и крупный системный шрифт.

Возврат — адресный revert коммитов. Данные/подпись не мигрируются.
Статус и следующие этапы — только ROADMAP; результаты проверок ниже.

## Реализовано / технический review

- Public token: отдельный scope public, memory-only expiry cache, single-flight,
  invalidation только отклонённого токена, transport retry не больше одного.
  Источник контракта: https://osu.ppy.sh/docs/index.html#client-credentials-grant.
- Локальный profile repository, raw source → DTO/domain в repository,
  типизированные notFound/accessDenied/rateLimited/connection/invalidResponse.
- Один event bucket; выбранная concurrent/latest-wins policy с generation guard.
  Старый запрос отменяется; после name lookup сохраняется stable player ID.
  Close/logout сбрасывают поколение; refresh сохраняет content и показывает ошибку.
- Стартовый guest shell теперь показывает поиск; аккаунт/язык в AppBar.
  Четыре ruleset, статистика, empty state, retry, bounded avatar/fallback, en/ru.
  Поле ввода владеет своим локальным state; selector режима не подписан на stats.
- Дополнительно закрыта связанная гонка logout/refresh: session generation и
  сериализованные storage writes. HTTP timeout включает body read и abort;
  typed exceptions не теряются при retry.
- Прежние profile/presentation файлы удалены, consumers переведены. Остальной
  legacy не удалён, его consumers/перенос остаются в P10–P16.

Проверки 2026-09-05:

- gen-l10n и scoped dart format выполнены.
- dart analyze profile/guest/auth/session/_core/tracksu_network: No issues found.
- flutter analyze --no-pub: 652 legacy issues (3 warnings, 649 info), 0 errors.
  Полный gate остаётся красным; lint policy не ослаблялась.
- flutter build apk --debug и повтор с --no-pub: exit 0, app-debug.apk.
- git diff --check: без ошибок.
- Автотестов/harnesses не добавляли и не запускали. На устройстве этот срез
  ещё не проверен; результат ожидает ручного подтверждения пользователя.
