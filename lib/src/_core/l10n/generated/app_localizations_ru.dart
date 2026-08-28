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
    return 'Рейтинг: $pp';
  }

  @override
  String profileCountry(String country) {
    return 'Страна: $country';
  }

  @override
  String profileAccuracy(double accuracy) {
    return 'Точность: $accuracy%';
  }

  @override
  String profilePlayCount(int count) {
    return 'Количество игр: $count';
  }
}
