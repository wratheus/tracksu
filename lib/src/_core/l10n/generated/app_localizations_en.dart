// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutTitle => 'About Tracksu';

  @override
  String get aboutDescription =>
      'Explore osu! players, scores, beatmaps and news.';

  @override
  String get aboutUnofficial =>
      'An independent, unofficial client. Not affiliated with or endorsed by ppy Pty Ltd.';

  @override
  String get aboutBuild => 'Installed version';

  @override
  String get aboutBuildUnavailable =>
      'Could not read the installed app version.';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version · Build $build';
  }

  @override
  String get aboutProject => 'Project on GitHub';

  @override
  String get aboutOsu => 'osu! website';

  @override
  String get aboutLicensesDescription =>
      'Open-source dependencies and Exo 2 font';

  @override
  String get aboutLinkFailed => 'Could not open the link.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'Follow system';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSaveFailed => 'Unable to save the theme.';

  @override
  String get spotlightsParticipants => 'Participants';

  @override
  String get spotlightsSearch => 'Name, year or ID';

  @override
  String get spotlightsNoMatch => 'No matching spotlights.';

  @override
  String spotlightsPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String spotlightsStarts(String date) {
    return 'From $date';
  }

  @override
  String spotlightsEnds(String date) {
    return 'Until $date';
  }

  @override
  String spotlightsDifficultyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# difficulties in set',
      one: '# difficulty in set',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSignOutConfirm =>
      'Sign out on this device? Your public osu! profile will remain available.';

  @override
  String get medalsLoading => 'Loading medals…';

  @override
  String get medalsFailed =>
      'Could not load medal details from osu!. Please try again.';

  @override
  String get medalsEmpty => 'No medals earned yet.';

  @override
  String get scoreMiss => 'MISS';

  @override
  String get scoreFruit => 'Fruit';

  @override
  String get scoreDroplet => 'Droplets';

  @override
  String get scoreTinyDroplet => 'Tiny droplets';

  @override
  String get scoreTinyMiss => 'Missed tiny droplets';

  @override
  String get scoreJudgementPercentNotice =>
      'Percentages are shares of the recorded judgments shown here, not map completion or maximum combo. Slider ticks and technical legacy counters are excluded.';

  @override
  String get profilePreviousNames => 'Previously known as';

  @override
  String get profileGroups => 'Groups';

  @override
  String profileTeamTag(String tag) {
    return 'Team · $tag';
  }

  @override
  String get profileMedals => 'Medals';

  @override
  String get profileMedalsView => 'View earned medals';

  @override
  String profileMedalId(int id) {
    return 'Medal #$id';
  }

  @override
  String get profileRankedPlay => 'Ranked play';

  @override
  String get profileRankedPlayEmpty =>
      'No ranked play statistics for this mode.';

  @override
  String profileRankedPool(int id) {
    return 'Pool #$id';
  }

  @override
  String get profileProvisionalRating => 'Provisional rating';

  @override
  String get profileRating => 'Rating';

  @override
  String get profileFirstPlaces => 'First places';

  @override
  String get profileRankedPoints => 'Match points';

  @override
  String get profileDailyChallenge => 'Daily challenge';

  @override
  String get profileDailyPlays => 'Challenges played';

  @override
  String get profileDailyCurrent => 'Current daily streak';

  @override
  String get profileDailyBest => 'Best daily streak';

  @override
  String get profileWeeklyCurrent => 'Current weekly streak';

  @override
  String get profileWeeklyBest => 'Best weekly streak';

  @override
  String get profileTop10 => 'Top 10% finishes';

  @override
  String get profileTop50 => 'Top 50% finishes';

  @override
  String profileDailyUpdated(String date) {
    return 'Last participation: $date';
  }

  @override
  String profileWeeklyUpdated(String date) {
    return 'Last weekly streak: $date';
  }

  @override
  String get shareSystem => 'Other apps…';

  @override
  String get shareCopy => 'Copy link';

  @override
  String get shareCopied => 'Link copied';

  @override
  String get shareDestinationNotice =>
      'Choose a recipient in the app or browser that opens. Nothing is posted automatically. The link leads to the public osu! page; previews depend on the receiving app.';

  @override
  String get shareAction => 'Share';

  @override
  String get shareBeatmapAction => 'Share beatmap';

  @override
  String get shareFailed => 'Could not open the share sheet. Please try again.';

  @override
  String get contentMediaSettings => 'External images';

  @override
  String get contentMediaConsent =>
      'Images embedded in profiles, beatmap descriptions and news are downloaded from external servers. Those servers receive your IP address and can log requests. This choice applies to all such images on this device; you can change it in the account menu. Avatars and map covers from osu! load separately.';

  @override
  String get contentMediaAllow => 'Allow images';

  @override
  String get contentMediaDecline => 'Not now';

  @override
  String get contentMediaDisabled =>
      'External images are off. You can enable them in the account menu.';

  @override
  String get contentMediaSaveFailed =>
      'Could not save this preference. It may revert after restarting the app.';

  @override
  String get contentImageUnsupported =>
      'This image address is not supported. Open the original page to view it.';

  @override
  String get profilePlayHistoryTitle => 'Plays by month';

  @override
  String rankingsPosition(int position) {
    final intl.NumberFormat positionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String positionString = positionNumberFormat.format(position);

    return 'Position #$positionString';
  }

  @override
  String get rankingsPositionNotice =>
      'Positions belong to this filtered table, not global PP ranks. Live rankings can move between page loads; refresh to update.';

  @override
  String get rankingsCountrySelection => 'Country or region';

  @override
  String get rankingsCountrySearch => 'Country name or code';

  @override
  String get rankingsCountryCatalogHint =>
      'Search English names or two-letter codes. Some entries show only a code. Ranking availability depends on osu!.';

  @override
  String get rankingsCountryCatalogFailed => 'Could not load the country list.';

  @override
  String get rankingsCountryNoMatch => 'No matching countries.';

  @override
  String get rankingsEnd => 'End of available rankings.';

  @override
  String get scoreHitsTitle => 'Hit results';

  @override
  String get scoreHitsExplanation =>
      'API hit-result names are shown as provided. Missing counts are not zero; maximum counts describe a perfect play, not a per-row target.';

  @override
  String get scoreHitsAchieved => 'Achieved';

  @override
  String get scoreHitsMaximum => 'Perfect-play count';

  @override
  String get scoreModSettingsTitle => 'Mod settings';

  @override
  String get scoreModSettingsExplanation =>
      'API setting names are retained. Only explicitly supplied settings are shown; no default values are assumed.';

  @override
  String get scoreNoModSettings => 'No explicit settings supplied.';

  @override
  String get scoreDetailsUnavailable => 'Not available';

  @override
  String get scoreSettingEnabled => 'Enabled';

  @override
  String get scoreSettingDisabled => 'Disabled';

  @override
  String get beatmapDescription => 'Map description';

  @override
  String get contentPageUnavailable =>
      'This content cannot be displayed here. You can open the original.';

  @override
  String get scoreDetailsTitle => 'Result details';

  @override
  String get scoreOpenBeatmap => 'Open beatmap';

  @override
  String get scoreStandardisedTotal => 'Standardised score';

  @override
  String get mapSetPlays => 'Set plays';

  @override
  String get mapFavourites => 'Favourites';

  @override
  String get mapBpm => 'BPM';

  @override
  String get profileReplayHistoryTitle => 'Replay views by month';

  @override
  String get profileReplayHistoryExplanation =>
      'Months without observations are omitted; missing data is not zero.';

  @override
  String get profileAbout => 'About me';

  @override
  String get contentPageNotice =>
      'External images follow your saved preference. Embeds open only on the original page. If rendered content is missing, BBCode is shown as plain text.';

  @override
  String get contentLinkFailed => 'Could not open the link.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileOverview => 'Overview';

  @override
  String get profilePpLabel => 'Performance (PP)';

  @override
  String get profileGlobalRankLabel => 'Global rank';

  @override
  String get profileCountryRankLabel => 'Country rank';

  @override
  String get profileStatisticsTitle => 'Statistics';

  @override
  String get profileAccuracyLabel => 'Accuracy';

  @override
  String get profilePlayCountLabel => 'Play count';

  @override
  String get profilePlayTimeLabel => 'Play time';

  @override
  String get profileComboLabel => 'Maximum combo';

  @override
  String get profileValueUnavailable => 'Unavailable';

  @override
  String get profileGradesTitle => 'Score grades';

  @override
  String get profileRankedScoreLabel => 'Ranked score';

  @override
  String get profileTotalScoreLabel => 'Total score';

  @override
  String get profileTotalHitsLabel => 'Total hits';

  @override
  String get profileReplaysLabel => 'Replays watched by others';

  @override
  String get profileHistoryTitle => 'Rank history';

  @override
  String get profileHistoryEmpty => 'No rank history for this mode.';

  @override
  String get profileHistoryExplanation =>
      'API observations in order, not calendar dates. Gaps mean unavailable ranks.';

  @override
  String get profileSwitchingMode =>
      'Loading the selected mode. Previous mode data is still shown.';

  @override
  String get profileUpdateFailed =>
      'Update failed. Previous data and mode are kept.';

  @override
  String profileDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString h $minutesString min';
  }

  @override
  String profileLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'Level $levelString';
  }

  @override
  String profileLevelProgress(int progress) {
    final intl.NumberFormat progressNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String progressString = progressNumberFormat.format(progress);

    return 'Level progress: $progressString%';
  }

  @override
  String profileHistorySample(int index) {
    final intl.NumberFormat indexNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);

    return 'Observation $indexString';
  }

  @override
  String get navigationSearch => 'Search';

  @override
  String get navigationUnavailable => 'This page is unavailable.';

  @override
  String get searchClear => 'Clear search';

  @override
  String get contentImage => 'Image';

  @override
  String get contentImageLoading => 'Loading image…';

  @override
  String get contentImageFailed =>
      'Could not load the image. It may be unavailable or exceed supported size or format.';

  @override
  String get contentImageOpen => 'Enlarge image';

  @override
  String get contentDisclosure => 'Show hidden content';

  @override
  String get contentUnsupported =>
      'This embedded content is available on the original page.';

  @override
  String get contentOriginal => 'Open original';

  @override
  String get contentUnavailable =>
      'Content is unavailable in the reader. Open the original page.';

  @override
  String get uiCatalogMedia => 'Images and badges';

  @override
  String get uiCatalogCards => 'Player and content cards';

  @override
  String get uiCatalogCharts => 'Charts';

  @override
  String get uiCatalogStates => 'Content states';

  @override
  String get uiCatalogSampleNotice =>
      'Preview data only. These are not live player statistics. Existing Tracksu artwork is used to demonstrate image layout.';

  @override
  String get uiCatalogHistory => 'Rank history';

  @override
  String get uiCatalogActivity => 'Play activity';

  @override
  String get uiCatalogSinglePoint => 'One observation';

  @override
  String get uiCatalogFlatSeries => 'Unchanged values';

  @override
  String get uiCatalogOffline => 'No connection';

  @override
  String get uiCatalogNoData => 'No data yet';

  @override
  String get uiCatalogChartHint =>
      'Tap or drag to inspect a sample, or use the slider. Smaller rank numbers appear higher.';

  @override
  String get uiMetricPerformance => 'Performance points';

  @override
  String get uiMetricAccuracy => 'Accuracy';

  @override
  String get uiMetricGlobalRank => 'Global rank';

  @override
  String get uiMetricPlayCount => 'Play count';

  @override
  String get uiMetricPlayTime => 'Play time';

  @override
  String get uiCatalogTitle => 'UI kit';

  @override
  String get uiCatalogTheme => 'Switch theme';

  @override
  String get uiCatalogTypography => 'Typography and surfaces';

  @override
  String get uiCatalogButtons => 'Buttons';

  @override
  String get uiCatalogInputs => 'Input and selection';

  @override
  String get uiCatalogFeedback => 'Feedback';

  @override
  String get uiCatalogNavigation => 'Navigation';

  @override
  String get uiCatalogConfirmMessage =>
      'This confirms a preview action only. No account or data will be changed.';

  @override
  String get newsTitle => 'News';

  @override
  String get newsRefresh => 'Refresh news';

  @override
  String get newsEmpty => 'No news available.';

  @override
  String get newsLoadMore => 'Load more news';

  @override
  String get newsLoading => 'Loading news…';

  @override
  String get newsKeepingContent => 'Previously loaded content is still shown.';

  @override
  String get newsNotFound => 'This news post is unavailable.';

  @override
  String get newsCancelled => 'News loading was cancelled.';

  @override
  String get newsAccessDenied => 'Unable to access news.';

  @override
  String get newsInvalidResponse => 'The news response could not be read.';

  @override
  String get newsUnavailable => 'News is temporarily unavailable.';

  @override
  String get newsLinkFailed => 'Unable to open this link.';

  @override
  String get newsOriginal => 'Open original';

  @override
  String get newsReaderNotice =>
      'External images follow your saved preference. Embeds open only on the original page.';

  @override
  String get spotlightsTitle => 'Spotlights';

  @override
  String get spotlightsChoose => 'Choose a spotlight';

  @override
  String get spotlightsEmpty => 'No spotlights available.';

  @override
  String get spotlightsMaps => 'Beatmapsets';

  @override
  String get spotlightsNoMaps =>
      'No beatmapsets for this spotlight and ruleset.';

  @override
  String get spotlightsRankingLimit => 'Spotlight ranking · up to 40 players';

  @override
  String get spotlightsNotFound => 'This spotlight or ruleset is unavailable.';

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
  String get profileSearchHint => 'Exact username or ID';

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
          decimalDigits: 0,
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
      'Open a player’s profile by exact username or ID. No sign-in required.';

  @override
  String get profileSearchHelp =>
      'Choose the statistics mode, then enter a full username or ID and submit. No suggestions while typing. For a numeric username, use @.';

  @override
  String get profileOpen => 'Open profile';

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
    return 'Player’s plays: $count';
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

  @override
  String get rankingsTitle => 'Rankings';

  @override
  String get rankingsScore => 'Score';

  @override
  String get rankingsRefresh => 'Refresh rankings';

  @override
  String get rankingsEmpty => 'No players found.';

  @override
  String get rankingsLoadMore => 'Load more players';

  @override
  String get rankingsLoading => 'Loading rankings…';

  @override
  String get rankingsKeepingContent =>
      'Could not update. Previously loaded rankings are shown.';

  @override
  String get rankingsCancelled => 'Loading cancelled.';

  @override
  String get rankingsNotFound => 'Ranking not found.';

  @override
  String get rankingsAccessDenied => 'Ranking is not accessible.';

  @override
  String get rankingsInvalidResponse => 'Unexpected ranking response.';

  @override
  String get rankingsUnavailable => 'Could not load rankings.';

  @override
  String rankingsRankedScore(int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Ranked score: $scoreString';
  }

  @override
  String get rankingsCountry => 'Country code';

  @override
  String get rankingsCountryInvalid => 'Enter a two-letter country code.';

  @override
  String get rankingsWorldwide => 'Worldwide';

  @override
  String get rankingsAllKeys => 'All key counts';

  @override
  String get germanLanguage => 'German';

  @override
  String get frenchLanguage => 'French';

  @override
  String get spanishLanguage => 'Spanish';

  @override
  String get japaneseLanguage => 'Japanese';

  @override
  String get chineseLanguage => 'Chinese (Simplified)';
}
