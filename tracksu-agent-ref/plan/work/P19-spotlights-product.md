# P19 — продуктовый срез Spotlights

2026-09-10 · awaiting_manual_check · baseline 16e6f50, чистое дерево.

Цель: подборка с датами/участниками, картами-баннерами и карточками игроков,
поиском по каталогу в sheet, единым ruleset selector без переноса chips.
Старт: Рейтинги → Spotlights; API/repository/Bloc/routes уже существуют.

Контракт: прежние GET /spotlights и /rankings/{mode}/charts. Расширяем проекцию
полями из этих ответов, без N+1, новых scopes, storage или внешних сервисов.
Source raw map → DTO в repository → typed domain → UI kit. Feature-owned Bloc
сохраняет latest-wins/cancellation, refresh сохраняет данные. Sheet не подменяет
страницу: закрытие/повторный выбор сохраняют scroll, новая комбинация сбрасывает.
Нет пагинации charts, количество показанных строк не равно числу участников.

За рамками: новости, friends, seasons/playlists, audio, native host, exact font.
План коммита: весь вертикальный срез с семью локализациями и docs; откат кодом
через Git, локальные данные не меняются. Не публиковать.

Проверки: gen-l10n, format, analyze lib/packages, diff. APK и тесты запрещены.
Ручная приёмка: длинные названия/языки, поиск в каталоге/пустая выдача, выбор,
режим без данных, быстрые смены, offline refresh/retry, карта/игрок → Back,
неудачная загрузка арта, число участников отдельно от top-40.

Источники: [SpotlightTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/SpotlightTransformer.php),
[RankingController::spotlight](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/RankingController.php)
в ppy/osu-web; проверены 2026-09-10. Метаданные имеют optional participant_count;
карты включают beatmaps, игроки идут через UserStatistics RANKING_INCLUDES.

Реализовано: расширение DTO/domain без изменения endpoints/Bloc, cards из
app-level UI, avatar/team, позиция в подборке (не global PP rank), точный score
по удержанию компактного числа. Метаданные карт и число сложностей относятся
к набору в целом, не выдаются за кураторский список сложностей Spotlight.
Период — опубликованные календарные даты UTC с локализованным представлением;
нет вычисленного «active» по локальным часам. Missing поля не превращаются в нули.
Старый inline каталог/_NavigationTile и неиспользуемый перевод удалены.
Поиск и double-tap guard живут в picker/карточке; закрытие sheet не меняет key
основного scroll. Не обещаем сохранение после убийства процесса.

Технически: gen-l10n, scoped format, analyze lib/packages без замечаний,
diff-check чистый. APK/тесты не запускались по указанию пользователя. Откат —
scoped revert коммита без очистки данных. Next: поэкранная доработка новостей.
