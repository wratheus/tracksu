// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get spotlightsParticipants => 'Участники';

  @override
  String get spotlightsSearch => 'Название, год или ID';

  @override
  String get spotlightsNoMatch => 'Подходящие подборки не найдены.';

  @override
  String spotlightsPeriod(String start, String end) {
    return '$start — $end';
  }

  @override
  String spotlightsStarts(String date) {
    return 'С $date';
  }

  @override
  String spotlightsEnds(String date) {
    return 'До $date';
  }

  @override
  String spotlightsDifficultyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# сложности в наборе',
      many: '# сложностей в наборе',
      few: '# сложности в наборе',
      one: '# сложность в наборе',
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
  String get contentMediaSettings => 'Внешние изображения';

  @override
  String get contentMediaConsent =>
      'Картинки внутри профилей, описаний карт и новостей скачиваются с внешних серверов. Эти серверы получают ваш IP-адрес и могут записывать запросы. Выбор действует для всех таких картинок на этом устройстве; изменить его можно в меню аккаунта. Аватары и обложки карт с osu! загружаются отдельно.';

  @override
  String get contentMediaAllow => 'Разрешить картинки';

  @override
  String get contentMediaDecline => 'Пока не загружать';

  @override
  String get contentMediaDisabled =>
      'Внешние картинки отключены. Включить их можно в меню аккаунта.';

  @override
  String get contentMediaSaveFailed =>
      'Не удалось сохранить выбор. После перезапуска он может сброситься.';

  @override
  String get contentImageUnsupported =>
      'Адрес этой картинки не поддерживается. Посмотреть её можно на странице оригинала.';

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
      'Поиск по английскому названию или коду из двух букв. Часть стран указана только кодом. Доступность рейтинга зависит от osu!.';

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
  String get scoreModSettingsExplanation =>
      'Названия параметров сохранены из API. Показаны только переданные настройки — значения по умолчанию не подставляются.';

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
  String get profileOverview => 'Обзор';

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
  String get spotlightsNotFound => 'Подборка или выбранный режим недоступны.';

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
  String get profileSearchHint => 'Точный ник или ID';

  @override
  String get profileSearchInvalid =>
      'Введите корректное имя пользователя или положительный ID.';

  @override
  String get rulesetOsu => 'osu!';

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
      'Выберите режим статистики, введите полный ник или ID и нажмите кнопку. Подсказок при вводе пока нет. Для числового ника добавьте @.';

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
  String get rankingsAllKeys => 'Все варианты клавиш';

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
}
