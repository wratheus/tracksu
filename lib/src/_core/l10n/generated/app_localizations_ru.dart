// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

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
  String get profileTitle => 'Профиль';

  @override
  String get profileSearchHint => 'Имя пользователя или ID';

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
      'Найдите игрока osu!, чтобы посмотреть профиль и статистику. Вход не нужен.';

  @override
  String get profileSearchHelp =>
      'Для числового имени добавьте @ перед именем.';

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
}
