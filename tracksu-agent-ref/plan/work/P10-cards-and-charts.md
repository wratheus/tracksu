# P10/P12 — карточки и графики

2026-09-08 · in_progress. Согласован пользователем; продолжает foundation P10/P12.

## Scope и план коммитов

1. Компактные результаты без обязательной обложки; подробности в общей modal,
   переход к карте сохраняет ruleset и исходный стек. Без нового запроса на каждый score.
2. Карты профиля и заголовок карты: optional HTTPS cover, mapper/status,
   favourites и plays набора; stars/длительность/BPM только конкретной сложности,
   когда поле действительно есть. Личные plays не смешивать с plays набора.
3. Общий line chart: лёгкая заливка, меньше маркеров, корректные разрывы;
   отдельный помесячный график просмотров реплеев из профиля.

## Baseline и границы

- Старт: cdc4b74; пользовательская `.gitignore` не входит в изменения.
- Общие визуальные компоненты — UI kit / `_shared/ui`, DTO только в repository.
- Не меняем OAuth, scopes, API version, legacy:false, пагинацию и lifetime Bloc.
- Обложки не обязательны; нет N+1 enrichment, новых assets или зависимостей.
- Rank history не содержит дат: не обещаем Today/90 days. Разрывы не соединяем.
- Replay history содержит start_date/count: сортируем месяцы, не выдумываем
  отсутствующие нули; пустой/невалидный optional график не скрывает профиль.
- Реплеи не скачиваем и не проигрываем; аудио, друзья, новые score categories отдельно.

## Проверка и rollback

Результаты: 8503efe. Карты: общий metadata DTO/domain и facts-компонент подключены
к профилю и деталям. Most-played содержит базовый Beatmap без гарантированного BPM:
показываем его на detail при наличии, не делаем enrichment запросы.
Полные hit statistics / настройки модов и descriptions карт остаются отдельной доработкой.

Формат, analyze приложения/пакетов, debug-сборки приложения и UI catalog.
Автотесты не пишем/не запускаем; APK не устанавливаем. Ручная проверка пользователем:
best/recent/leaderboard → детали → карта → Back; длинные переводы и крупный шрифт;
карта без cover/BPM; set vs difficulty/личные plays; график с одним значением,
пустым рядом и gaps; выбор точки и refresh/ruleset change.
Откат — revert соответствующего локального коммита, не reset истории.

Источник контрактов: [osu! API v2](https://osu.ppy.sh/docs/index.html),
Score, Beatmap/BeatmapExtended, Beatmapset/Covers, UserExtended.
