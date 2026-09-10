// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSaveFailed => '无法保存主题。';

  @override
  String get spotlightsParticipants => '参与人数';

  @override
  String get spotlightsSearch => '名称、年份或ID';

  @override
  String get spotlightsNoMatch => '没有匹配的Spotlight。';

  @override
  String spotlightsPeriod(String start, String end) {
    return '$start 至 $end';
  }

  @override
  String spotlightsStarts(String date) {
    return '从$date起';
  }

  @override
  String spotlightsEnds(String date) {
    return '至$date';
  }

  @override
  String spotlightsDifficultyCount(int count) {
    return '图集包含$count个难度';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSignOutConfirm => '要在此设备上退出登录吗？仍可查看你的公开osu!资料。';

  @override
  String get medalsLoading => '正在加载奖章…';

  @override
  String get medalsFailed => '无法从osu!加载奖章详情。请重试。';

  @override
  String get medalsEmpty => '尚未获得奖章。';

  @override
  String get scoreMiss => '未命中';

  @override
  String get scoreFruit => '水果';

  @override
  String get scoreDroplet => '水滴';

  @override
  String get scoreTinyDroplet => '小水滴';

  @override
  String get scoreTinyMiss => '漏接小水滴';

  @override
  String get scoreJudgementPercentNotice =>
      '百分比表示此处所列判定的占比，并非谱面完成度或最大连击。滑条刻度及内部旧版计数不包含在内。';

  @override
  String get profilePreviousNames => '曾用名';

  @override
  String get profileGroups => '用户组';

  @override
  String profileTeamTag(String tag) {
    return '战队 · $tag';
  }

  @override
  String get profileMedals => '奖章';

  @override
  String get profileMedalsView => '查看已获得的奖章';

  @override
  String profileMedalId(int id) {
    return '奖章 #$id';
  }

  @override
  String get profileRankedPlay => '排位对战';

  @override
  String get profileRankedPlayEmpty => '此模式暂无排位对战统计。';

  @override
  String profileRankedPool(int id) {
    return '对战池 #$id';
  }

  @override
  String get profileProvisionalRating => '暂定评级';

  @override
  String get profileRating => '评级';

  @override
  String get profileFirstPlaces => '第一名次数';

  @override
  String get profileRankedPoints => '对战积分';

  @override
  String get profileDailyChallenge => '每日挑战';

  @override
  String get profileDailyPlays => '参与挑战次数';

  @override
  String get profileDailyCurrent => '当前连续天数';

  @override
  String get profileDailyBest => '最长连续天数';

  @override
  String get profileWeeklyCurrent => '当前连续周数';

  @override
  String get profileWeeklyBest => '最长连续周数';

  @override
  String get profileTop10 => '前10%次数';

  @override
  String get profileTop50 => '前50%次数';

  @override
  String profileDailyUpdated(String date) {
    return '最近参与：$date';
  }

  @override
  String profileWeeklyUpdated(String date) {
    return '最近周连续记录：$date';
  }

  @override
  String get shareSystem => '其他应用…';

  @override
  String get shareCopy => '复制链接';

  @override
  String get shareCopied => '链接已复制';

  @override
  String get shareDestinationNotice =>
      '在打开的应用或浏览器中选择接收者。不会自动发布任何内容。链接指向 osu! 的公开页面，预览取决于接收应用。';

  @override
  String get shareAction => '分享';

  @override
  String get shareBeatmapAction => '分享谱面';

  @override
  String get shareFailed => '无法打开分享菜单，请重试。';

  @override
  String get contentMediaSettings => '外部图片';

  @override
  String get contentMediaConsent =>
      '个人资料、谱面描述和新闻中的图片从外部服务器下载。这些服务器会收到您的 IP 地址，并可能记录请求。此选择适用于本设备上的所有此类图片，可在账户菜单中更改。osu! 头像和谱面封面单独加载。';

  @override
  String get contentMediaAllow => '允许图片';

  @override
  String get contentMediaDecline => '暂不加载';

  @override
  String get contentMediaDisabled => '外部图片已关闭。您可以在账户菜单中开启。';

  @override
  String get contentMediaSaveFailed => '无法保存此设置。重启应用后可能恢复原设置。';

  @override
  String get contentImageUnsupported => '不支持此图片地址。请打开原页面查看。';

  @override
  String get profilePlayHistoryTitle => '每月游玩次数';

  @override
  String rankingsPosition(int position) {
    final intl.NumberFormat positionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String positionString = positionNumberFormat.format(position);

    return '第 $positionString 名';
  }

  @override
  String get rankingsPositionNotice =>
      '此名次属于当前筛选后的榜单，并非全球 PP 排名。加载不同页面时排名可能变化，请刷新以更新。';

  @override
  String get rankingsCountrySelection => '国家或地区';

  @override
  String get rankingsCountrySearch => '国家名称或代码';

  @override
  String get rankingsCountryCatalogHint =>
      '按英文名称或两字母代码搜索。部分条目仅显示代码。是否提供排名取决于 osu!。';

  @override
  String get rankingsCountryCatalogFailed => '无法加载国家列表。';

  @override
  String get rankingsCountryNoMatch => '没有匹配的国家。';

  @override
  String get rankingsEnd => '已到可用排名末尾。';

  @override
  String get scoreHitsTitle => '判定结果';

  @override
  String get scoreHitsExplanation => '判定名称沿用API。缺失不等于零；最大数量指完美游玩的判定数量，而非每行的目标。';

  @override
  String get scoreHitsAchieved => '实际数量';

  @override
  String get scoreHitsMaximum => '完美游玩数量';

  @override
  String get scoreModSettingsTitle => '模组设置';

  @override
  String get scoreModSettingsExplanation => '保留API参数名称。仅显示已提供的设置，不推测默认值。';

  @override
  String get scoreNoModSettings => '未提供明确设置。';

  @override
  String get scoreDetailsUnavailable => '不可用';

  @override
  String get scoreSettingEnabled => '已启用';

  @override
  String get scoreSettingDisabled => '已禁用';

  @override
  String get beatmapDescription => '谱面说明';

  @override
  String get contentPageUnavailable => '无法在此显示内容。你可以打开原文。';

  @override
  String get scoreDetailsTitle => '成绩详情';

  @override
  String get scoreOpenBeatmap => '打开谱面';

  @override
  String get scoreStandardisedTotal => '标准化分数';

  @override
  String get mapSetPlays => '谱面集游玩次数';

  @override
  String get mapFavourites => '收藏数';

  @override
  String get mapBpm => 'BPM';

  @override
  String get profileReplayHistoryTitle => '每月回放观看次数';

  @override
  String get profileReplayHistoryExplanation => '不显示没有记录的月份；缺少数据不代表零。';

  @override
  String get profileAbout => '关于我';

  @override
  String get contentPageNotice =>
      '外部图片按您保存的设置加载。嵌入内容仅在原页面打开。如无已排版的内容，BBCode 将以纯文本显示。';

  @override
  String get contentLinkFailed => '无法打开链接。';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileOverview => '概览';

  @override
  String get profilePpLabel => '表现分 (PP)';

  @override
  String get profileGlobalRankLabel => '全球排名';

  @override
  String get profileCountryRankLabel => '地区排名';

  @override
  String get profileStatisticsTitle => '统计';

  @override
  String get profileAccuracyLabel => '准确率';

  @override
  String get profilePlayCountLabel => '游玩次数';

  @override
  String get profilePlayTimeLabel => '游玩时间';

  @override
  String get profileComboLabel => '最高连击';

  @override
  String get profileValueUnavailable => '暂无数据';

  @override
  String get profileGradesTitle => '成绩等级';

  @override
  String get profileRankedScoreLabel => '排名总分';

  @override
  String get profileTotalScoreLabel => '总分';

  @override
  String get profileTotalHitsLabel => '总击中数';

  @override
  String get profileReplaysLabel => '他人观看回放次数';

  @override
  String get profileHistoryTitle => '排名历史';

  @override
  String get profileHistoryEmpty => '此模式暂无排名历史。';

  @override
  String get profileHistoryExplanation => '按 API 记录顺序显示，并非日历日期。断线表示排名数据缺失。';

  @override
  String get profileSwitchingMode => '正在加载所选模式，当前仍显示上一模式的数据。';

  @override
  String get profileUpdateFailed => '更新失败，已保留原有数据和模式。';

  @override
  String profileDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString小时$minutesString分钟';
  }

  @override
  String profileLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return '等级 $levelString';
  }

  @override
  String profileLevelProgress(int progress) {
    final intl.NumberFormat progressNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String progressString = progressNumberFormat.format(progress);

    return '距离下一等级的进度：$progressString%';
  }

  @override
  String profileHistorySample(int index) {
    final intl.NumberFormat indexNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);

    return '记录 $indexString';
  }

  @override
  String get navigationSearch => '搜索';

  @override
  String get navigationUnavailable => '此页面不可用。';

  @override
  String get searchClear => '清除搜索';

  @override
  String get contentImage => '图片';

  @override
  String get contentImageLoading => '正在加载图片…';

  @override
  String get contentImageFailed => '无法加载图片。图片可能不可用，或大小、格式不受支持。';

  @override
  String get contentImageOpen => '放大图片';

  @override
  String get contentDisclosure => '显示隐藏内容';

  @override
  String get contentUnsupported => '此嵌入内容可在原网页查看。';

  @override
  String get contentOriginal => '打开原网页';

  @override
  String get contentUnavailable => '阅读器无法显示此内容。请打开原网页。';

  @override
  String get uiCatalogMedia => '图片与徽章';

  @override
  String get uiCatalogCards => '玩家与内容卡片';

  @override
  String get uiCatalogCharts => '图表';

  @override
  String get uiCatalogStates => '内容状态';

  @override
  String get uiCatalogSampleNotice => '仅为预览数据，并非真实玩家统计。使用现有 Tracksu 图片展示布局。';

  @override
  String get uiCatalogHistory => '排名历史';

  @override
  String get uiCatalogActivity => '游戏活动';

  @override
  String get uiCatalogSinglePoint => '单个数据点';

  @override
  String get uiCatalogFlatSeries => '数值无变化';

  @override
  String get uiCatalogOffline => '无网络连接';

  @override
  String get uiCatalogNoData => '暂无数据';

  @override
  String get uiCatalogChartHint => '点击、拖动或使用滑块查看数据。排名数字越小，位置越高。';

  @override
  String get uiMetricPerformance => '表现分';

  @override
  String get uiMetricAccuracy => '准确率';

  @override
  String get uiMetricGlobalRank => '全球排名';

  @override
  String get uiMetricPlayCount => '游玩次数';

  @override
  String get uiMetricPlayTime => '游玩时间';

  @override
  String get uiCatalogTitle => 'UI kit';

  @override
  String get uiCatalogTheme => '切换主题';

  @override
  String get uiCatalogTypography => '字体与背景';

  @override
  String get uiCatalogButtons => '按钮';

  @override
  String get uiCatalogInputs => '输入与选择';

  @override
  String get uiCatalogFeedback => '提示消息';

  @override
  String get uiCatalogNavigation => '导航';

  @override
  String get uiCatalogConfirmMessage => '这仅确认预览操作，不会更改任何账号或数据。';

  @override
  String get newsTitle => '新闻';

  @override
  String get newsRefresh => '刷新新闻';

  @override
  String get newsEmpty => '暂无新闻。';

  @override
  String get newsLoadMore => '加载更多新闻';

  @override
  String get newsLoading => '正在加载新闻…';

  @override
  String get newsKeepingContent => '仍在显示之前加载的内容。';

  @override
  String get newsNotFound => '这篇新闻暂不可用。';

  @override
  String get newsCancelled => '已取消加载新闻。';

  @override
  String get newsAccessDenied => '无法访问新闻。';

  @override
  String get newsInvalidResponse => '无法读取新闻响应。';

  @override
  String get newsUnavailable => '新闻暂时不可用。';

  @override
  String get newsLinkFailed => '无法打开此链接。';

  @override
  String get newsOriginal => '打开原文';

  @override
  String get newsReaderNotice => '外部图片按您保存的设置加载。嵌入内容仅在原页面打开。';

  @override
  String get spotlightsTitle => 'Spotlights';

  @override
  String get spotlightsChoose => '选择 Spotlight';

  @override
  String get spotlightsEmpty => '暂无可用的 Spotlight。';

  @override
  String get spotlightsMaps => '谱面集';

  @override
  String get spotlightsNoMaps => '此 Spotlight 和游戏模式下暂无谱面集。';

  @override
  String get spotlightsRankingLimit => 'Spotlight 排名 · 最多 40 名玩家';

  @override
  String get spotlightsNotFound => '此 Spotlight 或游戏模式不可用。';

  @override
  String get appTitle => 'Tracksu';

  @override
  String get guestModeTitle => '访客模式';

  @override
  String get guestSignedOutDescription => '以访客身份浏览 osu! 公开数据。登录后即可使用账号功能。';

  @override
  String get guestSignedInDescription => '你已登录。无需账号也能浏览公开数据。';

  @override
  String get signInWithOsu => '使用 osu! 登录';

  @override
  String get signInWithAnotherAccount => '使用其他账号登录';

  @override
  String get signOut => '退出登录';

  @override
  String get signingOut => '正在退出登录…';

  @override
  String get signOutFailed => '无法退出登录，请重试。';

  @override
  String get systemLanguage => '跟随系统';

  @override
  String get englishLanguage => '英语';

  @override
  String get russianLanguage => '俄语';

  @override
  String get loginToOsu => '登录 osu!';

  @override
  String get signingIn => '正在登录…';

  @override
  String get openingOsu => '正在打开 osu!…';

  @override
  String get continueWithOsu => '通过 osu! 继续';

  @override
  String get authorizationExpired => '此授权请求已过期，请重试。';

  @override
  String get authorizationResponseUnavailable => '无法接收授权响应。';

  @override
  String get authorizationResponseMismatch => '授权响应与本次登录请求不匹配。';

  @override
  String get authorizationCancelled => '授权已取消或被拒绝。';

  @override
  String get authorizationResponseInvalid => '授权响应无效。';

  @override
  String get authorizationPreparationFailed => '无法准备 osu! 授权。';

  @override
  String get authorizationLaunchFailed => '无法打开 osu! 授权页面。';

  @override
  String get authorizationCompletionFailed => '无法完成授权。';

  @override
  String get authorizationIncomplete => '授权尚未完成，请重试。';

  @override
  String get viewMyProfile => '查看我的资料';

  @override
  String get profileSearchHint => '完整用户名或 ID';

  @override
  String get profileSearchInvalid => '请输入有效的用户名或正整数 ID。';

  @override
  String get rulesetOsu => 'osu!';

  @override
  String get rulesetTaiko => 'taiko';

  @override
  String get rulesetFruits => 'catch';

  @override
  String get rulesetMania => 'mania';

  @override
  String get profileLoading => '正在加载个人资料…';

  @override
  String get profileUnavailable => '个人资料不可用，请重试。';

  @override
  String get retry => '重试';

  @override
  String profileId(int id) {
    return 'ID：$id';
  }

  @override
  String profilePerformance(double pp) {
    final intl.NumberFormat ppNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 0,
        );
    final String ppString = ppNumberFormat.format(pp);

    return '表现分：$ppString';
  }

  @override
  String profileCountry(String country) {
    return '国家：$country';
  }

  @override
  String profileAccuracy(double accuracy) {
    final intl.NumberFormat accuracyNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 2,
        );
    final String accuracyString = accuracyNumberFormat.format(accuracy);

    return '准确率：$accuracyString%';
  }

  @override
  String profilePlayCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '游玩次数：$countString';
  }

  @override
  String get profileSearchIntroduction => '通过完整用户名或 ID 打开玩家资料，无需登录。';

  @override
  String get profileSearchHelp =>
      '选择统计模式，输入完整用户名或 ID 后提交。目前不提供输入建议。纯数字用户名请加上 @。';

  @override
  String get profileOpen => '打开资料';

  @override
  String get profileSearch => '搜索玩家';

  @override
  String get profileRefreshing => '正在更新个人资料';

  @override
  String get profileRefresh => '刷新';

  @override
  String get profileShowingPreviousData => '更新失败，正在显示之前加载的数据。';

  @override
  String get profileNotFound => '未找到玩家，请检查用户名或 ID。';

  @override
  String get profileAccessDenied => 'osu! 拒绝了访问。如果是你自己的资料，请尝试重新登录。';

  @override
  String get profileRateLimited => '请求过多，请稍后重试。';

  @override
  String get profileConnectionFailed => '无法连接，请检查网络后重试。';

  @override
  String get profileInvalidResponse => '服务器返回了不支持的个人资料响应。';

  @override
  String get profileOnline => '在线';

  @override
  String get profileOffline => '离线';

  @override
  String get profileSupporter => 'osu!supporter';

  @override
  String get profileNoStatistics => '此游戏模式下暂无统计数据。';

  @override
  String get profileUnranked => '暂无全球排名';

  @override
  String profileGlobalRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return '全球排名：#$rankString';
  }

  @override
  String profileCountryRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return '国家排名：#$rankString';
  }

  @override
  String profilePlayTime(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return '游玩时长：$hoursString 小时';
  }

  @override
  String profileMaximumCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return '最大连击：$comboString';
  }

  @override
  String get languageChangeFailed => '无法保存语言设置。';

  @override
  String get languageSelection => '语言';

  @override
  String get account => '账号';

  @override
  String get scoresTitle => '成绩';

  @override
  String get scoresBest => '最佳';

  @override
  String get scoresRecent => '最近';

  @override
  String get scoresRefresh => '刷新成绩';

  @override
  String get scoresLoading => '正在加载成绩…';

  @override
  String get scoresEmpty => '此玩家在该游戏模式下暂无成绩。';

  @override
  String get scoresLoadMore => '加载更多';

  @override
  String get scoresKeepingContent => '仍在显示之前加载的成绩。';

  @override
  String get scoresCancelled => '已取消加载。';

  @override
  String get scoresNotFound => '未找到成绩。';

  @override
  String get scoresAccessDenied => 'osu! 拒绝了对成绩的访问。';

  @override
  String get scoresInvalidResponse => '服务器返回了不支持的成绩响应。';

  @override
  String get scoresUnavailable => '成绩暂时不可用。';

  @override
  String get scoresNoMods => '无模组';

  @override
  String get scoresNoPp => 'PP 不可用';

  @override
  String get scoresFailedPlay => '未通过';

  @override
  String scoresBeatmap(int id) {
    return '谱面 #$id';
  }

  @override
  String scoresGrade(String grade) {
    return '评级：$grade';
  }

  @override
  String scoresCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return '连击：$comboString';
  }

  @override
  String scoresTotal(int total) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '分数：$totalString';
  }

  @override
  String scoresMods(String mods) {
    return '模组：$mods';
  }

  @override
  String scoresPlayedAt(String date) {
    return '游玩时间：$date';
  }

  @override
  String get beatmapsTitle => '谱面';

  @override
  String get beatmapsMostPlayed => '最常游玩';

  @override
  String get beatmapsFavourite => '收藏';

  @override
  String get beatmapsRanked => '上榜';

  @override
  String get beatmapsPending => '待定';

  @override
  String get beatmapsGraveyard => '坟场';

  @override
  String get beatmapsLoved => '社区喜爱';

  @override
  String get beatmapsGuest => '客串难度';

  @override
  String get beatmapsNominated => '已提名';

  @override
  String get beatmapsRefresh => '刷新谱面';

  @override
  String get beatmapsEmpty => '此分类下暂无谱面。';

  @override
  String get beatmapsLoadMore => '加载更多谱面';

  @override
  String get beatmapsLoading => '正在加载谱面…';

  @override
  String get beatmapsKeepingContent => '更新失败，仍在显示之前加载的谱面。';

  @override
  String get beatmapsCancelled => '已取消加载。';

  @override
  String get beatmapsNotFound => '未找到此玩家的谱面。';

  @override
  String get beatmapsAccessDenied => '目前无法访问谱面。';

  @override
  String get beatmapsInvalidResponse => '服务器返回了意外的谱面响应。';

  @override
  String get beatmapsUnavailable => '无法加载谱面，请重试。';

  @override
  String beatmapsSetFallback(int id) {
    return '谱面集 #$id';
  }

  @override
  String beatmapsMapFallback(int id) {
    return '谱面 #$id';
  }

  @override
  String beatmapsPlayCount(int count) {
    return '该玩家的游玩次数：$count';
  }

  @override
  String get beatmapTitle => '谱面';

  @override
  String get beatmapNotFound => '未找到谱面。';

  @override
  String get beatmapAccessDenied => '无法访问此谱面或排行榜。';

  @override
  String get beatmapInvalidResponse => '意外的谱面响应。';

  @override
  String get beatmapUnavailable => '无法加载谱面数据。';

  @override
  String get beatmapLeaderboard => '最佳成绩';

  @override
  String get beatmapRefreshLeaderboard => '刷新成绩';

  @override
  String get beatmapNoScores => '暂无成绩。';

  @override
  String beatmapLeaderboardPlayer(int position, String name) {
    return '#$position · $name';
  }

  @override
  String beatmapPlayerId(int id) {
    return '玩家 #$id';
  }

  @override
  String beatmapCreator(String name) {
    return '制谱：$name';
  }

  @override
  String get beatmapRefresh => '刷新谱面';

  @override
  String get beatmapDifficulties => '难度';

  @override
  String get beatmapNoDifficulties => '暂无可用难度。';

  @override
  String beatmapDifficultyInfo(String mode, double stars, int seconds) {
    return '$mode · $stars ★ · $seconds 秒';
  }

  @override
  String get rankingsTitle => '排名';

  @override
  String get rankingsScore => '分数';

  @override
  String get rankingsRefresh => '刷新排名';

  @override
  String get rankingsEmpty => '未找到玩家。';

  @override
  String get rankingsLoadMore => '加载更多玩家';

  @override
  String get rankingsLoading => '正在加载排名…';

  @override
  String get rankingsKeepingContent => '更新失败，正在显示之前加载的排名。';

  @override
  String get rankingsCancelled => '已取消加载。';

  @override
  String get rankingsNotFound => '未找到排名。';

  @override
  String get rankingsAccessDenied => '无法访问排名。';

  @override
  String get rankingsInvalidResponse => '意外的排名响应。';

  @override
  String get rankingsUnavailable => '无法加载排名。';

  @override
  String rankingsRankedScore(int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return '排名分数：$scoreString';
  }

  @override
  String get rankingsCountry => '国家代码';

  @override
  String get rankingsCountryInvalid => '请输入两个字母的国家代码。';

  @override
  String get rankingsWorldwide => '全球';

  @override
  String get rankingsAllKeys => '所有键数';

  @override
  String get germanLanguage => '德语';

  @override
  String get frenchLanguage => '法语';

  @override
  String get spanishLanguage => '西班牙语';

  @override
  String get japaneseLanguage => '日语';

  @override
  String get chineseLanguage => '中文（简体）';
}
