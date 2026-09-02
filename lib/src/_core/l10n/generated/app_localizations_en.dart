// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tracksu';

  @override
  String get guestModeTitle => 'Guest mode';

  @override
  String get guestSignedOutDescription =>
      'Browse public osu! data as a guest. Signing in will add account features.';

  @override
  String get guestSignedInDescription =>
      'You are signed in. Public browsing stays available without an account.';

  @override
  String get signInWithOsu => 'Sign in with osu!';

  @override
  String get signInWithAnotherAccount => 'Sign in with another account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signingOut => 'Signing out...';

  @override
  String get signOutFailed => 'Unable to sign out. Try again.';

  @override
  String get systemLanguage => 'System language';

  @override
  String get englishLanguage => 'English';

  @override
  String get russianLanguage => 'Russian';

  @override
  String get loginToOsu => 'Login to osu!';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get openingOsu => 'Opening osu!...';

  @override
  String get continueWithOsu => 'Continue with osu!';

  @override
  String get authorizationExpired =>
      'This authorization request has expired. Try again.';

  @override
  String get authorizationResponseUnavailable =>
      'Unable to receive the authorization response.';

  @override
  String get authorizationResponseMismatch =>
      'The authorization response did not match this login attempt.';

  @override
  String get authorizationCancelled =>
      'Authorization was cancelled or refused.';

  @override
  String get authorizationResponseInvalid =>
      'The authorization response is invalid.';

  @override
  String get authorizationPreparationFailed =>
      'Unable to prepare osu! authorization.';

  @override
  String get authorizationLaunchFailed => 'Unable to open osu! authorization.';

  @override
  String get authorizationCompletionFailed => 'Unable to finish authorization.';

  @override
  String get authorizationIncomplete =>
      'Authorization was not completed. Try again.';

  @override
  String get viewMyProfile => 'View my profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSearchHint => 'Username or ID';

  @override
  String get profileSearchInvalid => 'Enter a valid username or positive ID.';

  @override
  String get rulesetOsu => 'osu!';

  @override
  String get rulesetTaiko => 'taiko';

  @override
  String get rulesetFruits => 'catch';

  @override
  String get rulesetMania => 'mania';

  @override
  String get profileLoading => 'Loading profile...';

  @override
  String get profileUnavailable => 'Profile is unavailable. Try again.';

  @override
  String get retry => 'Retry';

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

    return 'Performance: $ppString';
  }

  @override
  String profileCountry(String country) {
    return 'Country: $country';
  }

  @override
  String profileAccuracy(double accuracy) {
    final intl.NumberFormat accuracyNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 2,
        );
    final String accuracyString = accuracyNumberFormat.format(accuracy);

    return 'Accuracy: $accuracyString%';
  }

  @override
  String profilePlayCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Play count: $countString';
  }

  @override
  String get profileSearchIntroduction =>
      'Find an osu! player to view their profile and statistics. No sign-in required.';

  @override
  String get profileSearchHelp => 'Use @ before a numeric username.';

  @override
  String get profileSearch => 'Find player';

  @override
  String get profileRefreshing => 'Updating profile';

  @override
  String get profileRefresh => 'Refresh';

  @override
  String get profileShowingPreviousData =>
      'Update failed. Previously loaded data is shown.';

  @override
  String get profileNotFound => 'Player not found. Check the name or ID.';

  @override
  String get profileAccessDenied =>
      'Access denied by osu!. For your own profile, try signing in again.';

  @override
  String get profileRateLimited =>
      'Too many requests. Wait before trying again.';

  @override
  String get profileConnectionFailed =>
      'Cannot connect. Check your connection and try again.';

  @override
  String get profileInvalidResponse =>
      'The server returned an unsupported profile response.';

  @override
  String get profileOnline => 'Online';

  @override
  String get profileOffline => 'Offline';

  @override
  String get profileSupporter => 'osu!supporter';

  @override
  String get profileNoStatistics => 'No statistics for this ruleset yet.';

  @override
  String get profileUnranked => 'No global rank';

  @override
  String profileGlobalRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Global rank: #$rankString';
  }

  @override
  String profileCountryRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Country rank: #$rankString';
  }

  @override
  String profilePlayTime(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return 'Time played: $hoursString h';
  }

  @override
  String profileMaximumCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'Maximum combo: $comboString';
  }

  @override
  String get languageChangeFailed => 'Unable to save the language.';

  @override
  String get languageSelection => 'Language';

  @override
  String get account => 'Account';

  @override
  String get scoresTitle => 'Scores';

  @override
  String get scoresBest => 'Best';

  @override
  String get scoresRecent => 'Recent';

  @override
  String get scoresRefresh => 'Refresh scores';

  @override
  String get scoresLoading => 'Loading scores…';

  @override
  String get scoresEmpty => 'No scores found for this player and ruleset.';

  @override
  String get scoresLoadMore => 'Load more';

  @override
  String get scoresKeepingContent =>
      'Previously loaded scores are still shown.';

  @override
  String get scoresCancelled => 'Loading was cancelled.';

  @override
  String get scoresNotFound => 'Scores could not be found.';

  @override
  String get scoresAccessDenied => 'osu! denied access to scores.';

  @override
  String get scoresInvalidResponse =>
      'The server returned an unsupported score response.';

  @override
  String get scoresUnavailable => 'Scores are temporarily unavailable.';

  @override
  String get scoresNoMods => 'No mods';

  @override
  String get scoresNoPp => 'PP unavailable';

  @override
  String get scoresFailedPlay => 'Failed play';

  @override
  String scoresBeatmap(int id) {
    return 'Beatmap #$id';
  }

  @override
  String scoresGrade(String grade) {
    return 'Grade: $grade';
  }

  @override
  String scoresCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'Combo: $comboString';
  }

  @override
  String scoresTotal(int total) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Score: $totalString';
  }

  @override
  String scoresMods(String mods) {
    return 'Mods: $mods';
  }

  @override
  String scoresPlayedAt(String date) {
    return 'Played: $date';
  }

  @override
  String get beatmapsTitle => 'Beatmaps';

  @override
  String get beatmapsMostPlayed => 'Most played';

  @override
  String get beatmapsFavourite => 'Favourites';

  @override
  String get beatmapsRanked => 'Ranked';

  @override
  String get beatmapsPending => 'Pending';

  @override
  String get beatmapsGraveyard => 'Graveyard';

  @override
  String get beatmapsLoved => 'Loved';

  @override
  String get beatmapsGuest => 'Guest difficulties';

  @override
  String get beatmapsNominated => 'Nominated';

  @override
  String get beatmapsRefresh => 'Refresh beatmaps';

  @override
  String get beatmapsEmpty => 'No beatmaps in this category.';

  @override
  String get beatmapsLoadMore => 'Load more beatmaps';

  @override
  String get beatmapsLoading => 'Loading beatmaps…';

  @override
  String get beatmapsKeepingContent =>
      'Could not update. Previously loaded beatmaps are still shown.';

  @override
  String get beatmapsCancelled => 'Loading was cancelled.';

  @override
  String get beatmapsNotFound => 'This player\'s beatmaps could not be found.';

  @override
  String get beatmapsAccessDenied => 'Beatmaps are not accessible right now.';

  @override
  String get beatmapsInvalidResponse =>
      'The server returned an unexpected beatmap response.';

  @override
  String get beatmapsUnavailable =>
      'Could not load beatmaps. Please try again.';

  @override
  String beatmapsSetFallback(int id) {
    return 'Beatmapset #$id';
  }

  @override
  String beatmapsMapFallback(int id) {
    return 'Beatmap #$id';
  }

  @override
  String beatmapsPlayCount(int count) {
    return 'Plays: $count';
  }

  @override
  String get beatmapTitle => 'Beatmap';

  @override
  String get beatmapNotFound => 'Beatmap not found.';

  @override
  String get beatmapAccessDenied =>
      'This beatmap or leaderboard is not accessible.';

  @override
  String get beatmapInvalidResponse => 'Unexpected beatmap response.';

  @override
  String get beatmapUnavailable => 'Could not load beatmap data.';

  @override
  String get beatmapLeaderboard => 'Top scores';

  @override
  String get beatmapRefreshLeaderboard => 'Refresh scores';

  @override
  String get beatmapNoScores => 'No scores available.';

  @override
  String beatmapLeaderboardPlayer(int position, String name) {
    return '#$position · $name';
  }

  @override
  String beatmapPlayerId(int id) {
    return 'Player #$id';
  }

  @override
  String beatmapCreator(String name) {
    return 'Mapped by $name';
  }

  @override
  String get beatmapRefresh => 'Refresh beatmap';

  @override
  String get beatmapDifficulties => 'Difficulties';

  @override
  String get beatmapNoDifficulties => 'No difficulties available.';

  @override
  String beatmapDifficultyInfo(String mode, double stars, int seconds) {
    return '$mode · $stars ★ · $seconds s';
  }
}
