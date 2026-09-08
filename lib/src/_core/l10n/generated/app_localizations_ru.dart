// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

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
  String get profileAboutNotice =>
      'Внешние изображения загружаются автоматически. Их серверы получают ваш IP-адрес и могут записывать запросы. Вставки открываются только в оригинале. Если готового HTML нет, BBCode показан обычным текстом.';

  @override
  String get profileOriginal => 'Открыть профиль на osu!';

  @override
  String get profileLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get profileAboutUnavailable =>
      'Этот блок нельзя безопасно отобразить. Можно открыть оригинал на osu!.';

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
      'Изображение недоступно или заблокировано ограничениями безопасности.';

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
      'Внешние изображения загружаются автоматически. Их серверы получают ваш IP-адрес и могут записывать запросы. Вставки открываются только в оригинале.';

  @override
  String get spotlightsTitle => 'Подборки Spotlights';

  @override
  String get spotlightsChoose => 'Выбрать подборку';

  @override
  String get spotlightsShowRanking => 'Показать выбранную подборку';

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
          decimalDigits: 2,
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
    return 'Игр: $count';
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
    return 'Рейтинговые очки: $score';
  }

  @override
  String get rankingsCountry => 'Код страны';

  @override
  String get rankingsCountryHint =>
      'Две буквы, например JP или US; пустое поле — весь мир.';

  @override
  String get rankingsCountryInvalid =>
      'Введите код страны из двух латинских букв.';

  @override
  String get rankingsApply => 'Применить страну';

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
