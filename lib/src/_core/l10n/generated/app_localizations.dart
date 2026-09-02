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

  /// No description provided for @profileSearchInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid username or positive ID.'**
  String get profileSearchInvalid;

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

  /// No description provided for @profileSearchIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Find an osu! player to view their profile and statistics. No sign-in required.'**
  String get profileSearchIntroduction;

  /// No description provided for @profileSearchHelp.
  ///
  /// In en, this message translates to:
  /// **'Use @ before a numeric username.'**
  String get profileSearchHelp;

  /// No description provided for @profileSearch.
  ///
  /// In en, this message translates to:
  /// **'Find player'**
  String get profileSearch;

  /// No description provided for @profileRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Updating profile'**
  String get profileRefreshing;

  /// No description provided for @profileRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get profileRefresh;

  /// No description provided for @profileShowingPreviousData.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Previously loaded data is shown.'**
  String get profileShowingPreviousData;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Player not found. Check the name or ID.'**
  String get profileNotFound;

  /// No description provided for @profileAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied by osu!. For your own profile, try signing in again.'**
  String get profileAccessDenied;

  /// No description provided for @profileRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait before trying again.'**
  String get profileRateLimited;

  /// No description provided for @profileConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect. Check your connection and try again.'**
  String get profileConnectionFailed;

  /// No description provided for @profileInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unsupported profile response.'**
  String get profileInvalidResponse;

  /// No description provided for @profileOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get profileOnline;

  /// No description provided for @profileOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get profileOffline;

  /// No description provided for @profileSupporter.
  ///
  /// In en, this message translates to:
  /// **'osu!supporter'**
  String get profileSupporter;

  /// No description provided for @profileNoStatistics.
  ///
  /// In en, this message translates to:
  /// **'No statistics for this ruleset yet.'**
  String get profileNoStatistics;

  /// No description provided for @profileUnranked.
  ///
  /// In en, this message translates to:
  /// **'No global rank'**
  String get profileUnranked;

  /// No description provided for @profileGlobalRank.
  ///
  /// In en, this message translates to:
  /// **'Global rank: #{rank}'**
  String profileGlobalRank(int rank);

  /// No description provided for @profileCountryRank.
  ///
  /// In en, this message translates to:
  /// **'Country rank: #{rank}'**
  String profileCountryRank(int rank);

  /// No description provided for @profilePlayTime.
  ///
  /// In en, this message translates to:
  /// **'Time played: {hours} h'**
  String profilePlayTime(int hours);

  /// No description provided for @profileMaximumCombo.
  ///
  /// In en, this message translates to:
  /// **'Maximum combo: {combo}'**
  String profileMaximumCombo(int combo);

  /// No description provided for @languageChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the language.'**
  String get languageChangeFailed;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSelection;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @scoresTitle.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get scoresTitle;

  /// No description provided for @scoresBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get scoresBest;

  /// No description provided for @scoresRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get scoresRecent;

  /// No description provided for @scoresRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh scores'**
  String get scoresRefresh;

  /// No description provided for @scoresLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading scores…'**
  String get scoresLoading;

  /// No description provided for @scoresEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scores found for this player and ruleset.'**
  String get scoresEmpty;

  /// No description provided for @scoresLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get scoresLoadMore;

  /// No description provided for @scoresKeepingContent.
  ///
  /// In en, this message translates to:
  /// **'Previously loaded scores are still shown.'**
  String get scoresKeepingContent;

  /// No description provided for @scoresCancelled.
  ///
  /// In en, this message translates to:
  /// **'Loading was cancelled.'**
  String get scoresCancelled;

  /// No description provided for @scoresNotFound.
  ///
  /// In en, this message translates to:
  /// **'Scores could not be found.'**
  String get scoresNotFound;

  /// No description provided for @scoresAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'osu! denied access to scores.'**
  String get scoresAccessDenied;

  /// No description provided for @scoresInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unsupported score response.'**
  String get scoresInvalidResponse;

  /// No description provided for @scoresUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Scores are temporarily unavailable.'**
  String get scoresUnavailable;

  /// No description provided for @scoresNoMods.
  ///
  /// In en, this message translates to:
  /// **'No mods'**
  String get scoresNoMods;

  /// No description provided for @scoresNoPp.
  ///
  /// In en, this message translates to:
  /// **'PP unavailable'**
  String get scoresNoPp;

  /// No description provided for @scoresFailedPlay.
  ///
  /// In en, this message translates to:
  /// **'Failed play'**
  String get scoresFailedPlay;

  /// No description provided for @scoresBeatmap.
  ///
  /// In en, this message translates to:
  /// **'Beatmap #{id}'**
  String scoresBeatmap(int id);

  /// No description provided for @scoresGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade: {grade}'**
  String scoresGrade(String grade);

  /// No description provided for @scoresCombo.
  ///
  /// In en, this message translates to:
  /// **'Combo: {combo}'**
  String scoresCombo(int combo);

  /// No description provided for @scoresTotal.
  ///
  /// In en, this message translates to:
  /// **'Score: {total}'**
  String scoresTotal(int total);

  /// No description provided for @scoresMods.
  ///
  /// In en, this message translates to:
  /// **'Mods: {mods}'**
  String scoresMods(String mods);

  /// No description provided for @scoresPlayedAt.
  ///
  /// In en, this message translates to:
  /// **'Played: {date}'**
  String scoresPlayedAt(String date);

  /// No description provided for @beatmapsTitle.
  ///
  /// In en, this message translates to:
  /// **'Beatmaps'**
  String get beatmapsTitle;

  /// No description provided for @beatmapsMostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get beatmapsMostPlayed;

  /// No description provided for @beatmapsFavourite.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get beatmapsFavourite;

  /// No description provided for @beatmapsRanked.
  ///
  /// In en, this message translates to:
  /// **'Ranked'**
  String get beatmapsRanked;

  /// No description provided for @beatmapsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get beatmapsPending;

  /// No description provided for @beatmapsGraveyard.
  ///
  /// In en, this message translates to:
  /// **'Graveyard'**
  String get beatmapsGraveyard;

  /// No description provided for @beatmapsLoved.
  ///
  /// In en, this message translates to:
  /// **'Loved'**
  String get beatmapsLoved;

  /// No description provided for @beatmapsGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest difficulties'**
  String get beatmapsGuest;

  /// No description provided for @beatmapsNominated.
  ///
  /// In en, this message translates to:
  /// **'Nominated'**
  String get beatmapsNominated;

  /// No description provided for @beatmapsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh beatmaps'**
  String get beatmapsRefresh;

  /// No description provided for @beatmapsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No beatmaps in this category.'**
  String get beatmapsEmpty;

  /// No description provided for @beatmapsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more beatmaps'**
  String get beatmapsLoadMore;

  /// No description provided for @beatmapsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading beatmaps…'**
  String get beatmapsLoading;

  /// No description provided for @beatmapsKeepingContent.
  ///
  /// In en, this message translates to:
  /// **'Could not update. Previously loaded beatmaps are still shown.'**
  String get beatmapsKeepingContent;

  /// No description provided for @beatmapsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Loading was cancelled.'**
  String get beatmapsCancelled;

  /// No description provided for @beatmapsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This player\'s beatmaps could not be found.'**
  String get beatmapsNotFound;

  /// No description provided for @beatmapsAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Beatmaps are not accessible right now.'**
  String get beatmapsAccessDenied;

  /// No description provided for @beatmapsInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unexpected beatmap response.'**
  String get beatmapsInvalidResponse;

  /// No description provided for @beatmapsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not load beatmaps. Please try again.'**
  String get beatmapsUnavailable;

  /// No description provided for @beatmapsSetFallback.
  ///
  /// In en, this message translates to:
  /// **'Beatmapset #{id}'**
  String beatmapsSetFallback(int id);

  /// No description provided for @beatmapsMapFallback.
  ///
  /// In en, this message translates to:
  /// **'Beatmap #{id}'**
  String beatmapsMapFallback(int id);

  /// No description provided for @beatmapsPlayCount.
  ///
  /// In en, this message translates to:
  /// **'Plays: {count}'**
  String beatmapsPlayCount(int count);

  /// No description provided for @beatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Beatmap'**
  String get beatmapTitle;

  /// No description provided for @beatmapNotFound.
  ///
  /// In en, this message translates to:
  /// **'Beatmap not found.'**
  String get beatmapNotFound;

  /// No description provided for @beatmapAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'This beatmap or leaderboard is not accessible.'**
  String get beatmapAccessDenied;

  /// No description provided for @beatmapInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected beatmap response.'**
  String get beatmapInvalidResponse;

  /// No description provided for @beatmapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not load beatmap data.'**
  String get beatmapUnavailable;

  /// No description provided for @beatmapLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Top scores'**
  String get beatmapLeaderboard;

  /// No description provided for @beatmapRefreshLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Refresh scores'**
  String get beatmapRefreshLeaderboard;

  /// No description provided for @beatmapNoScores.
  ///
  /// In en, this message translates to:
  /// **'No scores available.'**
  String get beatmapNoScores;

  /// No description provided for @beatmapLeaderboardPlayer.
  ///
  /// In en, this message translates to:
  /// **'#{position} · {name}'**
  String beatmapLeaderboardPlayer(int position, String name);

  /// No description provided for @beatmapPlayerId.
  ///
  /// In en, this message translates to:
  /// **'Player #{id}'**
  String beatmapPlayerId(int id);

  /// No description provided for @beatmapCreator.
  ///
  /// In en, this message translates to:
  /// **'Mapped by {name}'**
  String beatmapCreator(String name);

  /// No description provided for @beatmapRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh beatmap'**
  String get beatmapRefresh;

  /// No description provided for @beatmapDifficulties.
  ///
  /// In en, this message translates to:
  /// **'Difficulties'**
  String get beatmapDifficulties;

  /// No description provided for @beatmapNoDifficulties.
  ///
  /// In en, this message translates to:
  /// **'No difficulties available.'**
  String get beatmapNoDifficulties;

  /// No description provided for @beatmapDifficultyInfo.
  ///
  /// In en, this message translates to:
  /// **'{mode} · {stars} ★ · {seconds} s'**
  String beatmapDifficultyInfo(String mode, double stars, int seconds);
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
