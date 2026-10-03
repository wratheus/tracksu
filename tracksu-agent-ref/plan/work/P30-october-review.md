# P30 — аудит изменений 2–3 октября

2026-10-03 · implemented in code / awaiting_manual_check.

## Цель и границы

Восстановить контекст после Hermes, проверить пять коммитов
`01f65e5..bb677d1` и существующий незакоммиченный P29, исправить подтверждённые
регрессии и сверить документацию с фактическим приложением.
Scope: media/audio, загрузка команды, transitions/rankings, shell reselect,
scroll-to-top, языки и изменённый Spotlight decoder. Новые продуктовые фичи,
переписывание архитектуры, публикация и Android release не входят.

Пользователь поручил проверять приложение в симуляторе и писать аккуратные
тесты на ключевые реальные регрессии. Уточнение: не тестировать каждый метод
и не собирать покрытие ради покрытия. Этот запрос отменяет прежний запрет
на автотесты и самостоятельную ручную проверку исполнителем. Тест фиксирует
конкретный воспроизводимый контракт; не означает 100% корректности feature.

## Исходная точка

- HEAD `bb677d1`; пять коммитов от 2026-10-02, новых коммитов 3 октября нет.
- До аудита: 36 изменённых tracked файлов, untracked iOS host, navigation/
  scroll-to-top и четыре test-файла. Существующий diff сохраняем.
- `fvm flutter analyze --no-pub`: passed, No issues found.
- `fvm flutter test --no-pub`: 22 passed, 1 failed — устаревший шаблон
  `Counter increments smoke test`, не соответствующий приложению.
- `fvm flutter build ios --simulator --debug --no-pub`: passed.
- Выбран существующий Tracksu iPhone 17, iOS 27.0; установка поверх имеющегося
  приложения, без очистки пользовательских данных.
- Рабочий patch/status до изменений сохранён вне репозитория в
  `/tmp/tracksu-audit-2026-10-03/`.

## Проверка и критерии завершения

1. Просмотреть изменённые пути от события/запроса до UI и освобождения ресурсов.
2. Подтвердить дефекты тестом или конкретным GUI-сценарием, затем исправить.
3. Выбрать минимальные regression tests на важные контракты; отдельно отметить,
   что проверяют тесты и что требует реального устройства/API/визуальной оценки.
4. Format затронутого Dart, полный analyzer и suite; simulator build после fixes.
5. Протыкать доступные сценарии через Device Hub, записать фактические результаты.
6. Обновить владельцев документации, предложить следующий цельный срез очереди.

Порядок checkpoints: подтверждённые UI/DTO дефекты → ключевые regression tests
→ simulator QA → документация. Rollback — адресный diff поверх исходных изменений;
данные, auth, история Git и platform identity не мигрируются.

## Результаты

Статус: **awaiting_manual_check**. По решению пользователя финальные
format/analyze/test и GUI-приёмку выполняет он сам; исполнитель собрал и
запустил приложение в симуляторе без заявления PASS.

| Риск | Тест / GUI | Результат |
| --- | --- | --- |
| Один «неправильный» чарт ломает весь каталог Spotlights | `test/src/spotlights/data/repository_test.dart` (реальные даты чарта 68) | Исправлено по контракту osu-web, без заглушки: см. [P31](P31-spotlights-contract.md). Ранее GUI: каталог из 132 подборок загрузился |
| Ruleset без чарта (osu-web 404) выглядит как ошибка | `test/src/spotlights/bloc/bloc_test.dart` | Пустое состояние вместо ошибки/Retry ([P31](P31-spotlights-contract.md)) |
| Ник и PP на разной высоте в строке рейтинга | `test/src/_shared/ui/ranking_row_test.dart` | Общая alphabetic baseline; GUI ранее подтверждён на iPhone 17 |
| Кнопка «Наверх» перекрывает последний action | `test/tracksu_ui/widgets/scroll_to_top_test.dart` (последняя ссылка) | Место под кнопкой в конце страниц |
| Refresh/Retry теряет строки и scroll рейтинга | `test/src/rankings/widgets/refresh_test.dart` | Покрыто тестом |
| Reselect вкладки / сохранение веток | `test/src/guest/widgets/guest_shell_test.dart` | Покрыто тестом |
| Ошибка декодера аватара стирает кэш | `test/src/_shared/media/widgets/app_media_test.dart` | Покрыто тестом |
| Названия языков не на своём языке | `test/src/_shared/preferences/language_picker_test.dart` | Покрыто тестом |
| Ошибка декодера аудио просит «проверить соединение» | — (код + GUI) | `AudioPlaybackFailure` и 4 новых сообщения; GUI — пользователь |
| Шаблонный counter test всегда падает | — | Удалён |

Spotlights перенесены из Рейтингов на стартовый экран и задокументированы
в P31 и NAVIGATION_SPEC.

## План коммитов (после проверки пользователем)

Автор — по PLAYBOOK §15 (`git var GIT_AUTHOR_IDENT`). Генерированные l10n
общие: включать в первый коммит, который их требует, и далее дополнять.

1. `docs(process): adopt targeted regression tests` — TESTING, PLAYBOOK,
   SKILLS, CODE_STYLE, ROADMAP/IMPLEMENTED baseline.
2. `feat(navigation): scroll-to-top and active-tab reselect` — scroll_to_top,
   shell_reselect, consumers, l10n `scrollToTop`, тесты, NAVIGATION_SPEC.
3. `fix(media): keep healthy cache on avatar/cover decode errors` + тест.
4. `fix(l10n): show language names as autonyms` + тест.
5. `fix(rankings): align ranking row baselines` + тест.
6. `feat(spotlights): follow osu-web contract and open from start screen` —
   перенос `lib/src/spotlights`, SearchHome, RankingsSection, ARB, тесты, P31.
7. `fix(audio): explain playback failures by cause`.
8. `chore(test): remove template counter test`; `docs: P29/P30, CHANGELOG, README`.

Открытое решение пользователя: коммитить ли локальный iOS host `ios/`
(сейчас untracked).

