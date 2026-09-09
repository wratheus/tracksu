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

Медали: отдельная страница с названием, описанием, картинкой, датой, Share и
обновлением. `user_achievements` по-прежнему не содержит метаданных: изолированный
public web client читает `data-initial-data.achievements` официального HTML-профиля.
Remote source возвращает строку; repository декодирует HTML/JSON и соединяет
награды по ID, проверяет владельца/размер коллекции, разрешает artwork только
с HTTPS assets.ppy.sh/s.ppy.sh. BLoC отменяет запрос при уходе, игнорирует двойное
обновление, сохраняет коллекцию при ошибке refresh. Ни cookies, ни OAuth headers.
Это осознанный нестабильный web-контракт, не обещание REST API: при изменении
bootstrap показывается ошибка/retry. Имена приходят на языке сервера; оболочка
локализована. При отсутствии отдельного имени в каталоге остаётся честный ID.
Не смешивать с profile `badges`; не добавлять захардкоженные ID→asset догадки.

Контракты сверены 2026-09-09 по официальным исходникам:
- [UsersController::showUserIncludes](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/UsersController.php)
- [UserCompactTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/UserCompactTransformer.php)
- [GroupTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/GroupTransformer.php) / [TeamTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/TeamTransformer.php)
- [MatchmakingUserStatsTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/MatchmakingUserStatsTransformer.php) / [MatchmakingPoolTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/MatchmakingPoolTransformer.php)
- [DailyChallengeUserStatsTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/DailyChallengeUserStatsTransformer.php)
- [UserAchievementTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/UserAchievementTransformer.php)

Следующий UI-срез реализован: розовые столбики monthly plays (реальные x и
пропуски), команда у аватара профиля/рейтингов, daily challenge/team/ranked play
над общей статистикой. World rank — отдельный крупный показатель, остальные
компактнее; Exo 2 w800, не заявляем точное совпадение с шрифтом osu!.
Карта: cover@2x, широкий баннер, горизонтальный выбор сложности и полный lazy
picker. Галка выбранных chips выключена централизованно. Результат: баннер,
аватар автора из leaderboard, компактные показатели и график judgments с
локальными названиями 300/100/50/MISS; отдельная семантика taiko/mania/catch.
Процент от отображённых попаданий, не от combo/полноты прохождения. Технические
legacy/tick-счётчики не выдаются за оценки. Raw mod settings остаются отдельно.
Общий UiModal.scrollable подбирает высоту по sliver extents без eager layout;
после жеста высотой управляет пользователь. Короткие confirm/info content-fit.
Отдельная страница Settings: картинки, профиль/вход/выход с подтверждением;
аватар аккаунта в верхнем меню, gear рядом. Обновление аватара при смене аккаунта,
отмена и защита от устаревшего ответа; token refresh не вызывает перезагрузку UI.

Далее: ручная проверка новых компонентов, шрифт цифр с лицензией.
График сложности карты отложен до источника реальной strain-серии — не строить
его из BPM, звёзд или количества сложностей. Daily challenge здесь — статистика
участия пользователя, не отдельный экран сегодняшнего beatmap/room.

## Ручная проверка

- Sheet: короткий Share/список, длинные результаты/страны, drag вверх/вниз,
  раскрытие вложенного Share, Back, большой текст/клавиатура. Проверить размеры
  на устройстве: fit основан на оценке lazy slivers, не на полной разметке списка.
- Медали: пустая коллекция, имена/описания/картинки, ошибка HTML-контракта,
  повторный refresh/Back; настройки guest/login/logout/switch account.
- Карта: выбранная сложность, cover@2x, медленный/недоступный арт; score-avatar
  и переход к автору, osu!/taiko/mania/catch judgment totals, missing counts.
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
