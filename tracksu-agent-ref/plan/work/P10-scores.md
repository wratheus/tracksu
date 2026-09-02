# P10 — scores профиля

## Шаг 1: data-контракт (084bd41)

Сетевой/data-контракт best/recent: typed query, limit/offset, единая policy
legacy=false, отмена, raw source → DTO → domain repository. Образец — P09.
Перед DTO сверяем официальный Score response version 20220705.

UI/Bloc, pagination interaction, карты профиля и удаление legacy — следующие
части P10. Этот коммит не объявляет scores доступными на экране.
Source/repository будут локальными для секции scores, не глобальными DI singletons.
Shared REST-клиент с public auth, version headers и retry уже существует.

Проверки: scoped format/analyze, review diff; без автотестов и сетевых запросов
с секретами. Поскольку новый слой пока не подключён к UI, ручной сценарий
появится при подключении. Возврат — revert отдельного коммита.

## Реализованный контракт

- GET /users/{id}/scores/{best|recent}; ruleset, limit/offset,
  legacy_only=0 по умолчанию; include_fails отправляется только для recent.
- Summary DTO использует total_score/ended_at/ruleset_id/mods objects.
  Это намеренная проекция для списка, не полная модель Score: mod settings,
  hit statistics не входят. Optional title/artist/difficulty из вложенных
  beatmap/beatmapset подключены в шаге 2.
- accuracy хранится долей 0..1 (не процентом профиля); PP может быть null;
  UTC endedAt, immutable lists. Некорректные entries не пропускаем молча.
- Repository локален секции; отдельная отмена не прерывает профильный запрос.
  Отмена — typed cancelled, не network failure. user/ruleset ответа проверяются.
- Full page даёт nextOffset; это не доказательство наличия следующей страницы.
  Empty/short page завершает пагинацию; total/cursor у endpoint нет.

Основание: [Get User Scores](https://osu.ppy.sh/docs/index.html#get-user-scores)
и [Score](https://osu.ppy.sh/docs/index.html#score), сверены 2026-09-05.
Реальный authenticated response не запрашивали; совместимость по документации,
не подтверждение runtime на аккаунте. Контракт нуждается в ручной проверке
при подключении UI. Тесты и fixtures не создавались.

## Проверки шага 1 (история)

2026-09-05: scoped dart format выполнен; dart analyze lib/src/profile
lib/src/_core/serialization — No issues found; git diff --check чистый.
APK не пересобирался: новый data-слой пока не подключён, runtime приложения
не меняется. Следующий шаг: карточка score с beatmap metadata, локальный Bloc,
best/recent selector, load-more/retry и сброс секции при смене игрока/ruleset.
Не удалять legacy scores до подключения и ручной проверки замены.

## Шаг 2: подключение списка

Реализованы: optional beatmap metadata для карточек, локальный
ScoresMain → source/repository/Bloc, best/recent, загрузка/пусто/ошибка,
refresh с сохранением данных и ручная подгрузка следующей страницы.
Одна общая прокрутка профиля через slivers; без вложенных shrinkWrap списков.
Новая пара player/ruleset создаёт новый scope и закрывает старый. Refresh
статистики не пересоздаёт scores; у секции есть собственное обновление.
Не входят: новый дизайн, beatmap route (P12), дополнительные запросы для
обогащения каждой карты, audio, полный набор mod settings/hit statistics.
Проверки: gen-l10n, format/analyze, debug APK; автотесты не запускать.

## Текущая передача

- Best/recent доступны в гостевом и своём профиле. Recent пока показывает
  успешные попытки (includeFails=false); query поддерживает включение failed.
- Refresh сохраняет старые строки; ошибка load-more сохраняет offset для retry.
  Страницы объединяются по score ID без повторяющихся карточек.
- При смене best/recent действует latest-wins; повторные load-more/refresh
  во время загрузки игнорируются. Новый player/ruleset закрывает старый scope.
- Отсутствие metadata не скрывает score: отображается beatmap ID.
  Нет дополнительных запросов и eager PNG-строк; карточки текстовые.
- gen-l10n, scoped format, analyze profile/guest/auth/session/_core и обоих
  workspace packages: успешно, No issues found.
- flutter build apk --debug --no-pub: exit 0, app-debug.apk (2026-09-05).
  git diff --check чистый. На устройстве не запускали, автотесты не трогали.

Ручная проверка: guest lookup → scores; best/recent → load more; быстро
переключить тип/игрока/ruleset; offline refresh и offline load-more → retry;
пустой список; длинное название и крупный шрифт; en/ru; back/logout при загрузке.
Проверить, что локальное обновление scores не скрывает статистику профиля.

Списки карт подключены отдельной секцией: [P10-beatmaps](P10-beatmaps.md).
Далее переход в beatmap (P12) и адресное удаление заменённого legacy после
проверки сценариев. Редизайн не начинать.
