# P25 — завершение session cache для коллекций

2026-09-22 · implemented / awaiting_manual_check · baseline `ec4ca85`.

## Цель

Закрыть оставшийся collection-cache пункт P23: медали пользователя,
каталог/детали spotlights и результаты выбранной сложности карты.
Не менять дизайн целиком, не добавлять disk/offline storage и не объявлять
аудиоплеер, Liquid Glass или Dynamic Island реализованными.

## Изменения

- Используется существующий PageCache из DepsScope: максимум 40 snapshots,
  TTL 30 минут, identity revision и защита от повторного заполнения после Clear.
  Никакого отдельного cache manager и хранения credentials/HTML на диске.
- Medals: key `('medals', userId)`, immutable earned-medal collection.
  Сохранённый список показывается немедленно и всегда перепроверяется; только
  успешный ответ заменяет snapshot. Ошибка refresh оставляет медали с notice/Retry.
  Пустой успешный список тоже является данными и сохраняется во время refresh.
- Leaderboard: key `('beatmap-leaderboard', beatmapId, ruleset, legacy)`.
  Provider также привязан ко всей query: другой вариант не использует старый Bloc.
  Смена сложности/возврат использует только её собственный snapshot. Ошибка
  refresh не удаляет результаты; повторные refresh не ставятся в очередь.
- Spotlights: каталог хранится отдельно, детали — по spotlight ID и ruleset.
  Повторное открытие показывает cached catalog/details, затем revalidate catalog
  и выбранные детали. Удалённый из нового каталога spotlight заменяется первым
  доступным; данные старой выборки не подставляются под новую. При переключении
  сначала используется snapshot точной пары ID/mode, иначе skeleton.
  Ошибка каталога сохраняет доступный cached catalog, ошибка details — их snapshot.
- BLoC concurrency: medals/leaderboard `droppable` и busy guard, spotlights
  `concurrent` + generation/latest-wins. Repository продолжает владеть отменой IO,
  Bloc — состоянием/кэшем; после close нет позднего emit/cache write.
- Начальная загрузка трёх разделов использует общий статический UiPageSkeleton;
  refresh показывает компактный progress поверх сохранённых данных.
  Успешные данные не заменяются skeleton при обновлении.
- При review loading-consumers исправлен дефект P24: box-skeleton команды
  обёрнут SliverToBoxAdapter. Во время переключения режима команды теперь нет
  ложного текста «обновление не удалось», пока запрос ещё выполняется.

## Проверки

Только scoped format, analyze `lib packages`, diff/lifecycle review — без тестов,
APK, запуска приложения или каталога по действующему указанию пользователя.
Локальный FVM автоматически восстановил отсутствующий pinned SDK 3.47.2.
Первый analyze обнаружил отсутствующие пакеты; выполнен
`fvm flutter pub get --enforce-lockfile`. Версии и pubspec.lock не менялись.
Новые строки/генераторы не требовались: использованы существующие переводы/UI kit.
Итог: scoped format выполнен; `fvm flutter analyze --no-pub lib packages` —
`No issues found!`; `git diff --check` чистый. Runtime/device поведение не проверялось.

Ручная приёмка остаётся открытой:

- повторно открыть медали, сменить профиль, refresh/offline/Retry и пустой список;
- открыть результаты карты A, переключить сложность B и вернуться в A;
- переключать spotlight/mode быстро, открыть другой route, вернуться;
- недоступный каталог с snapshot, удалённый spotlight, пустой свежий каталог;
- Clear cache во время IO: текущий экран не исчезает, snapshot не возвращается
  в cache от уже начавшегося запроса; следующее открытие без snapshot;
- первая загрузка команды, переключение режима без ошибочной failure-подписи;
- narrow/large text, тема, семантика skeleton и сохранение scroll при refresh.

Следующий самостоятельный срез — аудиоплеер P23: preview карты и поддерживаемые
audio sources новостей, явный Play, единый поток, focus/lifecycle и media policy.
