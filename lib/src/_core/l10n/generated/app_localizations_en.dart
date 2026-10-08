// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsCacheCalculating => 'Calculating cache size…';

  @override
  String get settingsCacheFailed => 'Could not access the cache. Try again.';

  @override
  String settingsCacheConfirm(String size) {
    return 'Delete $size MB of images and audio? Your account and settings stay.';
  }

  @override
  String settingsCacheSize(String size) {
    return '$size MB';
  }

  @override
  String get audioPreview => 'Audio preview';

  @override
  String get audioPlay => 'Play';

  @override
  String get audioPause => 'Pause';

  @override
  String get audioReplay => 'Replay';

  @override
  String get audioCancel => 'Cancel loading';

  @override
  String get audioLoading => 'Loading audio…';

  @override
  String get audioPlaying => 'Playing';

  @override
  String get audioPaused => 'Paused';

  @override
  String get audioCompleted => 'Finished';

  @override
  String get audioFailed =>
      'Could not play this audio. Check your connection and try again.';

  @override
  String get audioFailedUnavailable =>
      'This audio preview is no longer available.';

  @override
  String get audioFailedUnsupported =>
      'This audio format cannot be played on this device.';

  @override
  String get audioFailedFocus =>
      'Another app is using audio. Try again when it stops.';

  @override
  String get audioFailedUnknown => 'Could not play this audio.';

  @override
  String get audioSeek => 'Playback position';

  @override
  String get teamTitle => 'Team';

  @override
  String get teamLoading => 'Loading team…';

  @override
  String get teamNotFound => 'Team not found';

  @override
  String get teamAccessDenied => 'This team is not available to view.';

  @override
  String get teamFailed => 'Could not load the team. Try again.';

  @override
  String get teamOpen => 'Recruiting';

  @override
  String get teamClosed => 'Recruitment closed';

  @override
  String teamSlots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free slots',
      one: '1 free slot',
      zero: 'No free slots',
    );
    return '$_temp0';
  }

  @override
  String teamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String teamCreated(String date) {
    return 'Created $date';
  }

  @override
  String teamDefaultMode(String mode) {
    return 'Default mode: $mode';
  }

  @override
  String get teamDescription => 'About the team';

  @override
  String get teamLeader => 'Team leader';

  @override
  String teamLastVisit(String date) {
    return 'Last seen: $date';
  }

  @override
  String get scoreGaugeReference =>
      'osu!lazer accuracy reference scale; SS requires 100% (its visible band is enlarged). The grade comes from the result: misses, mods and legacy scoring can also affect it.';

  @override
  String get settingsCache => 'Cache';

  @override
  String get settingsClearCache => 'Clear';

  @override
  String get settingsCacheDescription =>
      'Covers and audio previews saved on this device.';

  @override
  String get settingsCacheCleared => 'Cache cleared';

  @override
  String get profileDailyEmpty =>
      'This player has not taken part in the daily challenge yet.';

  @override
  String get aboutTitle => 'About Tracksu';

  @override
  String get aboutTabApp => 'About';

  @override
  String get settingsClearCacheTitle => 'Clear the cache?';

  @override
  String get aboutHistoryShort =>
      'Tracksu has existed since 2021 and has been developed and rebuilt more than once.';

  @override
  String get aboutTabAuthors => 'Authors';

  @override
  String get aboutTabLicenses => 'Licenses';

  @override
  String get aboutRoleAuthor => 'Author';

  @override
  String get aboutRoleCoauthor => 'Co-author';

  @override
  String get aboutThanksTitle => 'Thanks';

  @override
  String get aboutThanksBody =>
      'To ppy and the osu! team for the game and its public API. To the osu! community for the maps, the players and the ideas. To the authors of the open-source libraries listed under Licenses.';

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
      'Open-source libraries and asset licenses';

  @override
  String get licensesIntro =>
      'Tracksu is built on open-source software. These are the packages inside the app and the license texts their authors require us to show.';

  @override
  String get licensesSearch => 'Search packages';

  @override
  String get licensesNoMatch => 'No matching packages.';

  @override
  String licensesPackageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packages',
      one: '$count package',
    );
    return '$_temp0';
  }

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
  String spotlightsStartDate(String date) {
    return 'Start date: $date';
  }

  @override
  String spotlightsEndDate(String date) {
    return 'End date: $date';
  }

  @override
  String get spotlightsKindMonthly => 'Monthly';

  @override
  String get spotlightsKindBestOf => 'Best of the year';

  @override
  String get spotlightsKindSpecial => 'Special';

  @override
  String get spotlightsKindTheme => 'Theme';

  @override
  String get spotlightsRulesetUnavailable => 'No ranking for this ruleset.';

  @override
  String get spotlightsRulesetUnavailableHint =>
      'osu! ran this spotlight only for some rulesets. Choose another one above.';

  @override
  String get spotlightsHomeDescription =>
      'Old osu! charts; the last one ran in 2020. osu! no longer holds Spotlights — Seasons replaced them.';

  @override
  String get spotlightsOpen => 'Spotlights archive';

  @override
  String spotlightsDifficultyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count difficulties in set',
      one: '$count difficulty in set',
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
  String get contentMediaSettings => 'Load images';

  @override
  String get contentMediaConsent =>
      'Covers and avatars load automatically. Turn off to save data.';

  @override
  String get contentMediaAllow => 'Allow images';

  @override
  String get contentMediaDecline => 'Not now';

  @override
  String get contentMediaDisabled => 'Images are off. Enable them in Settings.';

  @override
  String get contentMediaSaveFailed =>
      'Could not save this preference. It may revert after restarting the app.';

  @override
  String get contentImageUnsupported =>
      'This image address is not supported. Open the original page to view it.';

  @override
  String get contentImagePaused => 'Image loading is paused.';

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
      'Search a country name or two-letter code. Ranking availability depends on osu!.';

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
  String get profileOverview => 'Profile';

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
  String get profileNotRanked => 'Not ranked';

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
  String get contentImageUnavailable =>
      'This image is no longer available at its source.';

  @override
  String get contentImageNetwork =>
      'Could not reach the image host. Check your connection and try again.';

  @override
  String get contentImageFormat => 'This image format cannot be displayed.';

  @override
  String get contentImageTooLarge => 'This image is too large to display.';

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
  String get spotlightsNotFound => 'This spotlight is unavailable.';

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
  String get profileSearchHint => 'Username or ID';

  @override
  String get profileSearchInvalid => 'Enter a valid username or positive ID.';

  @override
  String get rulesetOsu => 'ctd';

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
      'Find players by name, or enter an exact user ID. Use @ for an exact username, including numeric names.';

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
  String get profileSupporterInfo =>
      'This player has osu!supporter: a voluntary subscription that keeps osu! running without ads. Supporters get extra features such as more friends, a profile cover and in-game beatmap downloads.';

  @override
  String get actionGotIt => 'Got it';

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
  String get scoresPinned => 'Pinned';

  @override
  String get scoresFirsts => 'First places';

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
  String gradeSilver(String grade) {
    return 'Silver $grade';
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
  String get beatmapsCategory => 'Map category';

  @override
  String get scoresCategory => 'Score type';

  @override
  String get beatmapsGroupPlayer => 'Player';

  @override
  String get beatmapsGroupMapper => 'Mapper';

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
  String get rankingsAllKeys => 'All';

  @override
  String get rankingsPlayers => 'Players';

  @override
  String get rankingsTeams => 'Teams';

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

  @override
  String get scrollToTop => 'Back to top';

  @override
  String get dailyTitle => 'Map of the day';

  @override
  String dailyRemaining(String time) {
    return '$time left';
  }

  @override
  String dailyParticipants(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString players',
      one: '$countString player',
    );
    return '$_temp0';
  }

  @override
  String get dailyNone => 'No daily challenge right now.';

  @override
  String get dailyLeaderboard => 'Today\'s leaderboard';

  @override
  String get dailyOpenMap => 'Open map';

  @override
  String get dailyFailed => 'Couldn\'t load the map of the day.';

  @override
  String get contentVideoPlay => 'Play video';

  @override
  String get contentVideoPause => 'Pause';

  @override
  String get contentVideoFullscreen => 'Full screen';

  @override
  String get contentVideoExitFullscreen => 'Exit full screen';

  @override
  String get contentVideoFailed => 'Couldn\'t play the video.';

  @override
  String get contentEmbedYoutube => 'Watch on YouTube';

  @override
  String contentEmbedOpen(String host) {
    return 'Open on $host';
  }

  @override
  String get commentsTitle => 'Comments';

  @override
  String commentsTitleCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString comments',
      one: '$countString comment',
    );
    return '$_temp0';
  }

  @override
  String get commentsSortNew => 'New';

  @override
  String get commentsSortOld => 'Old';

  @override
  String get commentsSortTop => 'Top';

  @override
  String get commentsLoading => 'Loading comments';

  @override
  String get commentsFailed => 'Couldn\'t load comments.';

  @override
  String get commentsEmpty => 'No comments yet.';

  @override
  String get commentsDeleted => 'Comment deleted';

  @override
  String get commentsEdited => 'edited';

  @override
  String get commentsPinned => 'Pinned';

  @override
  String get commentsUnknownUser => 'Deleted user';

  @override
  String commentsVotes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString votes',
      one: '$countString vote',
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
      other: '$countString replies',
      one: '$countString reply',
    );
    return '$_temp0';
  }

  @override
  String get commentsHideReplies => 'Hide replies';

  @override
  String get commentsMoreReplies => 'More replies';

  @override
  String get commentsJustNow => 'just now';

  @override
  String commentsMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString min ago',
      one: '$countString min ago',
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
      other: '$countString h ago',
      one: '$countString h ago',
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
      other: '$countString days ago',
      one: '$countString day ago',
    );
    return '$_temp0';
  }

  @override
  String get rankingsCountries => 'Countries';

  @override
  String rankingsCountryPlayers(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString active players',
      one: '$countString active player',
    );
    return '$_temp0';
  }

  @override
  String get beatmapSearchTitle => 'Beatmap search';

  @override
  String get beatmapSearchHomeDescription =>
      'Ranked, loved and other osu! beatmaps';

  @override
  String get beatmapSearchHint => 'Title, artist or mapper';

  @override
  String get beatmapSearchStatus => 'Beatmap status';

  @override
  String get beatmapSearchLeaderboard => 'Has leaderboard';

  @override
  String get beatmapSearchQualified => 'Qualified';

  @override
  String get beatmapSearchWip => 'Work in progress';

  @override
  String get beatmapSearchAny => 'Any status';

  @override
  String get beatmapSearchEmpty => 'Nothing found.';

  @override
  String get beatmapSearchFailed => 'Couldn\'t search beatmaps.';

  @override
  String beatmapSearchFound(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString beatmaps found',
      one: '$countString beatmap found',
    );
    return '$_temp0';
  }

  @override
  String get aboutBuiltWithFlutter => 'Built with Flutter';

  @override
  String get commentsReply => 'Reply';

  @override
  String get commentsVoteOnSite => 'Voting and replying happen on osu.ppy.sh';

  @override
  String get dailyHistory => 'Past days';

  @override
  String get dailyHistoryDescription =>
      'Previous maps of the day and final rankings';

  @override
  String get dailyHistoryLimit => 'Showing up to 250 recent days';

  @override
  String get dailyHistoryEmpty => 'No past days available';

  @override
  String get dailyPastUnavailable => 'This day\'s challenge is unavailable';

  @override
  String get leaderboardModsTitle => 'Mod filter';

  @override
  String get leaderboardModsAll => 'All mods';

  @override
  String get leaderboardModsReset => 'Reset';

  @override
  String get leaderboardModsApply => 'Apply';

  @override
  String get beatmapKeys => 'Keys';

  @override
  String get beatmapCircleSize => 'Circle size (CS)';

  @override
  String get beatmapHpDrain => 'HP drain';

  @override
  String get beatmapAccuracy => 'Accuracy (OD)';

  @override
  String get beatmapApproachRate => 'Approach rate (AR)';

  @override
  String get beatmapMaxCombo => 'Max combo';

  @override
  String get beatmapObjects => 'Objects';

  @override
  String get beatmapPlays => 'Plays';

  @override
  String get beatmapPassRate => 'Pass rate';

  @override
  String get beatmapSearchAnyMode => 'All';

  @override
  String get beatmapSearchGenre => 'Genre';

  @override
  String get beatmapSearchAnyGenre => 'Any genre';

  @override
  String get beatmapSearchLanguage => 'Language';

  @override
  String get beatmapSearchAnyLanguage => 'Any language';

  @override
  String get genreUnspecified => 'Unspecified';

  @override
  String get genreVideoGame => 'Video game';

  @override
  String get genreAnime => 'Anime';

  @override
  String get genreRock => 'Rock';

  @override
  String get genrePop => 'Pop';

  @override
  String get genreOther => 'Other';

  @override
  String get genreNovelty => 'Novelty';

  @override
  String get genreHipHop => 'Hip hop';

  @override
  String get genreElectronic => 'Electronic';

  @override
  String get genreMetal => 'Metal';

  @override
  String get genreClassical => 'Classical';

  @override
  String get genreFolk => 'Folk';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageInstrumental => 'Instrumental';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get languageSwedish => 'Swedish';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languagePolish => 'Polish';

  @override
  String get languageOther => 'Other';

  @override
  String get languageUnspecified => 'Unspecified';

  @override
  String get rankingsKudosu => 'Kudosu';

  @override
  String get rankingsKudosuHint =>
      'Top contributors by total kudosu earned for helping mappers. Up to 1,000 players.';

  @override
  String rankingsKudosuAvailable(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Available kudosu: $countString';
  }

  @override
  String get unifiedSearchTitle => 'Search players and maps';

  @override
  String get unifiedSearchDescription => 'Players, beatmaps and exact user IDs';

  @override
  String get unifiedSearchMaps => 'Maps';

  @override
  String get unifiedSearchPrompt => 'Type at least two characters';

  @override
  String get userSearchEmpty => 'No players found';

  @override
  String get userSearchFailed => 'Could not load players';

  @override
  String get userSearchLimit =>
      'Showing the first 100 players. Refine your search.';

  @override
  String get profileActivity => 'Activity';

  @override
  String get activityEmpty => 'No recent activity';

  @override
  String get activityLoading => 'Loading activity';

  @override
  String get activityFailed => 'Couldn\'t load activity';

  @override
  String activityRank(int rank, String beatmap) {
    return 'Rank #$rank on $beatmap';
  }

  @override
  String activityRankLost(String beatmap) {
    return 'Lost first place on $beatmap';
  }

  @override
  String activityMedal(String medal) {
    return 'Unlocked the “$medal” medal';
  }

  @override
  String activityPlaycount(String beatmap, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# times',
      one: '# time',
    );
    return '$beatmap has been played $_temp0';
  }

  @override
  String activityApproved(String beatmapset, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'ranked': 'ranked',
      'approved': 'approved',
      'qualified': 'qualified',
      'loved': 'loved',
      'other': 'updated',
    });
    return '$beatmapset has been $_temp0';
  }

  @override
  String activityUpload(String beatmapset) {
    return 'Submitted a new beatmap $beatmapset';
  }

  @override
  String activityUpdate(String beatmapset) {
    return 'Updated $beatmapset';
  }

  @override
  String activityRevive(String beatmapset) {
    return 'Revived $beatmapset from the graveyard';
  }

  @override
  String activityDelete(String beatmapset) {
    return '$beatmapset was deleted';
  }

  @override
  String get activitySupportFirst => 'Became an osu!supporter';

  @override
  String get activitySupportAgain => 'Supported osu! again';

  @override
  String get activitySupportGift => 'Received osu!supporter as a gift';

  @override
  String activityUsernameChange(String previous, String current) {
    return 'Changed username from $previous to $current';
  }

  @override
  String profileFollowers(int count) {
    return 'Followers: $count';
  }

  @override
  String profileMappingFollowers(int count) {
    return 'Mapping subscribers: $count';
  }

  @override
  String get hubTitle => 'osu!';

  @override
  String get changelogTitle => 'Changelog';

  @override
  String get changelogLoading => 'Loading changes';

  @override
  String get changelogEmpty => 'No changes yet';

  @override
  String get changelogFailed => 'Couldn\'t load changes';

  @override
  String get changelogAllStreams => 'All';

  @override
  String changelogUsers(String count) {
    return '$count users';
  }

  @override
  String get changelogTypeAdd => 'Added';

  @override
  String get changelogTypeFix => 'Fixed';

  @override
  String get changelogTypeMisc => 'Changed';

  @override
  String get changelogOpenLink => 'Open in browser';

  @override
  String get settingsCacheEnabled => 'Keep cache';

  @override
  String get eventsTitle => 'Events';

  @override
  String get eventsLoading => 'Loading events';

  @override
  String get eventsEmpty => 'No events yet';

  @override
  String get eventsFailed => 'Couldn\'t load events';

  @override
  String get eventsFilter => 'Event type';

  @override
  String get eventsAll => 'All events';

  @override
  String get eventsRanks => 'Ranks';

  @override
  String get eventsMedals => 'Medals';

  @override
  String get eventsBeatmaps => 'Beatmaps';

  @override
  String get eventsSupporters => 'Supporters and names';

  @override
  String get wikiTitle => 'Wiki';

  @override
  String get wikiLoading => 'Loading wiki';

  @override
  String get wikiFailed => 'Couldn\'t load the wiki';

  @override
  String get wikiNotFound => 'Article not found';

  @override
  String get wikiShownInEnglish =>
      'Not translated yet; showing the English article.';

  @override
  String get wikiSearchHint => 'Wiki article';

  @override
  String get wikiSearchHelp =>
      'Guides, rules, game modes and everything about osu!.';

  @override
  String get wikiNoResults => 'No articles found';

  @override
  String get eventsLoadOlder => 'Load older';

  @override
  String get changelogShowText => 'Show text';

  @override
  String get webPageLoading => 'Loading page';

  @override
  String get webPageFailed => 'Couldn\'t load the page';

  @override
  String get webPageOpenInBrowser => 'Open in browser';

  @override
  String get eventsGroupEmpty => 'None among the loaded events';

  @override
  String get eventsGroupHint =>
      'The feed only filters what is loaded. Load older events to look further back.';

  @override
  String get forumTitle => 'Forum';

  @override
  String get forumLoading => 'Loading forum';

  @override
  String get forumFailed => 'Couldn\'t load the forum';

  @override
  String get forumNotFound => 'This forum or topic is not available';

  @override
  String get forumEmpty => 'No topics yet';

  @override
  String get forumSubforums => 'Subforums';

  @override
  String get forumTopics => 'Topics';

  @override
  String get forumPinned => 'Pinned';

  @override
  String get forumAnnouncement => 'Announcement';

  @override
  String get forumLocked => 'Locked';

  @override
  String forumReplies(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString replies',
      one: '$countString reply',
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
      other: '$countString views',
      one: '$countString view',
    );
    return '$_temp0';
  }

  @override
  String get forumPostUnavailable => 'This post can\'t be shown here';

  @override
  String get settingsImages => 'Images';
}
