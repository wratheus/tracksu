// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

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
  String get newsReaderNotice => 'テキスト表示モードです。画像、メディア、元の書式はosu!のウェブサイトで確認できます。';

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
  String get profileTitle => 'プロフィール';

  @override
  String get profileSearchHint => 'ユーザー名またはID';

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
          decimalDigits: 2,
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
      'osu!プレイヤーを検索してプロフィールや統計を閲覧できます。ログインは不要です。';

  @override
  String get profileSearchHelp => '数字のみのユーザー名には先頭に@を付けてください。';

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
    return 'プレイ回数: $count';
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
    return 'ランクスコア: $score';
  }

  @override
  String get rankingsCountry => '国コード';

  @override
  String get rankingsCountryHint => 'JPやUSなどの2文字を入力。空欄の場合は全世界が対象です。';

  @override
  String get rankingsCountryInvalid => '2文字の国コードを入力してください。';

  @override
  String get rankingsApply => '国を適用';

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
