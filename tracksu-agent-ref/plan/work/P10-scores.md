# P10 — scores профиля

## Текущий ограниченный шаг

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
  hit statistics, вложенные beatmap/beatmapset добавим при подключении карточек.
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

## Проверки и следующий шаг

2026-09-05: scoped dart format выполнен; dart analyze lib/src/profile
lib/src/_core/serialization — No issues found; git diff --check чистый.
APK не пересобирался: новый data-слой пока не подключён, runtime приложения
не меняется. Следующий шаг: карточка score с beatmap metadata, локальный Bloc,
best/recent selector, load-more/retry и сброс секции при смене игрока/ruleset.
Не удалять legacy scores до подключения и ручной проверки замены.
