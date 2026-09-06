import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Title and navigation label for osu! news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsTitle;

  /// Button or tooltip to reload news.
  ///
  /// In en, this message translates to:
  /// **'Refresh news'**
  String get newsRefresh;

  /// Empty state when no news posts are available.
  ///
  /// In en, this message translates to:
  /// **'No news available.'**
  String get newsEmpty;

  /// Button to fetch the next page of news.
  ///
  /// In en, this message translates to:
  /// **'Load more news'**
  String get newsLoadMore;

  /// Progress message while fetching news.
  ///
  /// In en, this message translates to:
  /// **'Loading news…'**
  String get newsLoading;

  /// Notice that cached news remains visible after a failed refresh.
  ///
  /// In en, this message translates to:
  /// **'Previously loaded content is still shown.'**
  String get newsKeepingContent;

  /// Error when a requested article does not exist or is unavailable.
  ///
  /// In en, this message translates to:
  /// **'This news post is unavailable.'**
  String get newsNotFound;

  /// Error after cancelling a news request.
  ///
  /// In en, this message translates to:
  /// **'News loading was cancelled.'**
  String get newsCancelled;

  /// Error when access to news is denied.
  ///
  /// In en, this message translates to:
  /// **'Unable to access news.'**
  String get newsAccessDenied;

  /// Error for an unreadable news API response.
  ///
  /// In en, this message translates to:
  /// **'The news response could not be read.'**
  String get newsInvalidResponse;

  /// Temporary news loading failure.
  ///
  /// In en, this message translates to:
  /// **'News is temporarily unavailable.'**
  String get newsUnavailable;

  /// Error when an external article link cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this link.'**
  String get newsLinkFailed;

  /// Button to open the original article in a browser.
  ///
  /// In en, this message translates to:
  /// **'Open original'**
  String get newsOriginal;

  /// Explains limitations of the in-app text-only news reader.
  ///
  /// In en, this message translates to:
  /// **'Text reading mode. Images, media and original formatting are available on the osu! website.'**
  String get newsReaderNotice;

  /// Title for osu! Spotlight collections; preserve the recognizable product term.
  ///
  /// In en, this message translates to:
  /// **'Spotlights'**
  String get spotlightsTitle;

  /// Label for the Spotlight selector.
  ///
  /// In en, this message translates to:
  /// **'Choose a spotlight'**
  String get spotlightsChoose;

  /// Button to load the selected Spotlight ranking.
  ///
  /// In en, this message translates to:
  /// **'Show selected spotlight'**
  String get spotlightsShowRanking;

  /// Empty Spotlight catalog.
  ///
  /// In en, this message translates to:
  /// **'No spotlights available.'**
  String get spotlightsEmpty;

  /// Heading for beatmap sets in a Spotlight.
  ///
  /// In en, this message translates to:
  /// **'Beatmapsets'**
  String get spotlightsMaps;

  /// No maps for the selected Spotlight and game mode.
  ///
  /// In en, this message translates to:
  /// **'No beatmapsets for this spotlight and ruleset.'**
  String get spotlightsNoMaps;

  /// Explains that the Spotlight ranking shows at most 40 players, not the full ranking.
  ///
  /// In en, this message translates to:
  /// **'Spotlight ranking · up to 40 players'**
  String get spotlightsRankingLimit;

  /// Selected Spotlight or game mode is unavailable.
  ///
  /// In en, this message translates to:
  /// **'This spotlight or ruleset is unavailable.'**
  String get spotlightsNotFound;

  /// Application brand name. Do not translate Tracksu.
  ///
  /// In en, this message translates to:
  /// **'Tracksu'**
  String get appTitle;

  /// Title for unauthenticated browsing.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get guestModeTitle;

  /// Explains that guests can browse public data and sign-in is optional.
  ///
  /// In en, this message translates to:
  /// **'Browse public osu! data as a guest. Signing in will add account features.'**
  String get guestSignedOutDescription;

  /// Explains that public browsing does not require an account even when signed in.
  ///
  /// In en, this message translates to:
  /// **'You are signed in. Public browsing stays available without an account.'**
  String get guestSignedInDescription;

  /// Account menu action to sign in through osu!.
  ///
  /// In en, this message translates to:
  /// **'Sign in with osu!'**
  String get signInWithOsu;

  /// Account menu action to switch osu! accounts.
  ///
  /// In en, this message translates to:
  /// **'Sign in with another account'**
  String get signInWithAnotherAccount;

  /// Account menu action to end the app session.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Progress label during sign-out.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get signingOut;

  /// Sign-out failure with retry guidance.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign out. Try again.'**
  String get signOutFailed;

  /// Language selector option that follows device preferences.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// Language selector label for English.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// Language selector label for Russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russianLanguage;

  /// Authorization screen title.
  ///
  /// In en, this message translates to:
  /// **'Login to osu!'**
  String get loginToOsu;

  /// Progress label during authorization code exchange.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// Progress label while launching osu! in an external browser.
  ///
  /// In en, this message translates to:
  /// **'Opening osu!...'**
  String get openingOsu;

  /// Button to launch or retry browser authorization.
  ///
  /// In en, this message translates to:
  /// **'Continue with osu!'**
  String get continueWithOsu;

  /// Pending OAuth transaction has expired; ask the user to retry.
  ///
  /// In en, this message translates to:
  /// **'This authorization request has expired. Try again.'**
  String get authorizationExpired;

  /// The app could not receive the OAuth callback.
  ///
  /// In en, this message translates to:
  /// **'Unable to receive the authorization response.'**
  String get authorizationResponseUnavailable;

  /// OAuth state did not match the pending login transaction.
  ///
  /// In en, this message translates to:
  /// **'The authorization response did not match this login attempt.'**
  String get authorizationResponseMismatch;

  /// User cancelled or denied authorization.
  ///
  /// In en, this message translates to:
  /// **'Authorization was cancelled or refused.'**
  String get authorizationCancelled;

  /// OAuth callback has an invalid format.
  ///
  /// In en, this message translates to:
  /// **'The authorization response is invalid.'**
  String get authorizationResponseInvalid;

  /// Unable to create or store the pending authorization request.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare osu! authorization.'**
  String get authorizationPreparationFailed;

  /// Unable to launch the external authorization page.
  ///
  /// In en, this message translates to:
  /// **'Unable to open osu! authorization.'**
  String get authorizationLaunchFailed;

  /// Token exchange or session completion failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to finish authorization.'**
  String get authorizationCompletionFailed;

  /// Returned from the browser without completing sign-in.
  ///
  /// In en, this message translates to:
  /// **'Authorization was not completed. Try again.'**
  String get authorizationIncomplete;

  /// Account menu action to load the signed-in player's profile.
  ///
  /// In en, this message translates to:
  /// **'View my profile'**
  String get viewMyProfile;

  /// Player profile screen title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Search field hint accepting a username or numeric player ID.
  ///
  /// In en, this message translates to:
  /// **'Username or ID'**
  String get profileSearchHint;

  /// Validation message for an invalid player query.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid username or positive ID.'**
  String get profileSearchInvalid;

  /// Official game mode name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'osu!'**
  String get rulesetOsu;

  /// Official game mode name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'taiko'**
  String get rulesetTaiko;

  /// Official catch game mode name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'catch'**
  String get rulesetFruits;

  /// Official game mode name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'mania'**
  String get rulesetMania;

  /// Progress message while fetching a player profile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get profileLoading;

  /// Generic player profile loading error.
  ///
  /// In en, this message translates to:
  /// **'Profile is unavailable. Try again.'**
  String get profileUnavailable;

  /// Button to repeat a failed operation.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Player's numeric osu! ID; do not add digit grouping.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String profileId(int id);

  /// Player or score performance points (PP), formatted with two decimal places.
  ///
  /// In en, this message translates to:
  /// **'Performance: {pp}'**
  String profilePerformance(double pp);

  /// Player's country; the parameter is supplied by the API.
  ///
  /// In en, this message translates to:
  /// **'Country: {country}'**
  String profileCountry(String country);

  /// Accuracy as a percentage on a 0–100 scale, not a 0–1 fraction.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {accuracy}%'**
  String profileAccuracy(double accuracy);

  /// Total number of plays for the selected game mode.
  ///
  /// In en, this message translates to:
  /// **'Play count: {count}'**
  String profilePlayCount(int count);

  /// Guest-first introduction to public player search.
  ///
  /// In en, this message translates to:
  /// **'Find an osu! player to view their profile and statistics. No sign-in required.'**
  String get profileSearchIntroduction;

  /// Prefix a numeric username with the literal @ character to distinguish it from an ID.
  ///
  /// In en, this message translates to:
  /// **'Use @ before a numeric username.'**
  String get profileSearchHelp;

  /// Button to submit player search.
  ///
  /// In en, this message translates to:
  /// **'Find player'**
  String get profileSearch;

  /// Progress label for refreshing an already visible profile.
  ///
  /// In en, this message translates to:
  /// **'Updating profile'**
  String get profileRefreshing;

  /// Button to refresh the player profile.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get profileRefresh;

  /// Refresh failed but previously loaded profile data remains visible.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Previously loaded data is shown.'**
  String get profileShowingPreviousData;

  /// No matching player; suggest checking the query.
  ///
  /// In en, this message translates to:
  /// **'Player not found. Check the name or ID.'**
  String get profileNotFound;

  /// Profile access denied, with sign-in guidance for the user's own profile.
  ///
  /// In en, this message translates to:
  /// **'Access denied by osu!. For your own profile, try signing in again.'**
  String get profileAccessDenied;

  /// API rate limit error; ask the user to wait.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait before trying again.'**
  String get profileRateLimited;

  /// Network connection failure.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect. Check your connection and try again.'**
  String get profileConnectionFailed;

  /// Profile response does not match the supported API contract.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unsupported profile response.'**
  String get profileInvalidResponse;

  /// Player is currently online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get profileOnline;

  /// Player is currently offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get profileOffline;

  /// Official osu!supporter label; do not translate.
  ///
  /// In en, this message translates to:
  /// **'osu!supporter'**
  String get profileSupporter;

  /// No player statistics for the selected game mode.
  ///
  /// In en, this message translates to:
  /// **'No statistics for this ruleset yet.'**
  String get profileNoStatistics;

  /// Player has no global ranking.
  ///
  /// In en, this message translates to:
  /// **'No global rank'**
  String get profileUnranked;

  /// Player's position in the global ranking.
  ///
  /// In en, this message translates to:
  /// **'Global rank: #{rank}'**
  String profileGlobalRank(int rank);

  /// Player's position within their country.
  ///
  /// In en, this message translates to:
  /// **'Country rank: #{rank}'**
  String profileCountryRank(int rank);

  /// Total hours played; use a short unit label.
  ///
  /// In en, this message translates to:
  /// **'Time played: {hours} h'**
  String profilePlayTime(int hours);

  /// Player's highest combo count.
  ///
  /// In en, this message translates to:
  /// **'Maximum combo: {combo}'**
  String profileMaximumCombo(int combo);

  /// Language preference could not be saved.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the language.'**
  String get languageChangeFailed;

  /// Tooltip for the app language selector.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSelection;

  /// Tooltip for the account menu.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Heading for player scores.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get scoresTitle;

  /// Tab for a player's best scores.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get scoresBest;

  /// Tab for a player's recent scores.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get scoresRecent;

  /// Button or tooltip to refresh scores.
  ///
  /// In en, this message translates to:
  /// **'Refresh scores'**
  String get scoresRefresh;

  /// Progress message while fetching scores.
  ///
  /// In en, this message translates to:
  /// **'Loading scores…'**
  String get scoresLoading;

  /// No scores for this player and game mode.
  ///
  /// In en, this message translates to:
  /// **'No scores found for this player and ruleset.'**
  String get scoresEmpty;

  /// Button to fetch the next page of scores.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get scoresLoadMore;

  /// Old scores remain visible after a failed refresh.
  ///
  /// In en, this message translates to:
  /// **'Previously loaded scores are still shown.'**
  String get scoresKeepingContent;

  /// Score loading request was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Loading was cancelled.'**
  String get scoresCancelled;

  /// Requested scores were not found.
  ///
  /// In en, this message translates to:
  /// **'Scores could not be found.'**
  String get scoresNotFound;

  /// Score API access was denied.
  ///
  /// In en, this message translates to:
  /// **'osu! denied access to scores.'**
  String get scoresAccessDenied;

  /// Score response does not match the supported API contract.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unsupported score response.'**
  String get scoresInvalidResponse;

  /// Temporary score loading failure.
  ///
  /// In en, this message translates to:
  /// **'Scores are temporarily unavailable.'**
  String get scoresUnavailable;

  /// Score was played without gameplay modifiers.
  ///
  /// In en, this message translates to:
  /// **'No mods'**
  String get scoresNoMods;

  /// Performance points are unavailable, not zero.
  ///
  /// In en, this message translates to:
  /// **'PP unavailable'**
  String get scoresNoPp;

  /// The player did not pass the beatmap.
  ///
  /// In en, this message translates to:
  /// **'Failed play'**
  String get scoresFailedPlay;

  /// Fallback title for a beatmap whose name is missing; ID is not grouped.
  ///
  /// In en, this message translates to:
  /// **'Beatmap #{id}'**
  String scoresBeatmap(int id);

  /// Score grade such as SS, S, A or B; do not translate the parameter.
  ///
  /// In en, this message translates to:
  /// **'Grade: {grade}'**
  String scoresGrade(String grade);

  /// Maximum combo achieved in this score.
  ///
  /// In en, this message translates to:
  /// **'Combo: {combo}'**
  String scoresCombo(int combo);

  /// Numeric total score.
  ///
  /// In en, this message translates to:
  /// **'Score: {total}'**
  String scoresTotal(int total);

  /// Gameplay modifier acronyms, already joined for display.
  ///
  /// In en, this message translates to:
  /// **'Mods: {mods}'**
  String scoresMods(String mods);

  /// When the score was played; parameter already contains a locale-formatted local date and time.
  ///
  /// In en, this message translates to:
  /// **'Played: {date}'**
  String scoresPlayedAt(String date);

  /// Heading for a player's beatmaps.
  ///
  /// In en, this message translates to:
  /// **'Beatmaps'**
  String get beatmapsTitle;

  /// Category of maps most played by the player.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get beatmapsMostPlayed;

  /// Category of maps favourited by the player.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get beatmapsFavourite;

  /// Category with the official Ranked status.
  ///
  /// In en, this message translates to:
  /// **'Ranked'**
  String get beatmapsRanked;

  /// Category with the official Pending status.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get beatmapsPending;

  /// Category with the official Graveyard status.
  ///
  /// In en, this message translates to:
  /// **'Graveyard'**
  String get beatmapsGraveyard;

  /// Category with the official Loved status.
  ///
  /// In en, this message translates to:
  /// **'Loved'**
  String get beatmapsLoved;

  /// Category of guest difficulties authored for other mappers; not guest browsing.
  ///
  /// In en, this message translates to:
  /// **'Guest difficulties'**
  String get beatmapsGuest;

  /// Category of beatmaps nominated by the player.
  ///
  /// In en, this message translates to:
  /// **'Nominated'**
  String get beatmapsNominated;

  /// Button or tooltip to refresh the beatmap list.
  ///
  /// In en, this message translates to:
  /// **'Refresh beatmaps'**
  String get beatmapsRefresh;

  /// No maps in the selected category.
  ///
  /// In en, this message translates to:
  /// **'No beatmaps in this category.'**
  String get beatmapsEmpty;

  /// Button to fetch another page of maps.
  ///
  /// In en, this message translates to:
  /// **'Load more beatmaps'**
  String get beatmapsLoadMore;

  /// Progress message while loading maps.
  ///
  /// In en, this message translates to:
  /// **'Loading beatmaps…'**
  String get beatmapsLoading;

  /// Map refresh failed but old content remains visible.
  ///
  /// In en, this message translates to:
  /// **'Could not update. Previously loaded beatmaps are still shown.'**
  String get beatmapsKeepingContent;

  /// Map loading was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Loading was cancelled.'**
  String get beatmapsCancelled;

  /// The player's maps could not be found.
  ///
  /// In en, this message translates to:
  /// **'This player\'s beatmaps could not be found.'**
  String get beatmapsNotFound;

  /// Access to the map list is currently denied.
  ///
  /// In en, this message translates to:
  /// **'Beatmaps are not accessible right now.'**
  String get beatmapsAccessDenied;

  /// Map list response does not match the supported contract.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unexpected beatmap response.'**
  String get beatmapsInvalidResponse;

  /// Generic map list loading failure.
  ///
  /// In en, this message translates to:
  /// **'Could not load beatmaps. Please try again.'**
  String get beatmapsUnavailable;

  /// Fallback beatmap set title; numeric identifier is not grouped.
  ///
  /// In en, this message translates to:
  /// **'Beatmapset #{id}'**
  String beatmapsSetFallback(int id);

  /// Fallback beatmap title; numeric identifier is not grouped.
  ///
  /// In en, this message translates to:
  /// **'Beatmap #{id}'**
  String beatmapsMapFallback(int id);

  /// Number of plays of a beatmap.
  ///
  /// In en, this message translates to:
  /// **'Plays: {count}'**
  String beatmapsPlayCount(int count);

  /// Single beatmap details screen title.
  ///
  /// In en, this message translates to:
  /// **'Beatmap'**
  String get beatmapTitle;

  /// Requested beatmap does not exist.
  ///
  /// In en, this message translates to:
  /// **'Beatmap not found.'**
  String get beatmapNotFound;

  /// Access to a beatmap or its leaderboard is denied.
  ///
  /// In en, this message translates to:
  /// **'This beatmap or leaderboard is not accessible.'**
  String get beatmapAccessDenied;

  /// Beatmap detail response does not match the supported contract.
  ///
  /// In en, this message translates to:
  /// **'Unexpected beatmap response.'**
  String get beatmapInvalidResponse;

  /// Beatmap details could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load beatmap data.'**
  String get beatmapUnavailable;

  /// Heading for the public top-score leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Top scores'**
  String get beatmapLeaderboard;

  /// Button to reload the beatmap's leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Refresh scores'**
  String get beatmapRefreshLeaderboard;

  /// Empty beatmap leaderboard.
  ///
  /// In en, this message translates to:
  /// **'No scores available.'**
  String get beatmapNoScores;

  /// Leaderboard position followed by the player's display name; preserve the name.
  ///
  /// In en, this message translates to:
  /// **'#{position} · {name}'**
  String beatmapLeaderboardPlayer(int position, String name);

  /// Fallback player label with numeric ID; do not group the identifier.
  ///
  /// In en, this message translates to:
  /// **'Player #{id}'**
  String beatmapPlayerId(int id);

  /// Credits the beatmap creator; preserve the name.
  ///
  /// In en, this message translates to:
  /// **'Mapped by {name}'**
  String beatmapCreator(String name);

  /// Button to reload beatmap details.
  ///
  /// In en, this message translates to:
  /// **'Refresh beatmap'**
  String get beatmapRefresh;

  /// Heading for selectable difficulties in a beatmap set.
  ///
  /// In en, this message translates to:
  /// **'Difficulties'**
  String get beatmapDifficulties;

  /// No available difficulties in this set.
  ///
  /// In en, this message translates to:
  /// **'No difficulties available.'**
  String get beatmapNoDifficulties;

  /// Compact game mode, star difficulty and length in seconds; stars is a difficulty rating.
  ///
  /// In en, this message translates to:
  /// **'{mode} · {stars} ★ · {seconds} s'**
  String beatmapDifficultyInfo(String mode, double stars, int seconds);

  /// Player rankings screen title.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankingsTitle;

  /// Selector for total ranked score rather than PP ranking.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get rankingsScore;

  /// Button or tooltip to refresh player rankings.
  ///
  /// In en, this message translates to:
  /// **'Refresh rankings'**
  String get rankingsRefresh;

  /// No players match the ranking filters.
  ///
  /// In en, this message translates to:
  /// **'No players found.'**
  String get rankingsEmpty;

  /// Button to fetch another page of players.
  ///
  /// In en, this message translates to:
  /// **'Load more players'**
  String get rankingsLoadMore;

  /// Progress label while loading rankings.
  ///
  /// In en, this message translates to:
  /// **'Loading rankings…'**
  String get rankingsLoading;

  /// Refresh failed but previous ranking data remains visible.
  ///
  /// In en, this message translates to:
  /// **'Could not update. Previously loaded rankings are shown.'**
  String get rankingsKeepingContent;

  /// Ranking request was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Loading cancelled.'**
  String get rankingsCancelled;

  /// Requested ranking does not exist.
  ///
  /// In en, this message translates to:
  /// **'Ranking not found.'**
  String get rankingsNotFound;

  /// Ranking access was denied.
  ///
  /// In en, this message translates to:
  /// **'Ranking is not accessible.'**
  String get rankingsAccessDenied;

  /// Ranking response does not match the supported contract.
  ///
  /// In en, this message translates to:
  /// **'Unexpected ranking response.'**
  String get rankingsInvalidResponse;

  /// Ranking could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load rankings.'**
  String get rankingsUnavailable;

  /// Player's total ranked score, a number rather than a position.
  ///
  /// In en, this message translates to:
  /// **'Ranked score: {score}'**
  String rankingsRankedScore(int score);

  /// Label for a two-letter country code filter.
  ///
  /// In en, this message translates to:
  /// **'Country code'**
  String get rankingsCountry;

  /// Country filter help; JP and US are literal examples of codes, empty means all countries.
  ///
  /// In en, this message translates to:
  /// **'Two letters, e.g. JP or US; empty means worldwide.'**
  String get rankingsCountryHint;

  /// Validation error for a country code that is not two letters.
  ///
  /// In en, this message translates to:
  /// **'Enter a two-letter country code.'**
  String get rankingsCountryInvalid;

  /// Button to apply the country filter.
  ///
  /// In en, this message translates to:
  /// **'Apply country'**
  String get rankingsApply;

  /// Label for the all-countries ranking.
  ///
  /// In en, this message translates to:
  /// **'Worldwide'**
  String get rankingsWorldwide;

  /// mania filter without restriction to a key count.
  ///
  /// In en, this message translates to:
  /// **'All key counts'**
  String get rankingsAllKeys;

  /// Language selector label for German.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get germanLanguage;

  /// Language selector label for French.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get frenchLanguage;

  /// Language selector label for Spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanishLanguage;

  /// Language selector label for Japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japaneseLanguage;

  /// Language selector label for Simplified Chinese; Traditional Chinese is not offered.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get chineseLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
