# P11 — глобальные рейтинги

Scope: performance/score × четыре ruleset, публичный клиент, отдельный route
из shell, lazy list, refresh/load-more/retry. Main → source/repository → Bloc.
Смена фильтра latest-wins; paging сохраняет строки и scroll.
Следующую страницу берём из cursor.page ответа, не из длины списка.
Страны/mania variants/spotlights — отдельный остаток.
Один коммит с en/ru, docs и wiring; откат отключает новый route.
Проверки: format/analyze/debug APK, без автотестов; устройство — пользователь.

Контракт сверяется с RankingController osu-web: API ещё принимает
performance/score как type, cursor.page задаёт следующую страницу.
Только публичный filter=all, не friends.

## Реализация

Отдельный route через appRouter, кнопка в AppBar гостевого shell; назад
возвращает исходный профиль. Открытие route заново создаёт новый scope.
Новые DTO используют JsonMapReader, страницы объединяются по user ID;
cursor не вычисляется по числу дедуплицированных строк. Не возрастающий
cursor — invalidResponse. Error refresh сохраняет строки и блокирует append
до успешного refresh; error append сохраняет страницу для повторного запроса.
Сортировка серверная. Номер строки не выдаётся за стабильный global_rank.
Карточки текстовые: username, country code, PP и ranked score.
Нет загрузки изображений/N+1; фильтры принадлежат только RankingsBloc.
При догрузке scroll сохраняется; отдельного cache позиций каждого фильтра нет.

Источник: [RankingController](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/RankingController.php),
сверен 2026-09-05. Сохраняем поддерживаемые API aliases performance/score;
современный web type global сам по себе не означает выбор sort через query.
Проверка контракта не равна live проверке с пользовательским token.

## Ручная проверка

- Открыть рейтинги кнопкой сверху, переключить восемь комбинаций.
- Догрузить несколько страниц; повторно нажать во время загрузки.
- Offline refresh/append → retry: строки не исчезают, страницы не пропускаются.
- Сменить фильтр во время запроса; старый ответ не подмешивается.
- Назад в профиль, en/ru, длинные имена и крупный системный шрифт.

Остаток P11: country filter, mania variants/spotlights по отдельным контрактам;
legacy cleanup после ручной проверки.

## Техническая проверка

2026-09-05: gen-l10n, scoped format и analyze всех современных features,
_core/_shared и обоих workspace packages — No issues found.
Debug APK собран командой `fvm flutter build apk --debug --no-pub`.
Прежнее предупреждение Gradle native access на JDK 25 не блокирует сборку.
`git diff --check` чистый. Автотесты не писали/не запускали, устройство не проверено.
Следующий шаг P11 — дополнительные фильтры. P13/news и темы этим коммитом
не начинаются.

## Переход рейтинг → профиль

Отдельный атомарный коммит: ProfileParams (валидированный ProfileUserId +
ruleset), appRouter.openProfile, optional initial params в существующем
ProfileMain, callback карточки. Repository/экран не дублируются.
Initial ruleset задаётся конструктору Bloc до единственного lookup:
нет гонки между событиями смены режима и загрузки.
Корневой guest ProfileMain без params по-прежнему не делает initial lookup.

Ranking route остаётся mounted под profile route: фильтр, строки и scroll
не сбрасываются при pop. Новый профиль владеет собственным Bloc/repository,
не изменяет исходный профиль гостевого shell. Его закрытие отменяет запросы.
Повторное нажатие блокируется локальным состоянием карточки; после await
проверяется mounted. Account actions остаются в исходном shell.
Rollback коммита отключает переход, не меняя API/paging рейтингов.

Ручная проверка: догрузить рейтинг → игрок → убедиться в правильном режиме →
карта → два раза назад → прежняя позиция рейтинга. Повторить taiko/fruits/mania,
быстро дважды нажать карточку и вернуться назад во время загрузки.
Scoped format/analyze profile/rankings/_core/guest — No issues found.
Debug APK (--debug --no-pub) собран успешно; git diff --check чистый.
Автотесты не писали/не запускали; проверка на устройстве остаётся пользователю.
