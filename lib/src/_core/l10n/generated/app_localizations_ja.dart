// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get profilePreviousNames => '以前のユーザー名';

  @override
  String get profileGroups => 'グループ';

  @override
  String profileTeamTag(String tag) {
    return 'チーム · $tag';
  }

  @override
  String get profileMedals => 'メダル';

  @override
  String get profileMedalsView => '獲得したメダルを見る';

  @override
  String get profileMedalMetadataNotice =>
      'プロフィールAPIはメダルのIDと獲得日時を返しますが、名前や画像は含みません。画像付きのコレクションはosu!で確認できます。';

  @override
  String profileMedalId(int id) {
    return 'メダル #$id';
  }

  @override
  String get profileRankedPlay => 'ランク対戦';

  @override
  String get profileRankedPlayEmpty => 'このモードのランク対戦データはありません。';

  @override
  String profileRankedPool(int id) {
    return 'プール #$id';
  }

  @override
  String get profileProvisionalRating => '暫定レーティング';

  @override
  String get profileRating => 'レーティング';

  @override
  String get profileFirstPlaces => '1位の回数';

  @override
  String get profileRankedPoints => '対戦ポイント';

  @override
  String get profileDailyChallenge => 'デイリーチャレンジ';

  @override
  String get profileDailyPlays => '挑戦した回数';

  @override
  String get profileDailyCurrent => '現在の連続日数';

  @override
  String get profileDailyBest => '最長連続日数';

  @override
  String get profileWeeklyCurrent => '現在の連続週数';

  @override
  String get profileWeeklyBest => '最長連続週数';

  @override
  String get profileTop10 => '上位10%に入った回数';

  @override
  String get profileTop50 => '上位50%に入った回数';

  @override
  String profileDailyUpdated(String date) {
    return '最終参加日：$date';
  }

  @override
  String profileWeeklyUpdated(String date) {
    return '最後の週間連続記録：$date';
  }

  @override
  String get shareSystem => 'その他のアプリ…';

  @override
  String get shareCopy => 'リンクをコピー';

  @override
  String get shareCopied => 'リンクをコピーしました';

  @override
  String get shareDestinationNotice =>
      '開いたアプリまたはブラウザーで送信先を選んでください。自動で投稿されることはありません。リンク先はosu!の公開ページです。プレビューは送信先アプリによって異なります。';

  @override
  String get shareAction => '共有';

  @override
  String get shareBeatmapAction => 'ビートマップを共有';

  @override
  String get shareFailed => '共有メニューを開けませんでした。もう一度お試しください。';

  @override
  String get contentMediaSettings => '外部画像';

  @override
  String get contentMediaConsent =>
      'プロフィール、ビートマップの説明、ニュース内の画像は外部サーバーから取得します。サーバーにはIPアドレスが伝わり、リクエストが記録される場合があります。この選択はこの端末のすべての外部画像に適用され、アカウントメニューから変更できます。osu!のアバターやマップのカバーは別に読み込まれます。';

  @override
  String get contentMediaAllow => '画像を許可';

  @override
  String get contentMediaDecline => '今は読み込まない';

  @override
  String get contentMediaDisabled => '外部画像は無効です。アカウントメニューから有効にできます。';

  @override
  String get contentMediaSaveFailed => '設定を保存できませんでした。再起動後に元に戻る場合があります。';

  @override
  String get contentImageUnsupported => 'この画像アドレスには対応していません。元のページを開いてください。';

  @override
  String get profilePlayHistoryTitle => '月ごとのプレイ回数';

  @override
  String rankingsPosition(int position) {
    final intl.NumberFormat positionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String positionString = positionNumberFormat.format(position);

    return '順位 #$positionString';
  }

  @override
  String get rankingsPositionNotice =>
      'この順位は絞り込み後の表での位置であり、世界PPランキングではありません。ページの読み込み中に順位が変わる場合があります。更新して確認してください。';

  @override
  String get rankingsCountrySelection => '国・地域';

  @override
  String get rankingsCountrySearch => '国名またはコード';

  @override
  String get rankingsCountryCatalogHint =>
      '英語名または2文字のコードで検索できます。一部はコードのみ表示されます。ランキングの提供状況はosu!によって異なります。';

  @override
  String get rankingsCountryCatalogFailed => '国一覧を読み込めませんでした。';

  @override
  String get rankingsCountryNoMatch => '一致する国がありません。';

  @override
  String get rankingsEnd => '表示可能なランキングはここまでです。';

  @override
  String get scoreHitsTitle => '判定結果';

  @override
  String get scoreHitsExplanation =>
      '判定名はAPIの表記です。欠損値はゼロではありません。最大数は完全なプレイの判定数であり、各行の目標ではありません。';

  @override
  String get scoreHitsAchieved => '取得数';

  @override
  String get scoreHitsMaximum => '完全なプレイの判定数';

  @override
  String get scoreModSettingsTitle => 'Modの設定';

  @override
  String get scoreModSettingsExplanation =>
      'APIの設定名を使用しています。送信された設定のみを表示し、既定値は推測しません。';

  @override
  String get scoreNoModSettings => '明示的な設定はありません。';

  @override
  String get scoreDetailsUnavailable => '利用できません';

  @override
  String get scoreSettingEnabled => '有効';

  @override
  String get scoreSettingDisabled => '無効';

  @override
  String get beatmapDescription => 'ビートマップの説明';

  @override
  String get contentPageUnavailable => 'この内容はここでは表示できません。元のページを開けます。';

  @override
  String get scoreDetailsTitle => 'スコアの詳細';

  @override
  String get scoreOpenBeatmap => 'ビートマップを開く';

  @override
  String get scoreStandardisedTotal => '標準化スコア';

  @override
  String get mapSetPlays => 'セットのプレイ数';

  @override
  String get mapFavourites => 'お気に入り';

  @override
  String get mapBpm => 'BPM';

  @override
  String get profileReplayHistoryTitle => '月別リプレイ視聴数';

  @override
  String get profileReplayHistoryExplanation =>
      'データのない月は省略されています。データがないことはゼロを意味しません。';

  @override
  String get profileAbout => '自己紹介';

  @override
  String get contentPageNotice =>
      '外部画像は保存された設定に従って読み込まれます。埋め込みコンテンツは元のページで開きます。整形済みコンテンツがない場合、BBCodeはプレーンテキストで表示されます。';

  @override
  String get contentLinkFailed => 'リンクを開けませんでした。';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profileOverview => '概要';

  @override
  String get profilePpLabel => 'パフォーマンス (PP)';

  @override
  String get profileGlobalRankLabel => '世界ランキング';

  @override
  String get profileCountryRankLabel => '国内ランキング';

  @override
  String get profileStatisticsTitle => '統計';

  @override
  String get profileAccuracyLabel => '精度';

  @override
  String get profilePlayCountLabel => 'プレイ回数';

  @override
  String get profilePlayTimeLabel => 'プレイ時間';

  @override
  String get profileComboLabel => '最大コンボ';

  @override
  String get profileValueUnavailable => 'データなし';

  @override
  String get profileGradesTitle => '成績ランク';

  @override
  String get profileRankedScoreLabel => 'ランクスコア';

  @override
  String get profileTotalScoreLabel => '合計スコア';

  @override
  String get profileTotalHitsLabel => '総ヒット数';

  @override
  String get profileReplaysLabel => '他の人によるリプレイ視聴数';

  @override
  String get profileHistoryTitle => 'ランキング履歴';

  @override
  String get profileHistoryEmpty => 'このモードのランキング履歴はありません。';

  @override
  String get profileHistoryExplanation =>
      'APIの記録順です。日付ではありません。途切れた部分は順位データがありません。';

  @override
  String get profileSwitchingMode => '選択したモードを読み込み中です。前のモードのデータを表示しています。';

  @override
  String get profileUpdateFailed => '更新できませんでした。前のデータとモードを保持しています。';

  @override
  String profileDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString時間$minutesString分';
  }

  @override
  String profileLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'レベル $levelString';
  }

  @override
  String profileLevelProgress(int progress) {
    final intl.NumberFormat progressNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String progressString = progressNumberFormat.format(progress);

    return '次のレベルまでの進捗 $progressString%';
  }

  @override
  String profileHistorySample(int index) {
    final intl.NumberFormat indexNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);

    return '記録 $indexString';
  }

  @override
  String get navigationSearch => '検索';

  @override
  String get navigationUnavailable => 'このページは表示できません。';

  @override
  String get searchClear => '検索をクリア';

  @override
  String get contentImage => '画像';

  @override
  String get contentImageLoading => '画像を読み込み中…';

  @override
  String get contentImageFailed => '画像を読み込めませんでした。画像が利用できないか、サイズまたは形式が対応範囲外です。';

  @override
  String get contentImageOpen => '画像を拡大';

  @override
  String get contentDisclosure => '非表示の内容を表示';

  @override
  String get contentUnsupported => 'この埋め込みコンテンツは元のページで確認できます。';

  @override
  String get contentOriginal => '元のページを開く';

  @override
  String get contentUnavailable => 'リーダーでは表示できません。元のページを開いてください。';

  @override
  String get uiCatalogMedia => '画像とバッジ';

  @override
  String get uiCatalogCards => 'プレイヤーとコンテンツのカード';

  @override
  String get uiCatalogCharts => 'グラフ';

  @override
  String get uiCatalogStates => 'コンテンツの状態';

  @override
  String get uiCatalogSampleNotice =>
      'プレビュー用のデータです。実際のプレイヤー統計ではありません。既存のTracksu画像でレイアウトを示しています。';

  @override
  String get uiCatalogHistory => 'ランキング履歴';

  @override
  String get uiCatalogActivity => 'プレイ履歴';

  @override
  String get uiCatalogSinglePoint => 'データが1件';

  @override
  String get uiCatalogFlatSeries => '変化のない値';

  @override
  String get uiCatalogOffline => '接続なし';

  @override
  String get uiCatalogNoData => 'データはまだありません';

  @override
  String get uiCatalogChartHint =>
      'タップ、ドラッグ、またはスライダーで値を確認できます。順位の数字が小さいほど上に表示されます。';

  @override
  String get uiMetricPerformance => 'パフォーマンスポイント';

  @override
  String get uiMetricAccuracy => '精度';

  @override
  String get uiMetricGlobalRank => '世界ランキング';

  @override
  String get uiMetricPlayCount => 'プレイ回数';

  @override
  String get uiMetricPlayTime => 'プレイ時間';

  @override
  String get uiCatalogTitle => 'UI kit';

  @override
  String get uiCatalogTheme => 'テーマを切り替え';

  @override
  String get uiCatalogTypography => '文字と背景';

  @override
  String get uiCatalogButtons => 'ボタン';

  @override
  String get uiCatalogInputs => '入力と選択';

  @override
  String get uiCatalogFeedback => 'メッセージ';

  @override
  String get uiCatalogNavigation => 'ナビゲーション';

  @override
  String get uiCatalogConfirmMessage => 'これはプレビュー操作の確認です。アカウントやデータは変更されません。';

  @override
  String get newsTitle => 'ニュース';

  @override
  String get newsRefresh => 'ニュースを更新';

  @override
  String get newsEmpty => 'ニュースはありません。';

  @override
  String get newsLoadMore => 'ニュースをさらに読み込む';

  @override
  String get newsLoading => 'ニュースを読み込み中…';

  @override
  String get newsKeepingContent => '読み込み済みの内容を引き続き表示しています。';

  @override
  String get newsNotFound => 'この記事は表示できません。';

  @override
  String get newsCancelled => 'ニュースの読み込みをキャンセルしました。';

  @override
  String get newsAccessDenied => 'ニュースにアクセスできません。';

  @override
  String get newsInvalidResponse => 'ニュースの応答を読み取れませんでした。';

  @override
  String get newsUnavailable => 'ニュースは一時的に利用できません。';

  @override
  String get newsLinkFailed => 'このリンクを開けませんでした。';

  @override
  String get newsOriginal => '元の記事を開く';

  @override
  String get newsReaderNotice =>
      '外部画像は保存された設定に従って読み込まれます。埋め込みコンテンツは元のページで開きます。';

  @override
  String get spotlightsTitle => 'Spotlights';

  @override
  String get spotlightsChoose => 'Spotlightを選択';

  @override
  String get spotlightsShowRanking => '選択したSpotlightを表示';

  @override
  String get spotlightsEmpty => '利用可能なSpotlightはありません。';

  @override
  String get spotlightsMaps => 'ビートマップセット';

  @override
  String get spotlightsNoMaps => 'このSpotlightとゲームモードに対応するビートマップセットはありません。';

  @override
  String get spotlightsRankingLimit => 'Spotlightランキング · 最大40人';

  @override
  String get spotlightsNotFound => 'このSpotlightまたはゲームモードは利用できません。';

  @override
  String get appTitle => 'Tracksu';

  @override
  String get guestModeTitle => 'ゲストモード';

  @override
  String get guestSignedOutDescription =>
      'ゲストとしてosu!の公開データを閲覧できます。ログインするとアカウント機能を利用できます。';

  @override
  String get guestSignedInDescription => 'ログインしています。公開データはアカウントがなくても閲覧できます。';

  @override
  String get signInWithOsu => 'osu!でログイン';

  @override
  String get signInWithAnotherAccount => '別のアカウントでログイン';

  @override
  String get signOut => 'ログアウト';

  @override
  String get signingOut => 'ログアウト中…';

  @override
  String get signOutFailed => 'ログアウトできませんでした。もう一度お試しください。';

  @override
  String get systemLanguage => 'システムの言語';

  @override
  String get englishLanguage => '英語';

  @override
  String get russianLanguage => 'ロシア語';

  @override
  String get loginToOsu => 'osu!にログイン';

  @override
  String get signingIn => 'ログイン中…';

  @override
  String get openingOsu => 'osu!を開いています…';

  @override
  String get continueWithOsu => 'osu!で続行';

  @override
  String get authorizationExpired => 'この認証リクエストは期限切れです。もう一度お試しください。';

  @override
  String get authorizationResponseUnavailable => '認証の応答を受信できませんでした。';

  @override
  String get authorizationResponseMismatch => '認証の応答が今回のログイン試行と一致しません。';

  @override
  String get authorizationCancelled => '認証がキャンセルまたは拒否されました。';

  @override
  String get authorizationResponseInvalid => '認証の応答が無効です。';

  @override
  String get authorizationPreparationFailed => 'osu!認証の準備ができませんでした。';

  @override
  String get authorizationLaunchFailed => 'osu!の認証ページを開けませんでした。';

  @override
  String get authorizationCompletionFailed => '認証を完了できませんでした。';

  @override
  String get authorizationIncomplete => '認証が完了していません。もう一度お試しください。';

  @override
  String get viewMyProfile => '自分のプロフィールを表示';

  @override
  String get profileSearchHint => '正確なユーザー名またはID';

  @override
  String get profileSearchInvalid => '有効なユーザー名または正のIDを入力してください。';

  @override
  String get rulesetOsu => 'osu!';

  @override
  String get rulesetTaiko => 'taiko';

  @override
  String get rulesetFruits => 'catch';

  @override
  String get rulesetMania => 'mania';

  @override
  String get profileLoading => 'プロフィールを読み込み中…';

  @override
  String get profileUnavailable => 'プロフィールを表示できません。もう一度お試しください。';

  @override
  String get retry => '再試行';

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

    return 'パフォーマンス: $ppString';
  }

  @override
  String profileCountry(String country) {
    return '国: $country';
  }

  @override
  String profileAccuracy(double accuracy) {
    final intl.NumberFormat accuracyNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 2,
        );
    final String accuracyString = accuracyNumberFormat.format(accuracy);

    return '精度: $accuracyString%';
  }

  @override
  String profilePlayCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'プレイ回数: $countString';
  }

  @override
  String get profileSearchIntroduction =>
      '正確なユーザー名またはIDでプロフィールを開きます。ログインは不要です。';

  @override
  String get profileSearchHelp =>
      '統計のモードを選び、完全なユーザー名またはIDを入力してボタンを押してください。入力中の候補表示はありません。数字のみの名前には@を付けてください。';

  @override
  String get profileOpen => 'プロフィールを開く';

  @override
  String get profileSearch => 'プレイヤーを検索';

  @override
  String get profileRefreshing => 'プロフィールを更新中';

  @override
  String get profileRefresh => '更新';

  @override
  String get profileShowingPreviousData => '更新できませんでした。読み込み済みのデータを表示しています。';

  @override
  String get profileNotFound => 'プレイヤーが見つかりません。名前またはIDを確認してください。';

  @override
  String get profileAccessDenied =>
      'osu!にアクセスを拒否されました。自分のプロフィールの場合は再ログインをお試しください。';

  @override
  String get profileRateLimited => 'リクエストが多すぎます。しばらく待ってからお試しください。';

  @override
  String get profileConnectionFailed => '接続できません。接続を確認してもう一度お試しください。';

  @override
  String get profileInvalidResponse => 'サーバーから未対応のプロフィール応答が返されました。';

  @override
  String get profileOnline => 'オンライン';

  @override
  String get profileOffline => 'オフライン';

  @override
  String get profileSupporter => 'osu!supporter';

  @override
  String get profileNoStatistics => 'このゲームモードの統計はまだありません。';

  @override
  String get profileUnranked => '世界ランクなし';

  @override
  String profileGlobalRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return '世界ランク: #$rankString';
  }

  @override
  String profileCountryRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return '国内ランク: #$rankString';
  }

  @override
  String profilePlayTime(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return 'プレイ時間: $hoursString時間';
  }

  @override
  String profileMaximumCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return '最大コンボ: $comboString';
  }

  @override
  String get languageChangeFailed => '言語を保存できませんでした。';

  @override
  String get languageSelection => '言語';

  @override
  String get account => 'アカウント';

  @override
  String get scoresTitle => 'スコア';

  @override
  String get scoresBest => 'ベスト';

  @override
  String get scoresRecent => '最近';

  @override
  String get scoresRefresh => 'スコアを更新';

  @override
  String get scoresLoading => 'スコアを読み込み中…';

  @override
  String get scoresEmpty => 'このプレイヤーとゲームモードのスコアはありません。';

  @override
  String get scoresLoadMore => 'さらに読み込む';

  @override
  String get scoresKeepingContent => '読み込み済みのスコアを引き続き表示しています。';

  @override
  String get scoresCancelled => '読み込みをキャンセルしました。';

  @override
  String get scoresNotFound => 'スコアが見つかりませんでした。';

  @override
  String get scoresAccessDenied => 'osu!にスコアへのアクセスを拒否されました。';

  @override
  String get scoresInvalidResponse => 'サーバーから未対応のスコア応答が返されました。';

  @override
  String get scoresUnavailable => 'スコアは一時的に利用できません。';

  @override
  String get scoresNoMods => 'Modなし';

  @override
  String get scoresNoPp => 'PPなし';

  @override
  String get scoresFailedPlay => 'クリア失敗';

  @override
  String scoresBeatmap(int id) {
    return 'ビートマップ #$id';
  }

  @override
  String scoresGrade(String grade) {
    return 'ランク: $grade';
  }

  @override
  String scoresCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'コンボ: $comboString';
  }

  @override
  String scoresTotal(int total) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'スコア: $totalString';
  }

  @override
  String scoresMods(String mods) {
    return 'Mod: $mods';
  }

  @override
  String scoresPlayedAt(String date) {
    return 'プレイ日時: $date';
  }

  @override
  String get beatmapsTitle => 'ビートマップ';

  @override
  String get beatmapsMostPlayed => 'よくプレイしたマップ';

  @override
  String get beatmapsFavourite => 'お気に入り';

  @override
  String get beatmapsRanked => 'Ranked';

  @override
  String get beatmapsPending => 'Pending';

  @override
  String get beatmapsGraveyard => 'Graveyard';

  @override
  String get beatmapsLoved => 'Loved';

  @override
  String get beatmapsGuest => 'ゲスト難易度';

  @override
  String get beatmapsNominated => 'ノミネート済み';

  @override
  String get beatmapsRefresh => 'ビートマップを更新';

  @override
  String get beatmapsEmpty => 'このカテゴリにビートマップはありません。';

  @override
  String get beatmapsLoadMore => 'ビートマップをさらに読み込む';

  @override
  String get beatmapsLoading => 'ビートマップを読み込み中…';

  @override
  String get beatmapsKeepingContent => '更新できませんでした。読み込み済みのビートマップを引き続き表示しています。';

  @override
  String get beatmapsCancelled => '読み込みをキャンセルしました。';

  @override
  String get beatmapsNotFound => 'このプレイヤーのビートマップが見つかりませんでした。';

  @override
  String get beatmapsAccessDenied => '現在ビートマップにアクセスできません。';

  @override
  String get beatmapsInvalidResponse => 'サーバーから予期しないビートマップ応答が返されました。';

  @override
  String get beatmapsUnavailable => 'ビートマップを読み込めませんでした。もう一度お試しください。';

  @override
  String beatmapsSetFallback(int id) {
    return 'ビートマップセット #$id';
  }

  @override
  String beatmapsMapFallback(int id) {
    return 'ビートマップ #$id';
  }

  @override
  String beatmapsPlayCount(int count) {
    return 'このプレイヤーのプレイ回数: $count';
  }

  @override
  String get beatmapTitle => 'ビートマップ';

  @override
  String get beatmapNotFound => 'ビートマップが見つかりません。';

  @override
  String get beatmapAccessDenied => 'このビートマップまたはランキングにアクセスできません。';

  @override
  String get beatmapInvalidResponse => '予期しないビートマップ応答です。';

  @override
  String get beatmapUnavailable => 'ビートマップのデータを読み込めませんでした。';

  @override
  String get beatmapLeaderboard => 'トップスコア';

  @override
  String get beatmapRefreshLeaderboard => 'スコアを更新';

  @override
  String get beatmapNoScores => 'スコアはありません。';

  @override
  String beatmapLeaderboardPlayer(int position, String name) {
    return '#$position · $name';
  }

  @override
  String beatmapPlayerId(int id) {
    return 'プレイヤー #$id';
  }

  @override
  String beatmapCreator(String name) {
    return '作成者: $name';
  }

  @override
  String get beatmapRefresh => 'ビートマップを更新';

  @override
  String get beatmapDifficulties => '難易度';

  @override
  String get beatmapNoDifficulties => '選択できる難易度はありません。';

  @override
  String beatmapDifficultyInfo(String mode, double stars, int seconds) {
    return '$mode · $stars ★ · $seconds秒';
  }

  @override
  String get rankingsTitle => 'ランキング';

  @override
  String get rankingsScore => 'スコア';

  @override
  String get rankingsRefresh => 'ランキングを更新';

  @override
  String get rankingsEmpty => 'プレイヤーが見つかりませんでした。';

  @override
  String get rankingsLoadMore => 'プレイヤーをさらに読み込む';

  @override
  String get rankingsLoading => 'ランキングを読み込み中…';

  @override
  String get rankingsKeepingContent => '更新できませんでした。読み込み済みのランキングを表示しています。';

  @override
  String get rankingsCancelled => '読み込みをキャンセルしました。';

  @override
  String get rankingsNotFound => 'ランキングが見つかりません。';

  @override
  String get rankingsAccessDenied => 'ランキングにアクセスできません。';

  @override
  String get rankingsInvalidResponse => '予期しないランキング応答です。';

  @override
  String get rankingsUnavailable => 'ランキングを読み込めませんでした。';

  @override
  String rankingsRankedScore(int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'ランクスコア: $scoreString';
  }

  @override
  String get rankingsCountry => '国コード';

  @override
  String get rankingsCountryInvalid => '2文字の国コードを入力してください。';

  @override
  String get rankingsWorldwide => '全世界';

  @override
  String get rankingsAllKeys => 'すべてのキー数';

  @override
  String get germanLanguage => 'ドイツ語';

  @override
  String get frenchLanguage => 'フランス語';

  @override
  String get spanishLanguage => 'スペイン語';

  @override
  String get japaneseLanguage => '日本語';

  @override
  String get chineseLanguage => '中国語（簡体字）';
}
