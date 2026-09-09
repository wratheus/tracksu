# P18 — обратная связь 9 сентября

Приоритет перед Spotlights/новостями. Проверка: format, analyze, diff;
без запуска тестов, приложения и APK. Коммиты локальные, без push.

## Последовательность цельных срезов

1. Карты и читаемость: полноширинные баннеры, единый интервал списков 12 px,
   PP без дроби, локализованные компактные большие счётчики с точным значением,
   иконки категорий. Настоящий график `monthly_playcounts`, отдельно от просмотров
   реплеев; общий контракт помесячных наблюдений, без выдуманных пропусков/нулей.
2. Внешние изображения ContentFrame: одноразовый выбор разрешить/отказать,
   сохранение решения, изменение в настройках. Это новое решение заменяет
   прежнее автоматическое включение. Сетевые/размерные ограничения сохраняются;
   отказ пользователя не смешивать с ошибкой загрузки/неподдерживаемым URL.
3. Общий системный Share для профиля/карты/результата/новости и модалок.
   Системный выбор установленных приложений, не отдельные TG/Discord API.
   Из результата в leaderboard — переход к профилю автора.
4. Полнота профиля: прежние имена возле ника с раскрытием списка; группы/team,
   медали, ranked play и daily challenge. Сначала сверить актуальные API поля,
   затем DTO → repository → domain → переиспользуемые элементы. Нет поля ≠ ноль.
5. Детали визуального языка: индикаторы количества/сложностей набора; страница
   результата по присланному референсу; округлый жирный шрифт цифр рейтинга
   после проверки источника/лицензии. Не подменять произвольным скачанным font.

Первый JPG отсутствует по указанному пути. Остальные референсы доступны в задаче.
Полноценные privacy/terms остаются P01.3; короткое разрешение на картинки не
заменяет документы и не обещает отсутствие сбора данных третьими сторонами.

## Позже

Действия при удержании ярлыка: Share и быстрые переходы. Не включать в текущий
срез. Друзья, чаты, push, аналитика, сравнения и BFF остаются PRODUCT-FUTURE.

## Статус

Срез 1 реализован, вместе с переходом результат → игрок из пункта 3.
Format/analyze/diff-check; ручная оценка на устройстве отдельно. При удержании
компактного счётчика видно точное число; PP округляется только для показа.
Источники: osu-web UserCompactTransformer / UserMonthlyPlaycountTransformer,
`monthly_playcounts` и `replays_watched_counts` — независимые серии.
Разрешение изображений реализовано: versioned allow/deny storage, fail-closed,
нет запросов без решения, отключение отменяет очередь, настройка доступна guest.
Первый выбор inline в reader, повторного вопроса после выбора нет. При ошибке
сохранения показывается сообщение о возможном сбросе после перезапуска.
Источники недоступных картинок требуют ручной проверки: соглашение не отменяет
HTTPS/формат/размер limits и не гарантирует доступность стороннего сервера.
Share реализован: общий app-level ShareTarget/ShareService и ShareButton поверх
UI kit; одна панель Telegram/WhatsApp/Facebook/X, copy и системный chooser.
Подключены поиск, рейтинг с фильтрами, Spotlights, список/страница новости,
профиль, карта, результат, модалка выбора сложности и Share карты в результате.
Это публичные ссылки osu!, не новые Tracksu deep links; поиск не выдаёт draft.
Аккаунт/OAuth/settings/catalog не являются публичными share targets.
Технические источники: [share_plus](https://pub.dev/packages/share_plus),
[Telegram](https://core.telegram.org/widgets/share),
[WhatsApp](https://faq.whatsapp.com/5913398998672934/?locale=pt_BR),
[X Web Intents](https://docs.x.com/x-for-websites/web-intents/overview),
[Facebook sharer](https://www.facebook.com/sharer/sharer.php), osu-web routes/web.php.
Facebook docs ограничены 429; web sharer ведёт в login/composer, поведение после
входа требует ручной проверки. Соцсети могут открыть браузер вместо приложения;
если launch возвращает false, предлагается системный chooser. Никаких SDK/login
соцсетей, записи recipients/raw result/аналитики, автопостинга или preview fetch.

Профиль: прежние имена в lazy sheet возле ника, группы и команда с флагом,
официальные ссылки, matchmaking stats по пулам (отдельно от PP), daily challenge
с текущими/лучшими дневными и недельными сериями, placements и датами подключены.
ProfileDetailsDto → mapper → immutable domain; source по-прежнему raw JSON.
Отсутствующие списки отличаются от пустых; неверный обязательный тип в
присутствующем разделе идёт через существующий invalidResponse, а не в нули.
Даты локализованы, rating округляется только для показа. Нет новых API запросов.

Медали **частично**: count, список ID/дата (сначала новые), переход к коллекции
на osu!. `user_achievements` не содержит названия/изображения. В публичных routes
не найден GET каталога медалей; HTML-профиль сайта получает отдельный `achievements`.
Не добавлены scraping, сторонний сервис или захардкоженные ID→asset догадки.
Нужен отдельный проверенный справочник/источник метаданных, прежде чем считать
иллюстрированную коллекцию законченной. Это не смешивается с profile `badges`.

Контракты сверены 2026-09-09 по официальным исходникам:
- [UsersController::showUserIncludes](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/UsersController.php)
- [UserCompactTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/UserCompactTransformer.php)
- [GroupTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/GroupTransformer.php) / [TeamTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/TeamTransformer.php)
- [MatchmakingUserStatsTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/MatchmakingUserStatsTransformer.php) / [MatchmakingPoolTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/MatchmakingPoolTransformer.php)
- [DailyChallengeUserStatsTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/DailyChallengeUserStatsTransformer.php)
- [UserAchievementTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/UserAchievementTransformer.php)

Далее: индикаторы сложностей, детализация результата по референсу, шрифт цифр
с лицензией, иллюстрированный каталог медалей. Daily challenge здесь — статистика
участия пользователя, не отдельный экран сегодняшнего beatmap/room.

## Ручная проверка

- Имена: длинные никнеймы, раскрытие/Back/двойной тап; группы с `has_listing=false`,
  команда с отсутствующим флагом; ссылки только в официальный сайт.
- Профиль без optional sections; пустые медали/пулы; provisional rating, смена
  ruleset без смешивания статистики, даты медалей/серий и длинные переводы.
- Нативный/визуальный результат нового блока ещё не проверен: только чистый
  analyze, format, diff-check; APK/catalog и тесты не запускались.

- RU/DE/JA и увеличенный текст: карточки, целые PP, длинные счётчики/tooltip.
- Профиль с `monthly_playcounts`: отдельный график игр, реальные месяцы/пропуски.
- Картинки: первый выбор, отказ/перезапуск, allow/перезапуск, выключение в guest,
  background/другая вкладка; технически недоступная картинка не зависает.
- Share: оба типа кнопки, все перечисленные страницы и вложенная модалка;
  copy, dismiss/Back/двойной тап, получатель установлен/не установлен, ошибки
  браузера, Telegram/WA/Facebook/X после входа. Native plugin требует полного
  перезапуска приложения пользователем; hot reload недостаточен.
- Проверки агента только format/analyze/diff; APK и тесты не запускались.
