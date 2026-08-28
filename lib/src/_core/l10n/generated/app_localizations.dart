import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracksu'**
  String get appTitle;

  /// No description provided for @guestModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get guestModeTitle;

  /// No description provided for @guestSignedOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse public osu! data as a guest. Signing in will add account features.'**
  String get guestSignedOutDescription;

  /// No description provided for @guestSignedInDescription.
  ///
  /// In en, this message translates to:
  /// **'You are signed in. Public browsing stays available without an account.'**
  String get guestSignedInDescription;

  /// No description provided for @signInWithOsu.
  ///
  /// In en, this message translates to:
  /// **'Sign in with osu!'**
  String get signInWithOsu;

  /// No description provided for @signInWithAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in with another account'**
  String get signInWithAnotherAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get signingOut;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign out. Try again.'**
  String get signOutFailed;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @russianLanguage.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russianLanguage;

  /// No description provided for @loginToOsu.
  ///
  /// In en, this message translates to:
  /// **'Login to osu!'**
  String get loginToOsu;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @openingOsu.
  ///
  /// In en, this message translates to:
  /// **'Opening osu!...'**
  String get openingOsu;

  /// No description provided for @continueWithOsu.
  ///
  /// In en, this message translates to:
  /// **'Continue with osu!'**
  String get continueWithOsu;

  /// No description provided for @authorizationExpired.
  ///
  /// In en, this message translates to:
  /// **'This authorization request has expired. Try again.'**
  String get authorizationExpired;

  /// No description provided for @authorizationResponseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to receive the authorization response.'**
  String get authorizationResponseUnavailable;

  /// No description provided for @authorizationResponseMismatch.
  ///
  /// In en, this message translates to:
  /// **'The authorization response did not match this login attempt.'**
  String get authorizationResponseMismatch;

  /// No description provided for @authorizationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Authorization was cancelled or refused.'**
  String get authorizationCancelled;

  /// No description provided for @authorizationResponseInvalid.
  ///
  /// In en, this message translates to:
  /// **'The authorization response is invalid.'**
  String get authorizationResponseInvalid;

  /// No description provided for @authorizationPreparationFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare osu! authorization.'**
  String get authorizationPreparationFailed;

  /// No description provided for @authorizationLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open osu! authorization.'**
  String get authorizationLaunchFailed;

  /// No description provided for @authorizationCompletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to finish authorization.'**
  String get authorizationCompletionFailed;

  /// No description provided for @authorizationIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Authorization was not completed. Try again.'**
  String get authorizationIncomplete;

  /// No description provided for @viewMyProfile.
  ///
  /// In en, this message translates to:
  /// **'View my profile'**
  String get viewMyProfile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Username or ID'**
  String get profileSearchHint;

  /// No description provided for @rulesetOsu.
  ///
  /// In en, this message translates to:
  /// **'osu!'**
  String get rulesetOsu;

  /// No description provided for @rulesetTaiko.
  ///
  /// In en, this message translates to:
  /// **'taiko'**
  String get rulesetTaiko;

  /// No description provided for @rulesetFruits.
  ///
  /// In en, this message translates to:
  /// **'catch'**
  String get rulesetFruits;

  /// No description provided for @rulesetMania.
  ///
  /// In en, this message translates to:
  /// **'mania'**
  String get rulesetMania;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get profileLoading;

  /// No description provided for @profileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile is unavailable. Try again.'**
  String get profileUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @profileId.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String profileId(int id);

  /// No description provided for @profilePerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance: {pp}'**
  String profilePerformance(double pp);

  /// No description provided for @profileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country: {country}'**
  String profileCountry(String country);

  /// No description provided for @profileAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {accuracy}%'**
  String profileAccuracy(double accuracy);

  /// No description provided for @profilePlayCount.
  ///
  /// In en, this message translates to:
  /// **'Play count: {count}'**
  String profilePlayCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
