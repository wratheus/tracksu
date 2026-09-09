# P11 — глобальные рейтинги

Текущая доработка основного рейтинга: [P11-product](P11-product.md).
Продуктовый UI Spotlights: [P19](P19-spotlights-product.md), реализован 2026-09-10.
Ниже — история реализации API-срезов, не описание актуального UI.
Ручной country input и восемь общих chips заменены; APK/build инструкции
ниже не применять: с 2026-09-09 только format/analyze/review по указанию пользователя.

## Срез spotlights — реализован, ожидает ручной проверки

Цель: из рейтингов открыть каталог spotlights, выбрать подборку/ruleset,
посмотреть её карты и рейтинг, перейти в существующие профиль/beatmap routes.
Собственный route/repository/Bloc, общий public transport; без storage changes.
Каталог и выбранная подборка загружаются последовательно; смена выбора
latest-wins с отменой IO. Refresh сохраняет content, ошибка позволяет retry.
Charts не имеет cursor: сервер возвращает до 40 игроков, пагинацию не выдумываем.
Отсутствующий ruleset — явная ошибка, не пустой успех. Не добавляем country,
mania variants, friends, playlists/seasons или темы. Исходная точка — 44f28c1,
analyze/debug build успешны, устройство не проверено. Проверка: format/analyze/
debug APK и ручной сценарий; без автотестов. Откат — scoped commit, данные
хранилища не затрагиваются. Источники: RankingController::spotlight,
SpotlightsController, SpotlightTransformer, Spotlight model в ppy/osu-web.

### Контракт и ручная приёмка spotlights

Сверено 2026-09-06 с официальными исходниками:
[каталог](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/SpotlightsController.php),
[charts](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/RankingController.php),
[модель и ограничение результата](https://github.com/ppy/osu-web/blob/master/app/Models/Spotlight.php),
[метаданные](https://github.com/ppy/osu-web/blob/master/app/Transformers/SpotlightTransformer.php).
GET /spotlights → spotlights; GET /rankings/{mode}/charts?spotlight={id}&filter=all
→ spotlight, beatmapsets, ranking. Загружается последняя запись каталога, затем
выбор доступен через ленивый список. Каталог обновляется при новом входе;
пустой каталог и его ошибка позволяют retry. Refresh выбранной подборки не
перезагружает каталог. Источник возвращает raw map, repository разбирает DTO,
проверяет совпадение ID и повторы. Проекция сознательно не включает даты,
participant_count и PP: интерфейсу нужны имя, карты и ranked_score подборки.
Никаких запросов на каждый ряд или собственных обложек.

Public allowlist расширен только exact /spotlights и charts четырёх режимов;
общие ограничения host/HTTPS/GET сохранены. Независимый route scope закрывает
Bloc и отменяет запросы, не трогает обычный рейтинг и его фильтры. Смена
подборки/режима начинает scroll сверху; refresh и возврат из pushed profile/map
сохраняют позицию. Открытие/закрытие каталога не обещает сохранить scroll деталей.
Набор открывается целиком через BeatmapsetParams, без отдельного фильтра сложностей
spotlight. Несуществующий режим отдаёт явную ошибку и оставляет выбор доступным.

- Рейтинги → Spotlights: индикатор, последняя подборка, карты и top игроков.
- Выбрать старую подборку; переключить osu/taiko/fruits/mania, включая режим
  без данных: ошибка с retry, без выдачи старой таблицы за новую.
- Быстро менять подборку и режим на медленной сети; последняя комбинация побеждает.
- Offline refresh: прежние данные остаются, ошибка видна, retry восстанавливает.
- Карта → назад; игрок → назад: правильный профиль/ruleset и прежняя подборка.
- Двойное нажатие строки, выход во время запроса, длинные названия, en/ru,
  крупный шрифт; каталог и ряды создаются лениво, без shrinkWrap.

UI временный Material в текущей теме. Визуальное качество новых страниц не
считается согласованным: после функционального переноса нужны аудит assets,
совместное планирование osu!-стиля и только затем P07/UI kit.

Техническая проверка 2026-09-06: gen-l10n, scoped format; analyze rankings,
profile, beatmap, _shared, _core, guest, auth, session и двух workspace packages
— No issues found. Debug APK (--debug --no-pub) собран; git diff --check чистый.
Остаётся прежнее предупреждение Gradle native access на JDK 25. Автотесты
не писали/не запускали; live API и устройство не проверяли. Skills feature/
dart-style/UI/quality определили локальный DI, raw source → repository mapping,
lazy slivers и проверку lifecycle, с пользовательским исключением автотестов.

Scope: performance/score × четыре ruleset, публичный клиент, отдельный route
из shell, lazy list, refresh/load-more/retry. Main → source/repository → Bloc.
Смена фильтра latest-wins; paging сохраняет строки и scroll.
Следующую страницу берём из cursor.page ответа, не из длины списка.
Страны, mania variants и spotlights подключены; ожидается ручная проверка.
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

Остаток P11: ручная проверка; legacy cleanup по usages после проверки.

## Техническая проверка

2026-09-05: gen-l10n, scoped format и analyze всех современных features,
_core/_shared и обоих workspace packages — No issues found.
Debug APK собран командой `fvm flutter build apk --debug --no-pub`.
Прежнее предупреждение Gradle native access на JDK 25 не блокирует сборку.
`git diff --check` чистый. Автотесты не писали/не запускали, устройство не проверено.
Дополнительные фильтры описаны ниже. P13/news и темы этим коммитом
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

## Страны и mania 4K/7K

Отдельный коммит: RankingCountry, ManiaVariant, события/состояния Bloc,
query source и локализованные scoped фильтры. Источник контракта — тот же
RankingController (сверен 2026-09-05): country и variant=4k/7k применимы
к performance/score; общий вариант не передаётся в query.

Пока используем ввод кода, не каталог стран: trim + uppercase, ровно две
латинские буквы. Проверяем только формат; наличие страны определяет сервер.
Невалидный формат не отправляется; серверный 404 становится notFound,
без незаметного возврата к мировому рейтингу. Запрос только по «Применить»
или Done, не на каждую букву. «Весь мир» очищает применённую страну.

Страна сохраняется при смене режима; variant сохраняется между двумя
сортировками mania и сбрасывается при выходе из mania. Query запрещает
4K/7K для других режимов. Каждая новая комбинация начинает страницу 1,
отменяет старый запрос и отбрасывает запоздалые ответы. Refresh, append
и retry используют применённые фильтры. Черновик поля локален виджету.
Из 4K/7K открываем общий профиль mania: variant-specific профиль не реализован.
Внешний вид временный; тематизация и полноценный picker здесь не начинаются.

Ручная проверка:

- Ввести ` jp ` → JP, применить, догрузить; очистить через «Весь мир».
- Неверный формат → ошибка поля без запроса; неизвестный код → ошибка сервера.
- Mania 4K → score → 7K → osu: вариант сохраняется внутри mania и сбрасывается
  при выходе; страна остаётся. Вернуться в mania — общий вариант.
- На медленной сети быстро менять фильтры; старые строки не подмешиваются.
- Offline refresh/append → retry сохраняет комбинацию фильтров.
- Открыть игрока и вернуться: фильтры, строки и позиция списка сохраняются.
- Проверить en/ru, клавиатуру и крупный шрифт на телефоне.

Проверки: gen-l10n, scoped format, analyze современных features/_core/_shared
и обоих пакетов — No issues found; debug APK собран. Прежнее предупреждение
Gradle native access остаётся. Автотесты не писали/не запускали, live API
и устройство не проверяли. Откат коммита убирает фильтры без смены endpoint.
