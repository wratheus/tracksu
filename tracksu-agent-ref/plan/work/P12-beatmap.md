# P12 — карта и leaderboard

2026-09-05. Статус в ROADMAP.

## Commit plan

Цельный сценарий: карточка результата/карты → typed route → набор и выбор
сложности → публичный top leaderboard → назад с сохранением профиля.
Main создаёт локальные source/repository/Bloc. Сеть и public token общие.
Данные карты и leaderboard имеют независимые ошибки/refresh.
Смена сложности отменяет старое чтение, закрытие route отменяет IO.

Score DTO/domain/card выносим в app shared: теперь два реальных потребителя,
профиль и leaderboard. Не копируем parser и не вводим универсальный base Bloc.
Без редизайна, audio, скачивания, персонального/friends ranking и фильтра mods.
Показываем mod acronyms из нового Score; legacy=false в query, переключатель позже.
Top endpoint не документирует offset: вымышленную пагинацию не добавляем.

Коммит включает wiring, en/ru, docs. Проверки: gen-l10n, format/analyze/build,
diff/lifecycle. Автотестов нет. Откат всего среза возвращает неактивные карточки.
Legacy удаляем после ручной проверки и переноса оставшихся consumers.

## Ручные сценарии

- Из best/recent открыть конкретную сложность; из favourite открыть набор.
- Переключать сложности во время загрузки; нет scores от прежней сложности.
- Назад: профиль, категория и загруженные страницы сохраняются.
- Offline initial/refresh leaderboard → retry; metadata не исчезает.
- Пустой leaderboard/удалённая карта; длинные тексты, en/ru, крупный шрифт.

## Реализация и ограничения

- Typed BeatmapDifficultyParams/BeatmapsetParams вместо Object/casts между
  legacy Score и Beatmap. Для сложности сначала определяется набор; его
  ответ даёт все native difficulties, без N+1 запросов.
- Строгая сверка ID набора/сложности и ID/ruleset scores. Shared JsonMapReader,
  raw payload в source; DTO создаёт repository. Score вынесен в
  `_shared/scores`, профильная пагинация осталась в profile.
- Выбор сложности локален, запрос leaderboard принадлежит отдельному scope
  с ключом ID/ruleset. Refresh сохраняет content; закрытие отменяет IO,
  поздние завершения закрытых Bloc не emit. Повторные refresh игнорируются.
- Из score сохраняется его ruleset, включая конверт; звёзды/длительность в
  списке описывают исходную native difficulty, не пересчитанные mod attributes.
- Top global, legacy=false. Моды показываются acronyms; фильтры mods,
  friends/country, личный score, полный hit-statistics и preview не реализованы.
  Offset/cursor этого endpoint не выдумываем. Порядок строк — серверный.
- Текущее оформление без новой темы и assets. Навигация через appRouter,
  callbacks не содержат HTTP/JSON. Профиль остаётся в предыдущем route.
- Legacy beatmap route не удалён: ещё есть старые consumers, cleanup после
  ручной проверки и переноса оставшихся разделов.

Контракты сверены с [документацией](https://osu.ppy.sh/docs/index.html#get-beatmap-scores)
и [BeatmapsController](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/BeatmapsController.php):
global — публичный тип, версия заголовка выбирает современный Score.
Это не проверка live авторизованных ответов.

## Проверки и handoff

2026-09-05: gen-l10n и format выполнены. Scoped analyze:
`lib/src/beatmap lib/src/_shared lib/src/profile lib/src/guest lib/src/auth
lib/src/session lib/src/_core packages/tracksu_network packages/tracksu_storage`
— No issues found. Debug APK (`fvm flutter build apk --debug --no-pub`) —
exit 0. JDK 25 выдаёт прежнее предупреждение Gradle native access, не ошибку.
`git diff --check` чистый; старых imports перемещённых Score-файлов нет.
Автотесты не писали/не запускали, устройство проверяет пользователь.
README/CHANGELOG/ROADMAP обновлены. Далее P11: фильтры рейтингов, пагинация
без гонок и доступ из mobile shell; не переходить к темизации.
