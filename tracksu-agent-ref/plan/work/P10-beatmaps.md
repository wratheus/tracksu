# P10 — списки карт профиля

2026-09-05. Сводный статус — в ROADMAP.

## Scope и commit plan

Один вертикальный срез: восемь категорий Get User Beatmaps, отдельная секция
профиля с пагинацией/refresh/retry. Source возвращает raw list, repository
разбирает разные контракты most_played и beatmapsets. Main владеет repository
и Bloc; запросы через shared publicRestClient, без отдельной пользовательской
авторизации. Смена категории отменяет прежний запрос; закрытие тоже.

Именованные фильтры, immutable domain, scoped Bloc, lazy slivers, en/ru.
API не документирует mode для этого endpoint: фильтр ruleset не отправляем.
Нет дополнительного запроса на каждую строку. Обложки, проигрывание, переход
к beatmap (P12), новый дизайн и удаление старых routes не входят в этот срез.

Коммит: feature + wiring + l10n + docs. Проверки: format, scoped analyze,
debug build, diff; автотесты не пишем/не запускаем. Откат коммита удаляет
только новую секцию, scores и профиль остаются доступны.

## Ручная проверка

- Гость: поиск игрока → секция карт → most played/favourite и категории маппера.
- Пустой список, несколько страниц, повторные нажатия «Ещё».
- Быстро сменить категории/игрока во время загрузки: нет чужих строк.
- Обрыв сети: ошибка первой загрузки и ошибка refresh/load-more; повторить.
- Смена en/ru, длинные названия, увеличенный шрифт, прокрутка.
- Карта без вложенных metadata отображает ID, не ломает весь список.

Проверку поведения выполняет пользователь; до подтверждения не verified.

## Реализовано и передача

- `lib/src/profile/beatmaps`: Main → raw source → repository/DTO → Bloc
  → sliver section. Общий JsonMapReader, без локальных семейств JSON helpers.
- Все восемь категорий, default mostPlayed, страницы по 20. Дедупликация ID
  в Bloc, offset — по размеру raw страницы. Ошибка refresh сохраняет данные,
  но блокирует append до успешного refresh. Ошибка append сохраняет offset.
- Смена категории supersedes старое чтение; generation guard и транспортная
  отмена защищают от поздних ответов. Повторные refresh/load-more во время
  операции игнорируются. Close отменяет запрос.
- Локальные состояния меняют только секцию карт, не ProfileBloc и scores.
  Refresh шапки с тем же ID сохраняет scope. Полная загрузка другого профиля
  или ruleset пока размонтирует loaded-ветку и сбрасывает секции; сохранение
  category/scroll/cache между такими переходами не заявляется.
- Текстовые карточки не требуют PNG, новых assets, per-row enrichment или
  пакетов. Карточки не кликабельны до P12. Старые routes пока не удалены:
  они обслуживают ещё не перенесённые beatmap/leaderboard сценарии.
- Проверено: `fvm flutter gen-l10n`, format изменённого Dart-кода;
  `fvm dart analyze lib/src/profile lib/src/guest lib/src/auth lib/src/session
  lib/src/_core packages/tracksu_network packages/tracksu_storage` —
  No issues found.
- `fvm flutter build apk --debug --no-pub` — exit 0, app-debug.apk.
  Gradle печатает предупреждение о native access на JDK 25; сборка успешна.
  `git diff --check` — чисто. На устройстве не запускали. Автотестов нет.

README/CHANGELOG/API reference и ROADMAP обновлены. Следующая реализация —
P12 (детали карты/leaderboard и typed navigation), не темизация.
