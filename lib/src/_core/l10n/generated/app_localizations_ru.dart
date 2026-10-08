// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settingsCacheCalculating => 'Подсчёт размера кэша…';

  @override
  String get settingsCacheFailed =>
      'Не удалось получить доступ к кэшу. Попробуйте снова.';

  @override
  String settingsCacheConfirm(String size) {
    return 'Удалить $size МБ изображений и аудио? Аккаунт и настройки сохранятся.';
  }

  @override
  String settingsCacheSize(String size) {
    return '$size МБ';
  }

  @override
  String get audioPreview => 'Послушать';

  @override
  String get audioPlay => 'Слушать';

  @override
  String get audioPause => 'Пауза';

  @override
  String get audioReplay => 'Слушать снова';

  @override
  String get audioCancel => 'Отменить загрузку';

  @override
  String get audioLoading => 'Загрузка аудио…';

  @override
  String get audioPlaying => 'Воспроизводится';

  @override
  String get audioPaused => 'На паузе';

  @override
  String get audioCompleted => 'Воспроизведение завершено';

  @override
  String get audioFailed =>
      'Не удалось воспроизвести аудио. Проверьте соединение и попробуйте снова.';

  @override
  String get audioFailedUnavailable => 'Это аудио-превью больше недоступно.';

  @override
  String get audioFailedUnsupported =>
      'Этот формат аудио не воспроизводится на устройстве.';

  @override
  String get audioFailedFocus =>
      'Звук занят другим приложением. Попробуйте, когда оно освободит его.';

  @override
  String get audioFailedUnknown => 'Не удалось воспроизвести аудио.';

  @override
  String get audioSeek => 'Позиция воспроизведения';

  @override
  String get teamTitle => 'Команда';

  @override
  String get teamLoading => 'Загрузка команды…';

  @override
  String get teamNotFound => 'Команда не найдена';

  @override
  String get teamAccessDenied => 'Просмотр этой команды недоступен.';

  @override
  String get teamFailed => 'Не удалось загрузить команду. Попробуйте ещё раз.';

  @override
  String get teamOpen => 'Набор открыт';

  @override
  String get teamClosed => 'Набор закрыт';

  @override
  String teamSlots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count свободного места',
      many: '$count свободных мест',
      few: '$count свободных места',
      one: '$count свободное место',
      zero: 'Нет свободных мест',
    );
    return '$_temp0';
  }

  @override
  String teamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String teamCreated(String date) {
    return 'Создана $date';
  }

  @override
  String teamDefaultMode(String mode) {
    return 'Основной режим: $mode';
  }

  @override
  String get teamDescription => 'О команде';

  @override
  String get teamLeader => 'Лидер команды';

  @override
  String teamLastVisit(String date) {
    return 'Был в сети: $date';
  }

  @override
  String get scoreGaugeReference =>
      'Ориентир точности osu!lazer; SS требует 100% (его сектор увеличен для видимости). Грейд взят из результата: промахи, моды и старые правила подсчёта тоже могут влиять на него.';

  @override
  String get settingsCache => 'Кэш';

  @override
  String get settingsClearCache => 'Очистить';

  @override
  String get settingsCacheDescription =>
      'Обложки и превью треков, сохранённые на устройстве.';

  @override
  String get settingsCacheCleared => 'Кэш очищен';

  @override
  String get profileDailyEmpty => 'Игрок ещё не участвовал в карте дня.';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String get aboutTabApp => 'О приложении';

  @override
  String get settingsClearCacheTitle => 'Очистить кэш?';

  @override
  String get aboutHistoryShort =>
      'Tracksu существует с 2021 года и не раз развивался и пересоздавался.';

  @override
  String get aboutTabAuthors => 'Авторы';

  @override
  String get aboutTabLicenses => 'Лицензии';

  @override
  String get aboutRoleAuthor => 'Автор';

  @override
  String get aboutRoleCoauthor => 'Соавтор';

  @override
  String get aboutThanksTitle => 'Благодарности';

  @override
  String get aboutThanksBody =>
      'ppy и команде osu! — за игру и открытый API. Сообществу osu! — за карты, игроков и идеи. Авторам открытых библиотек — их список во вкладке «Лицензии».';

  @override
  String get aboutDescription =>
      'Профили игроков, результаты, карты и новости osu!';

  @override
  String get aboutUnofficial =>
      'Независимый неофициальный клиент. Не связан с ppy Pty Ltd и не одобрен этой компанией.';

  @override
  String get aboutBuild => 'Установленная версия';

  @override
  String get aboutBuildUnavailable =>
      'Не удалось прочитать версию установленного приложения.';

  @override
  String aboutVersion(String version, String build) {
    return 'Версия $version · Сборка $build';
  }

  @override
  String get aboutProject => 'Проект на GitHub';

  @override
  String get aboutOsu => 'Сайт osu!';

  @override
  String get aboutLicensesDescription =>
      'Открытые библиотеки и лицензии ресурсов';

  @override
  String get licensesIntro =>
      'Tracksu построен на открытом ПО. Здесь пакеты внутри приложения и тексты лицензий, которые их авторы просят показывать.';

  @override
  String get licensesSearch => 'Поиск пакетов';

  @override
  String get licensesNoMatch => 'Подходящих пакетов нет.';

  @override
  String licensesPackageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пакета',
      many: '$count пакетов',
      few: '$count пакета',
      one: '$count пакет',
    );
    return '$_temp0';
  }

  @override
  String get aboutLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Как в системе';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSaveFailed => 'Не удалось сохранить тему.';

  @override
  String get spotlightsParticipants => 'Участники';

  @override
  String get spotlightsSearch => 'Название, год или ID';

  @override
  String get spotlightsNoMatch => 'Подходящие подборки не найдены.';

  @override
  String spotlightsStartDate(String date) {
    return 'Дата начала: $date';
  }

  @override
  String spotlightsEndDate(String date) {
    return 'Дата окончания: $date';
  }

  @override
  String get spotlightsKindMonthly => 'Месячная';

  @override
  String get spotlightsKindBestOf => 'Лучшее за год';

  @override
  String get spotlightsKindSpecial => 'Специальная';

  @override
  String get spotlightsKindTheme => 'Тематическая';

  @override
  String get spotlightsRulesetUnavailable => 'Для этого режима рейтинга нет.';

  @override
  String get spotlightsRulesetUnavailableHint =>
      'osu! вела эту подборку не для всех режимов. Выберите другой режим выше.';

  @override
  String get spotlightsHomeDescription =>
      'Старые чарты osu!, последний прошёл в 2020 году. Поддержка Spotlights прекращена — в osu! их заменили Seasons.';

  @override
  String get spotlightsOpen => 'Архив Spotlights';

  @override
  String spotlightsDifficultyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сложности в наборе',
      many: '$count сложностей в наборе',
      few: '$count сложности в наборе',
      one: '$count сложность в наборе',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSignOutConfirm =>
      'Выйти на этом устройстве? Публичный профиль osu! останется доступен.';

  @override
  String get medalsLoading => 'Загрузка медалей…';

  @override
  String get medalsFailed =>
      'Не удалось загрузить описание медалей с osu!. Попробуйте снова.';

  @override
  String get medalsEmpty => 'Пока нет полученных медалей.';

  @override
  String get scoreMiss => 'Промах';

  @override
  String get scoreFruit => 'Фрукты';

  @override
  String get scoreDroplet => 'Капли';

  @override
  String get scoreTinyDroplet => 'Маленькие капли';

  @override
  String get scoreTinyMiss => 'Пропущенные малые капли';

  @override
  String get scoreJudgementPercentNotice =>
      'Проценты — доли показанных оценок попаданий, а не прохождение карты или максимальное комбо. Тики слайдеров и технические legacy-счётчики исключены.';

  @override
  String get profilePreviousNames => 'Прежние имена';

  @override
  String get profileGroups => 'Группы';

  @override
  String profileTeamTag(String tag) {
    return 'Команда · $tag';
  }

  @override
  String get profileMedals => 'Медали';

  @override
  String get profileMedalsView => 'Полученные медали';

  @override
  String profileMedalId(int id) {
    return 'Медаль №$id';
  }

  @override
  String get profileRankedPlay => 'Рейтинговая игра';

  @override
  String get profileRankedPlayEmpty =>
      'Нет статистики рейтинговой игры в этом режиме.';

  @override
  String profileRankedPool(int id) {
    return 'Пул №$id';
  }

  @override
  String get profileProvisionalRating => 'Предварительный рейтинг';

  @override
  String get profileRating => 'Рейтинг';

  @override
  String get profileFirstPlaces => 'Первые места';

  @override
  String get profileRankedPoints => 'Очки матчей';

  @override
  String get profileDailyChallenge => 'Карта дня';

  @override
  String get profileDailyPlays => 'Сыграно испытаний';

  @override
  String get profileDailyCurrent => 'Текущая серия дней';

  @override
  String get profileDailyBest => 'Лучшая серия дней';

  @override
  String get profileWeeklyCurrent => 'Текущая серия недель';

  @override
  String get profileWeeklyBest => 'Лучшая серия недель';

  @override
  String get profileTop10 => 'Попадания в топ 10%';

  @override
  String get profileTop50 => 'Попадания в топ 50%';

  @override
  String profileDailyUpdated(String date) {
    return 'Последнее участие: $date';
  }

  @override
  String profileWeeklyUpdated(String date) {
    return 'Последняя недельная серия: $date';
  }

  @override
  String get shareSystem => 'Другие приложения…';

  @override
  String get shareCopy => 'Копировать ссылку';

  @override
  String get shareCopied => 'Ссылка скопирована';

  @override
  String get shareDestinationNotice =>
      'Выберите получателя в открывшемся приложении или браузере. Ничего не публикуется автоматически. Ссылка ведёт на публичную страницу osu!; превью зависит от приложения получателя.';

  @override
  String get shareAction => 'Поделиться';

  @override
  String get shareBeatmapAction => 'Поделиться картой';

  @override
  String get shareFailed =>
      'Не удалось открыть меню «Поделиться». Попробуйте ещё раз.';

  @override
  String get contentMediaSettings => 'Загружать изображения';

  @override
  String get contentMediaConsent =>
      'Обложки и аватары загружаются автоматически. Выключите, чтобы экономить трафик.';

  @override
  String get contentMediaAllow => 'Разрешить картинки';

  @override
  String get contentMediaDecline => 'Пока не загружать';

  @override
  String get contentMediaDisabled =>
      'Изображения отключены. Включить можно в настройках.';

  @override
  String get contentMediaSaveFailed =>
      'Не удалось сохранить выбор. После перезапуска он может сброситься.';

  @override
  String get contentImageUnsupported =>
      'Адрес этой картинки не поддерживается. Посмотреть её можно на странице оригинала.';

  @override
  String get contentImagePaused => 'Загрузка картинки приостановлена.';

  @override
  String get profilePlayHistoryTitle => 'Игры по месяцам';

  @override
  String rankingsPosition(int position) {
    final intl.NumberFormat positionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String positionString = positionNumberFormat.format(position);

    return 'Место №$positionString';
  }

  @override
  String get rankingsPositionNotice =>
      'Места относятся к выбранной таблице, а не к мировому PP-рейтингу. Рейтинг может измениться между загрузками страниц; обновите список.';

  @override
  String get rankingsCountrySelection => 'Страна или регион';

  @override
  String get rankingsCountrySearch => 'Название страны или код';

  @override
  String get rankingsCountryCatalogHint =>
      'Ищите по названию страны или двухбуквенному коду. Наличие рейтинга зависит от osu!.';

  @override
  String get rankingsCountryCatalogFailed =>
      'Не удалось загрузить список стран.';

  @override
  String get rankingsCountryNoMatch => 'Страны не найдены.';

  @override
  String get rankingsEnd => 'Конец доступного рейтинга.';

  @override
  String get scoreHitsTitle => 'Попадания';

  @override
  String get scoreHitsExplanation =>
      'Типы попаданий указаны как в API. Пропуск — не ноль; максимальные количества относятся к идеальному прохождению, а не к цели в каждой строке.';

  @override
  String get scoreHitsAchieved => 'Получено';

  @override
  String get scoreHitsMaximum => 'При идеальном прохождении';

  @override
  String get scoreModSettingsTitle => 'Настройки модов';

  @override
  String get scoreNoModSettings => 'Явные настройки не переданы.';

  @override
  String get scoreDetailsUnavailable => 'Недоступно';

  @override
  String get scoreSettingEnabled => 'Включено';

  @override
  String get scoreSettingDisabled => 'Выключено';

  @override
  String get beatmapDescription => 'Описание карты';

  @override
  String get contentPageUnavailable =>
      'Этот контент не удалось отобразить здесь. Можно открыть оригинал.';

  @override
  String get scoreDetailsTitle => 'Подробности результата';

  @override
  String get scoreOpenBeatmap => 'Открыть карту';

  @override
  String get scoreStandardisedTotal => 'Стандартизированные очки';

  @override
  String get mapSetPlays => 'Игры набора';

  @override
  String get mapFavourites => 'В избранном';

  @override
  String get mapBpm => 'BPM';

  @override
  String get profileReplayHistoryTitle => 'Просмотры реплеев по месяцам';

  @override
  String get profileReplayHistoryExplanation =>
      'Месяцы без наблюдений пропущены; отсутствие данных не означает ноль.';

  @override
  String get profileAbout => 'О себе';

  @override
  String get contentPageNotice =>
      'Внешние картинки загружаются согласно вашему выбору. Вставки доступны в оригинале. Если готового HTML нет, BBCode показан обычным текстом.';

  @override
  String get contentLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileOverview => 'Профиль';

  @override
  String get profilePpLabel => 'Очки производительности (PP)';

  @override
  String get profileGlobalRankLabel => 'Мировой рейтинг';

  @override
  String get profileCountryRankLabel => 'Рейтинг страны';

  @override
  String get profileStatisticsTitle => 'Статистика';

  @override
  String get profileAccuracyLabel => 'Точность';

  @override
  String get profilePlayCountLabel => 'Количество игр';

  @override
  String get profilePlayTimeLabel => 'Время игры';

  @override
  String get profileComboLabel => 'Максимальное комбо';

  @override
  String get profileValueUnavailable => 'Нет данных';

  @override
  String get profileNotRanked => 'Нет места';

  @override
  String get profileGradesTitle => 'Оценки результатов';

  @override
  String get profileRankedScoreLabel => 'Рейтинговые очки';

  @override
  String get profileTotalScoreLabel => 'Всего очков';

  @override
  String get profileTotalHitsLabel => 'Всего попаданий';

  @override
  String get profileReplaysLabel => 'Просмотры повторов другими';

  @override
  String get profileHistoryTitle => 'История рейтинга';

  @override
  String get profileHistoryEmpty => 'Для этого режима нет истории рейтинга.';

  @override
  String get profileHistoryExplanation =>
      'Наблюдения API по порядку, не календарные даты. Разрывы — отсутствующие значения рейтинга.';

  @override
  String get profileSwitchingMode =>
      'Загружаем выбранный режим. Пока показаны данные предыдущего.';

  @override
  String get profileUpdateFailed =>
      'Обновление не удалось. Сохранены прежние данные и режим.';

  @override
  String profileDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString ч $minutesString мин';
  }

  @override
  String profileLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Уровень $levelString';
  }

  @override
  String profileLevelProgress(int progress) {
    final intl.NumberFormat progressNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String progressString = progressNumberFormat.format(progress);

    return 'Прогресс уровня: $progressString%';
  }

  @override
  String profileHistorySample(int index) {
    final intl.NumberFormat indexNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);

    return 'Наблюдение $indexString';
  }

  @override
  String get navigationSearch => 'Поиск';

  @override
  String get navigationUnavailable => 'Эта страница недоступна.';

  @override
  String get searchClear => 'Очистить поиск';

  @override
  String get contentImage => 'Изображение';

  @override
  String get contentImageLoading => 'Загрузка изображения…';

  @override
  String get contentImageFailed =>
      'Не удалось загрузить картинку. Возможно, она недоступна либо её размер или формат не поддерживается.';

  @override
  String get contentImageUnavailable =>
      'Эта картинка больше недоступна на источнике.';

  @override
  String get contentImageNetwork =>
      'Не удалось связаться с источником картинки. Проверьте соединение и повторите.';

  @override
  String get contentImageFormat => 'Формат этой картинки не поддерживается.';

  @override
  String get contentImageTooLarge => 'Эта картинка слишком большая для показа.';

  @override
  String get contentImageOpen => 'Увеличить изображение';

  @override
  String get contentDisclosure => 'Показать скрытое содержимое';

  @override
  String get contentUnsupported => 'Эта вставка доступна на исходной странице.';

  @override
  String get contentOriginal => 'Открыть оригинал';

  @override
  String get contentUnavailable =>
      'Содержимое недоступно в режиме чтения. Откройте оригинал.';

  @override
  String get uiCatalogMedia => 'Изображения и значки';

  @override
  String get uiCatalogCards => 'Карточки игроков и контента';

  @override
  String get uiCatalogCharts => 'Графики';

  @override
  String get uiCatalogStates => 'Состояния контента';

  @override
  String get uiCatalogSampleNotice =>
      'Демонстрационные данные, не реальная статистика игроков. Существующие изображения Tracksu показывают размещение обложек.';

  @override
  String get uiCatalogHistory => 'История рейтинга';

  @override
  String get uiCatalogActivity => 'Игровая активность';

  @override
  String get uiCatalogSinglePoint => 'Одна точка';

  @override
  String get uiCatalogFlatSeries => 'Без изменений';

  @override
  String get uiCatalogOffline => 'Нет подключения';

  @override
  String get uiCatalogNoData => 'Данных пока нет';

  @override
  String get uiCatalogChartHint =>
      'Нажми или проведи по графику либо используй ползунок. Меньший номер места расположен выше.';

  @override
  String get uiMetricPerformance => 'Очки производительности';

  @override
  String get uiMetricAccuracy => 'Точность';

  @override
  String get uiMetricGlobalRank => 'Мировой рейтинг';

  @override
  String get uiMetricPlayCount => 'Количество игр';

  @override
  String get uiMetricPlayTime => 'Время в игре';

  @override
  String get uiCatalogTitle => 'UI kit';

  @override
  String get uiCatalogTheme => 'Сменить тему';

  @override
  String get uiCatalogTypography => 'Типографика и поверхности';

  @override
  String get uiCatalogButtons => 'Кнопки';

  @override
  String get uiCatalogInputs => 'Ввод и выбор';

  @override
  String get uiCatalogFeedback => 'Сообщения';

  @override
  String get uiCatalogNavigation => 'Навигация';

  @override
  String get uiCatalogConfirmMessage =>
      'Это подтверждение действия в каталоге. Аккаунт и данные не изменятся.';

  @override
  String get newsTitle => 'Новости';

  @override
  String get newsRefresh => 'Обновить новости';

  @override
  String get newsEmpty => 'Новостей пока нет.';

  @override
  String get newsLoadMore => 'Загрузить ещё новости';

  @override
  String get newsLoading => 'Загружаем новости…';

  @override
  String get newsKeepingContent => 'Показаны ранее загруженные данные.';

  @override
  String get newsNotFound => 'Эта новость недоступна.';

  @override
  String get newsCancelled => 'Загрузка новости отменена.';

  @override
  String get newsAccessDenied => 'Нет доступа к новостям.';

  @override
  String get newsInvalidResponse => 'Не удалось прочитать ответ с новостями.';

  @override
  String get newsUnavailable => 'Новости временно недоступны.';

  @override
  String get newsLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get newsOriginal => 'Открыть оригинал';

  @override
  String get newsReaderNotice =>
      'Внешние картинки загружаются согласно вашему выбору. Вставки доступны в оригинале.';

  @override
  String get spotlightsTitle => 'Подборки Spotlights';

  @override
  String get spotlightsChoose => 'Выбрать подборку';

  @override
  String get spotlightsEmpty => 'Нет доступных подборок.';

  @override
  String get spotlightsMaps => 'Наборы карт';

  @override
  String get spotlightsNoMaps =>
      'В этой подборке нет карт для выбранного режима.';

  @override
  String get spotlightsRankingLimit => 'Рейтинг подборки · до 40 игроков';

  @override
  String get spotlightsNotFound => 'Подборка недоступна.';

  @override
  String get appTitle => 'Tracksu';

  @override
  String get guestModeTitle => 'Гостевой режим';

  @override
  String get guestSignedOutDescription =>
      'Просматривайте публичные данные osu! в гостевом режиме. Вход добавит возможности аккаунта.';

  @override
  String get guestSignedInDescription =>
      'Вы вошли в аккаунт. Публичные данные доступны и без него.';

  @override
  String get signInWithOsu => 'Войти через osu!';

  @override
  String get signInWithAnotherAccount => 'Войти в другой аккаунт';

  @override
  String get signOut => 'Выйти';

  @override
  String get signingOut => 'Выход из аккаунта...';

  @override
  String get signOutFailed =>
      'Не удалось выйти из аккаунта. Повторите попытку.';

  @override
  String get systemLanguage => 'Язык системы';

  @override
  String get englishLanguage => 'Английский';

  @override
  String get russianLanguage => 'Русский';

  @override
  String get loginToOsu => 'Вход в osu!';

  @override
  String get signingIn => 'Выполняется вход...';

  @override
  String get openingOsu => 'Открываем osu!...';

  @override
  String get continueWithOsu => 'Продолжить через osu!';

  @override
  String get authorizationExpired =>
      'Срок действия запроса на авторизацию истёк. Повторите попытку.';

  @override
  String get authorizationResponseUnavailable =>
      'Не удалось получить ответ авторизации.';

  @override
  String get authorizationResponseMismatch =>
      'Ответ авторизации не соответствует этой попытке входа.';

  @override
  String get authorizationCancelled =>
      'Авторизация была отменена или отклонена.';

  @override
  String get authorizationResponseInvalid =>
      'Ответ авторизации имеет неверный формат.';

  @override
  String get authorizationPreparationFailed =>
      'Не удалось подготовить авторизацию в osu!.';

  @override
  String get authorizationLaunchFailed =>
      'Не удалось открыть авторизацию в osu!.';

  @override
  String get authorizationCompletionFailed =>
      'Не удалось завершить авторизацию.';

  @override
  String get authorizationIncomplete =>
      'Авторизация не была завершена. Повторите попытку.';

  @override
  String get viewMyProfile => 'Мой профиль';

  @override
  String get profileSearchHint => 'Ник или ID';

  @override
  String get profileSearchInvalid =>
      'Введите корректное имя пользователя или положительный ID.';

  @override
  String get rulesetOsu => 'ctd';

  @override
  String get rulesetTaiko => 'taiko';

  @override
  String get rulesetFruits => 'catch';

  @override
  String get rulesetMania => 'mania';

  @override
  String get profileLoading => 'Загружаем профиль...';

  @override
  String get profileUnavailable => 'Профиль недоступен. Повторите попытку.';

  @override
  String get retry => 'Повторить';

  @override
  String profileId(int id) {
    return 'ID: $id';
  }

  @override
  String profilePerformance(double pp) {
    final intl.NumberFormat ppNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 0,
        );
    final String ppString = ppNumberFormat.format(pp);

    return 'Рейтинг: $ppString';
  }

  @override
  String profileCountry(String country) {
    return 'Страна: $country';
  }

  @override
  String profileAccuracy(double accuracy) {
    final intl.NumberFormat accuracyNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 2,
        );
    final String accuracyString = accuracyNumberFormat.format(accuracy);

    return 'Точность: $accuracyString%';
  }

  @override
  String profilePlayCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Количество игр: $countString';
  }

  @override
  String get profileSearchIntroduction =>
      'Откройте профиль игрока по точному нику или ID. Вход не нужен.';

  @override
  String get profileSearchHelp =>
      'Ищите игрока по нику или введите точный ID. Для точного ника, в том числе числового, используйте @.';

  @override
  String get profileOpen => 'Открыть профиль';

  @override
  String get profileSearch => 'Найти игрока';

  @override
  String get profileRefreshing => 'Обновление профиля';

  @override
  String get profileRefresh => 'Обновить';

  @override
  String get profileShowingPreviousData =>
      'Обновление не удалось. Показаны ранее загруженные данные.';

  @override
  String get profileNotFound => 'Игрок не найден. Проверьте имя или ID.';

  @override
  String get profileAccessDenied =>
      'osu! отказал в доступе. Для своего профиля попробуйте войти заново.';

  @override
  String get profileRateLimited =>
      'Слишком много запросов. Подождите перед повтором.';

  @override
  String get profileConnectionFailed =>
      'Не удалось подключиться. Проверьте интернет и повторите.';

  @override
  String get profileInvalidResponse =>
      'Сервер вернул неподдерживаемый ответ профиля.';

  @override
  String get profileOnline => 'В сети';

  @override
  String get profileOffline => 'Не в сети';

  @override
  String get profileSupporter => 'osu!supporter';

  @override
  String get profileSupporterInfo =>
      'У игрока есть osu!supporter — добровольная подписка, на которую osu! живёт без рекламы. Супортеры получают дополнительные возможности: больше друзей, обложку профиля, загрузку карт прямо из игры.';

  @override
  String get actionGotIt => 'Понятно';

  @override
  String get profileNoStatistics => 'Для этого режима пока нет статистики.';

  @override
  String get profileUnranked => 'Нет места в мировом рейтинге';

  @override
  String profileGlobalRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Мировой рейтинг: #$rankString';
  }

  @override
  String profileCountryRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Рейтинг страны: #$rankString';
  }

  @override
  String profilePlayTime(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return 'Время игры: $hoursString ч';
  }

  @override
  String profileMaximumCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'Максимальное комбо: $comboString';
  }

  @override
  String get languageChangeFailed => 'Не удалось сохранить язык.';

  @override
  String get languageSelection => 'Язык';

  @override
  String get account => 'Аккаунт';

  @override
  String get scoresTitle => 'Результаты';

  @override
  String get scoresBest => 'Лучшие';

  @override
  String get scoresPinned => 'Закреплённые';

  @override
  String get scoresFirsts => 'Первые места';

  @override
  String get scoresRecent => 'Последние';

  @override
  String get scoresRefresh => 'Обновить результаты';

  @override
  String get scoresLoading => 'Загрузка результатов…';

  @override
  String get scoresEmpty => 'У игрока нет результатов для этого режима.';

  @override
  String get scoresLoadMore => 'Загрузить ещё';

  @override
  String get scoresKeepingContent => 'Ранее загруженные результаты сохранены.';

  @override
  String get scoresCancelled => 'Загрузка отменена.';

  @override
  String get scoresNotFound => 'Результаты не найдены.';

  @override
  String get scoresAccessDenied => 'osu! отказал в доступе к результатам.';

  @override
  String get scoresInvalidResponse =>
      'Сервер вернул неподдерживаемый ответ результатов.';

  @override
  String get scoresUnavailable => 'Результаты временно недоступны.';

  @override
  String get scoresNoMods => 'Без модов';

  @override
  String get scoresNoPp => 'PP недоступны';

  @override
  String get scoresFailedPlay => 'Неудачная попытка';

  @override
  String scoresBeatmap(int id) {
    return 'Карта №$id';
  }

  @override
  String scoresGrade(String grade) {
    return 'Оценка: $grade';
  }

  @override
  String gradeSilver(String grade) {
    return 'Серебряная $grade';
  }

  @override
  String scoresCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'Комбо: $comboString';
  }

  @override
  String scoresTotal(int total) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Счёт: $totalString';
  }

  @override
  String scoresMods(String mods) {
    return 'Моды: $mods';
  }

  @override
  String scoresPlayedAt(String date) {
    return 'Сыграно: $date';
  }

  @override
  String get beatmapsTitle => 'Карты';

  @override
  String get beatmapsMostPlayed => 'Чаще всего играемые';

  @override
  String get beatmapsFavourite => 'Избранные';

  @override
  String get beatmapsRanked => 'Рейтинговые';

  @override
  String get beatmapsPending => 'На рассмотрении';

  @override
  String get beatmapsGraveyard => 'Заброшенные';

  @override
  String get beatmapsLoved => 'Любимые сообществом';

  @override
  String get beatmapsGuest => 'Гостевые сложности';

  @override
  String get beatmapsNominated => 'Номинированные';

  @override
  String get beatmapsRefresh => 'Обновить карты';

  @override
  String get beatmapsCategory => 'Категория карт';

  @override
  String get scoresCategory => 'Тип результатов';

  @override
  String get beatmapsGroupPlayer => 'Игрок';

  @override
  String get beatmapsGroupMapper => 'Маппер';

  @override
  String get beatmapsEmpty => 'В этой категории пока нет карт.';

  @override
  String get beatmapsLoadMore => 'Загрузить ещё карты';

  @override
  String get beatmapsLoading => 'Загрузка карт…';

  @override
  String get beatmapsKeepingContent =>
      'Обновить не удалось. Показаны ранее загруженные карты.';

  @override
  String get beatmapsCancelled => 'Загрузка отменена.';

  @override
  String get beatmapsNotFound => 'Карты этого игрока не найдены.';

  @override
  String get beatmapsAccessDenied => 'Сейчас нет доступа к картам.';

  @override
  String get beatmapsInvalidResponse =>
      'Сервер вернул неожиданный ответ со списком карт.';

  @override
  String get beatmapsUnavailable =>
      'Не удалось загрузить карты. Попробуйте ещё раз.';

  @override
  String beatmapsSetFallback(int id) {
    return 'Набор карт №$id';
  }

  @override
  String beatmapsMapFallback(int id) {
    return 'Карта №$id';
  }

  @override
  String beatmapsPlayCount(int count) {
    return 'Игр у игрока: $count';
  }

  @override
  String get beatmapTitle => 'Карта';

  @override
  String get beatmapNotFound => 'Карта не найдена.';

  @override
  String get beatmapAccessDenied =>
      'Нет доступа к карте или таблице результатов.';

  @override
  String get beatmapInvalidResponse => 'Некорректный ответ с данными карты.';

  @override
  String get beatmapUnavailable => 'Не удалось загрузить данные карты.';

  @override
  String get beatmapLeaderboard => 'Лучшие результаты';

  @override
  String get beatmapRefreshLeaderboard => 'Обновить результаты';

  @override
  String get beatmapNoScores => 'Нет доступных результатов.';

  @override
  String beatmapLeaderboardPlayer(int position, String name) {
    return '№$position · $name';
  }

  @override
  String beatmapPlayerId(int id) {
    return 'Игрок №$id';
  }

  @override
  String beatmapCreator(String name) {
    return 'Автор: $name';
  }

  @override
  String get beatmapRefresh => 'Обновить карту';

  @override
  String get beatmapDifficulties => 'Сложности';

  @override
  String get beatmapNoDifficulties => 'Нет доступных сложностей.';

  @override
  String beatmapDifficultyInfo(String mode, double stars, int seconds) {
    return '$mode · $stars ★ · $seconds с';
  }

  @override
  String get rankingsTitle => 'Рейтинги';

  @override
  String get rankingsScore => 'Очки';

  @override
  String get rankingsRefresh => 'Обновить рейтинг';

  @override
  String get rankingsEmpty => 'Игроки не найдены.';

  @override
  String get rankingsLoadMore => 'Загрузить ещё';

  @override
  String get rankingsLoading => 'Загрузка рейтинга…';

  @override
  String get rankingsKeepingContent =>
      'Обновить не удалось. Показан ранее загруженный рейтинг.';

  @override
  String get rankingsCancelled => 'Загрузка отменена.';

  @override
  String get rankingsNotFound => 'Рейтинг не найден.';

  @override
  String get rankingsAccessDenied => 'Нет доступа к рейтингу.';

  @override
  String get rankingsInvalidResponse => 'Некорректный ответ рейтинга.';

  @override
  String get rankingsUnavailable => 'Не удалось загрузить рейтинг.';

  @override
  String rankingsRankedScore(int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Рейтинговые очки: $scoreString';
  }

  @override
  String get rankingsCountry => 'Код страны';

  @override
  String get rankingsCountryInvalid =>
      'Введите код страны из двух латинских букв.';

  @override
  String get rankingsWorldwide => 'Весь мир';

  @override
  String get rankingsAllKeys => 'Все';

  @override
  String get rankingsPlayers => 'Игроки';

  @override
  String get rankingsTeams => 'Команды';

  @override
  String get germanLanguage => 'Немецкий';

  @override
  String get frenchLanguage => 'Французский';

  @override
  String get spanishLanguage => 'Испанский';

  @override
  String get japaneseLanguage => 'Японский';

  @override
  String get chineseLanguage => 'Китайский (упрощённый)';

  @override
  String get scrollToTop => 'Наверх';

  @override
  String get dailyTitle => 'Карта дня';

  @override
  String dailyRemaining(String time) {
    return 'Осталось $time';
  }

  @override
  String dailyParticipants(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString игрока',
      many: '$countString игроков',
      few: '$countString игрока',
      one: '$countString игрок',
    );
    return '$_temp0';
  }

  @override
  String get dailyNone => 'Сейчас карты дня нет.';

  @override
  String get dailyLeaderboard => 'Рейтинг дня';

  @override
  String get dailyOpenMap => 'Открыть карту';

  @override
  String get dailyFailed => 'Не удалось загрузить карту дня.';

  @override
  String get contentVideoPlay => 'Смотреть видео';

  @override
  String get contentVideoPause => 'Пауза';

  @override
  String get contentVideoFullscreen => 'Во весь экран';

  @override
  String get contentVideoExitFullscreen => 'Выйти из полноэкранного режима';

  @override
  String get contentVideoFailed => 'Не удалось воспроизвести видео.';

  @override
  String get contentEmbedYoutube => 'Смотреть на YouTube';

  @override
  String contentEmbedOpen(String host) {
    return 'Открыть на $host';
  }

  @override
  String get commentsTitle => 'Комментарии';

  @override
  String commentsTitleCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString комментария',
      many: '$countString комментариев',
      few: '$countString комментария',
      one: '$countString комментарий',
    );
    return '$_temp0';
  }

  @override
  String get commentsSortNew => 'Новые';

  @override
  String get commentsSortOld => 'Старые';

  @override
  String get commentsSortTop => 'Лучшие';

  @override
  String get commentsLoading => 'Загрузка комментариев';

  @override
  String get commentsFailed => 'Не удалось загрузить комментарии.';

  @override
  String get commentsEmpty => 'Комментариев пока нет.';

  @override
  String get commentsDeleted => 'Комментарий удалён';

  @override
  String get commentsEdited => 'изменён';

  @override
  String get commentsPinned => 'Закреплён';

  @override
  String get commentsUnknownUser => 'Удалённый пользователь';

  @override
  String commentsVotes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString голоса',
      many: '$countString голосов',
      few: '$countString голоса',
      one: '$countString голос',
    );
    return '$_temp0';
  }

  @override
  String commentsReplies(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ответа',
      many: '$countString ответов',
      few: '$countString ответа',
      one: '$countString ответ',
    );
    return '$_temp0';
  }

  @override
  String get commentsHideReplies => 'Скрыть ответы';

  @override
  String get commentsMoreReplies => 'Ещё ответы';

  @override
  String get commentsJustNow => 'только что';

  @override
  String commentsMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString мин назад',
      many: '$countString мин назад',
      few: '$countString мин назад',
      one: '$countString мин назад',
    );
    return '$_temp0';
  }

  @override
  String commentsHoursAgo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ч назад',
      many: '$countString ч назад',
      few: '$countString ч назад',
      one: '$countString ч назад',
    );
    return '$_temp0';
  }

  @override
  String commentsDaysAgo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString дня назад',
      many: '$countString дней назад',
      few: '$countString дня назад',
      one: '$countString день назад',
    );
    return '$_temp0';
  }

  @override
  String get rankingsCountries => 'Страны';

  @override
  String rankingsCountryPlayers(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString активного игрока',
      many: '$countString активных игроков',
      few: '$countString активных игрока',
      one: '$countString активный игрок',
    );
    return '$_temp0';
  }

  @override
  String get beatmapSearchTitle => 'Поиск карт';

  @override
  String get beatmapSearchHomeDescription =>
      'Ранкнутые, лавнутые и другие карты osu!';

  @override
  String get beatmapSearchHint => 'Название, исполнитель или маппер';

  @override
  String get beatmapSearchStatus => 'Статус карт';

  @override
  String get beatmapSearchLeaderboard => 'С таблицей рекордов';

  @override
  String get beatmapSearchQualified => 'Квалифицированные';

  @override
  String get beatmapSearchWip => 'В работе';

  @override
  String get beatmapSearchAny => 'Любой статус';

  @override
  String get beatmapSearchEmpty => 'Ничего не найдено.';

  @override
  String get beatmapSearchFailed => 'Не удалось выполнить поиск.';

  @override
  String beatmapSearchFound(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $countString карты',
      many: 'Найдено $countString карт',
      few: 'Найдено $countString карты',
      one: 'Найдена $countString карта',
    );
    return '$_temp0';
  }

  @override
  String get aboutBuiltWithFlutter => 'Разработано на Flutter';

  @override
  String get commentsReply => 'Ответить';

  @override
  String get commentsVoteOnSite => 'Голосовать и отвечать можно на osu.ppy.sh';

  @override
  String get dailyHistory => 'Прошлые дни';

  @override
  String get dailyHistoryDescription => 'Прошлые карты дня и итоговые рейтинги';

  @override
  String get dailyHistoryLimit => 'Показаны последние дни: не более 250';

  @override
  String get dailyHistoryEmpty => 'Прошлых дней пока нет';

  @override
  String get dailyPastUnavailable => 'Карта за этот день недоступна';

  @override
  String get leaderboardModsTitle => 'Фильтр по модам';

  @override
  String get leaderboardModsAll => 'Все моды';

  @override
  String get leaderboardModsReset => 'Сбросить';

  @override
  String get leaderboardModsApply => 'Применить';

  @override
  String get beatmapKeys => 'Клавиши';

  @override
  String get beatmapCircleSize => 'Размер нот (CS)';

  @override
  String get beatmapHpDrain => 'Потеря HP';

  @override
  String get beatmapAccuracy => 'Точность (OD)';

  @override
  String get beatmapApproachRate => 'Скорость появления (AR)';

  @override
  String get beatmapMaxCombo => 'Макс. комбо';

  @override
  String get beatmapObjects => 'Объекты';

  @override
  String get beatmapPlays => 'Попытки';

  @override
  String get beatmapPassRate => 'Доля прохождений';

  @override
  String get beatmapSearchAnyMode => 'Все';

  @override
  String get beatmapSearchGenre => 'Жанр';

  @override
  String get beatmapSearchAnyGenre => 'Любой жанр';

  @override
  String get beatmapSearchLanguage => 'Язык';

  @override
  String get beatmapSearchAnyLanguage => 'Любой язык';

  @override
  String get genreUnspecified => 'Не указан';

  @override
  String get genreVideoGame => 'Видеоигры';

  @override
  String get genreAnime => 'Аниме';

  @override
  String get genreRock => 'Рок';

  @override
  String get genrePop => 'Поп';

  @override
  String get genreOther => 'Другое';

  @override
  String get genreNovelty => 'Юмористическая';

  @override
  String get genreHipHop => 'Хип-хоп';

  @override
  String get genreElectronic => 'Электронная';

  @override
  String get genreMetal => 'Метал';

  @override
  String get genreClassical => 'Классическая';

  @override
  String get genreFolk => 'Фолк';

  @override
  String get genreJazz => 'Джаз';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get languageChinese => 'Китайский';

  @override
  String get languageInstrumental => 'Без слов';

  @override
  String get languageKorean => 'Корейский';

  @override
  String get languageFrench => 'Французский';

  @override
  String get languageGerman => 'Немецкий';

  @override
  String get languageSwedish => 'Шведский';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languageItalian => 'Итальянский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languagePolish => 'Польский';

  @override
  String get languageOther => 'Другой';

  @override
  String get languageUnspecified => 'Не указан';

  @override
  String get rankingsKudosu => 'Kudosu';

  @override
  String get rankingsKudosuHint =>
      'Лучшие участники по сумме kudosu за помощь мапперам. До 1000 игроков.';

  @override
  String rankingsKudosuAvailable(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Доступно kudosu: $countString';
  }

  @override
  String get unifiedSearchTitle => 'Поиск игроков и карт';

  @override
  String get unifiedSearchDescription => 'Игроки, карты и точный поиск по ID';

  @override
  String get unifiedSearchMaps => 'Карты';

  @override
  String get unifiedSearchPrompt => 'Введите хотя бы два символа';

  @override
  String get userSearchEmpty => 'Игроки не найдены';

  @override
  String get userSearchFailed => 'Не удалось загрузить игроков';

  @override
  String get userSearchLimit => 'Показаны первые 100 игроков. Уточните запрос.';

  @override
  String get profileActivity => 'Активность';

  @override
  String get activityEmpty => 'Недавней активности нет';

  @override
  String get activityLoading => 'Загружаем активность';

  @override
  String get activityFailed => 'Не удалось загрузить активность';

  @override
  String activityRank(int rank, String beatmap) {
    return '#$rank место на $beatmap';
  }

  @override
  String activityRankLost(String beatmap) {
    return 'Первое место на $beatmap потеряно';
  }

  @override
  String activityMedal(String medal) {
    return 'Получена медаль «$medal»';
  }

  @override
  String activityPlaycount(String beatmap, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# раза',
      many: '# раз',
      few: '# раза',
      one: '# раз',
    );
    return '$beatmap сыграна $_temp0';
  }

  @override
  String activityApproved(String beatmapset, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'ranked': 'стала рейтинговой',
      'approved': 'одобрена',
      'qualified': 'квалифицирована',
      'loved': 'попала в Loved',
      'other': 'обновлена',
    });
    return 'Карта $beatmapset $_temp0';
  }

  @override
  String activityUpload(String beatmapset) {
    return 'Загружена новая карта $beatmapset';
  }

  @override
  String activityUpdate(String beatmapset) {
    return 'Обновлена карта $beatmapset';
  }

  @override
  String activityRevive(String beatmapset) {
    return 'Карта $beatmapset возвращена с кладбища';
  }

  @override
  String activityDelete(String beatmapset) {
    return 'Карта $beatmapset удалена';
  }

  @override
  String get activitySupportFirst => 'Впервые поддержка osu! — osu!supporter';

  @override
  String get activitySupportAgain => 'Снова поддержка osu!';

  @override
  String get activitySupportGift => 'Получен osu!supporter в подарок';

  @override
  String activityUsernameChange(String previous, String current) {
    return 'Ник изменён: $previous → $current';
  }

  @override
  String profileFollowers(int count) {
    return 'Подписчики: $count';
  }

  @override
  String profileMappingFollowers(int count) {
    return 'Подписчики на карты: $count';
  }

  @override
  String get hubTitle => 'osu!';

  @override
  String get changelogTitle => 'Изменения';

  @override
  String get changelogLoading => 'Загружаем изменения';

  @override
  String get changelogEmpty => 'Изменений пока нет';

  @override
  String get changelogFailed => 'Не удалось загрузить изменения';

  @override
  String get changelogAllStreams => 'Все';

  @override
  String changelogUsers(String count) {
    return '$count игроков';
  }

  @override
  String get changelogTypeAdd => 'Добавлено';

  @override
  String get changelogTypeFix => 'Исправлено';

  @override
  String get changelogTypeMisc => 'Изменено';

  @override
  String get changelogOpenLink => 'Открыть в браузере';

  @override
  String get settingsCacheEnabled => 'Кэшировать данные';

  @override
  String get eventsTitle => 'События';

  @override
  String get eventsLoading => 'Загружаем события';

  @override
  String get eventsEmpty => 'Событий пока нет';

  @override
  String get eventsFailed => 'Не удалось загрузить события';

  @override
  String get eventsFilter => 'Тип событий';

  @override
  String get eventsAll => 'Все события';

  @override
  String get eventsRanks => 'Рекорды';

  @override
  String get eventsMedals => 'Медали';

  @override
  String get eventsBeatmaps => 'Карты';

  @override
  String get eventsSupporters => 'Supporter и ники';

  @override
  String get wikiTitle => 'Вики';

  @override
  String get wikiLoading => 'Загружаем вики';

  @override
  String get wikiFailed => 'Не удалось загрузить вики';

  @override
  String get wikiNotFound => 'Статья не найдена';

  @override
  String get wikiShownInEnglish =>
      'Перевода пока нет — показана английская статья.';

  @override
  String get wikiSearchHint => 'Статья вики';

  @override
  String get wikiSearchHelp => 'Гайды, правила, режимы игры и всё об osu!.';

  @override
  String get wikiNoResults => 'Статьи не найдены';

  @override
  String get eventsLoadOlder => 'Загрузить ещё';

  @override
  String get changelogShowText => 'Показать текст';

  @override
  String get webPageLoading => 'Загружаем страницу';

  @override
  String get webPageFailed => 'Не удалось загрузить страницу';

  @override
  String get webPageOpenInBrowser => 'Открыть в браузере';

  @override
  String get eventsGroupEmpty => 'Среди загруженных событий таких нет';

  @override
  String get eventsGroupHint =>
      'Фильтр работает по уже загруженной ленте. Загрузите более старые события, чтобы посмотреть дальше.';

  @override
  String get forumTitle => 'Форум';

  @override
  String get forumLoading => 'Загружаем форум';

  @override
  String get forumFailed => 'Не удалось загрузить форум';

  @override
  String get forumNotFound => 'Этот раздел или тема недоступны';

  @override
  String get forumEmpty => 'Тем пока нет';

  @override
  String get forumSubforums => 'Подразделы';

  @override
  String get forumTopics => 'Темы';

  @override
  String get forumPinned => 'Закреплено';

  @override
  String get forumAnnouncement => 'Объявление';

  @override
  String get forumLocked => 'Закрыто';

  @override
  String forumReplies(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ответа',
      many: '$countString ответов',
      few: '$countString ответа',
      one: '$countString ответ',
    );
    return '$_temp0';
  }

  @override
  String forumViews(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString просмотра',
      many: '$countString просмотров',
      few: '$countString просмотра',
      one: '$countString просмотр',
    );
    return '$_temp0';
  }

  @override
  String get forumPostUnavailable => 'Этот пост нельзя показать здесь';

  @override
  String get settingsImages => 'Изображения';

  @override
  String get navigationHome => 'Главная';
}
