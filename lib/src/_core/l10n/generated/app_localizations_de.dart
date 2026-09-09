// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSignOutConfirm =>
      'Auf diesem Gerät abmelden? Dein öffentliches osu!-Profil bleibt verfügbar.';

  @override
  String get medalsLoading => 'Medaillen werden geladen…';

  @override
  String get medalsFailed =>
      'Medaillendetails konnten nicht von osu! geladen werden. Bitte erneut versuchen.';

  @override
  String get medalsEmpty => 'Noch keine Medaillen erhalten.';

  @override
  String get scoreMiss => 'MISS';

  @override
  String get scoreFruit => 'Früchte';

  @override
  String get scoreDroplet => 'Tropfen';

  @override
  String get scoreTinyDroplet => 'Kleine Tropfen';

  @override
  String get scoreTinyMiss => 'Verpasste kleine Tropfen';

  @override
  String get scoreJudgementPercentNotice =>
      'Prozente beziehen sich auf die hier gezeigten Trefferwertungen, nicht auf Kartenfortschritt oder Maximalkombo. Slider-Ticks und technische Legacy-Zähler sind ausgeschlossen.';

  @override
  String get profilePreviousNames => 'Frühere Namen';

  @override
  String get profileGroups => 'Gruppen';

  @override
  String profileTeamTag(String tag) {
    return 'Team · $tag';
  }

  @override
  String get profileMedals => 'Medaillen';

  @override
  String get profileMedalsView => 'Erhaltene Medaillen';

  @override
  String profileMedalId(int id) {
    return 'Medaille #$id';
  }

  @override
  String get profileRankedPlay => 'Ranglistenspiel';

  @override
  String get profileRankedPlayEmpty =>
      'Keine Ranglistenspiel-Statistik für diesen Modus.';

  @override
  String profileRankedPool(int id) {
    return 'Pool #$id';
  }

  @override
  String get profileProvisionalRating => 'Vorläufige Wertung';

  @override
  String get profileRating => 'Wertung';

  @override
  String get profileFirstPlaces => 'Erste Plätze';

  @override
  String get profileRankedPoints => 'Matchpunkte';

  @override
  String get profileDailyChallenge => 'Tägliche Herausforderung';

  @override
  String get profileDailyPlays => 'Gespielte Herausforderungen';

  @override
  String get profileDailyCurrent => 'Aktuelle Tages-Serie';

  @override
  String get profileDailyBest => 'Beste Tages-Serie';

  @override
  String get profileWeeklyCurrent => 'Aktuelle Wochen-Serie';

  @override
  String get profileWeeklyBest => 'Beste Wochen-Serie';

  @override
  String get profileTop10 => 'Top-10%-Platzierungen';

  @override
  String get profileTop50 => 'Top-50%-Platzierungen';

  @override
  String profileDailyUpdated(String date) {
    return 'Letzte Teilnahme: $date';
  }

  @override
  String profileWeeklyUpdated(String date) {
    return 'Letzte Wochen-Serie: $date';
  }

  @override
  String get shareSystem => 'Weitere Apps…';

  @override
  String get shareCopy => 'Link kopieren';

  @override
  String get shareCopied => 'Link kopiert';

  @override
  String get shareDestinationNotice =>
      'Wähle den Empfänger in der geöffneten App oder im Browser. Nichts wird automatisch veröffentlicht. Der Link führt zur öffentlichen osu!-Seite; Vorschauen hängen von der Ziel-App ab.';

  @override
  String get shareAction => 'Teilen';

  @override
  String get shareBeatmapAction => 'Beatmap teilen';

  @override
  String get shareFailed =>
      'Das Teilen-Menü konnte nicht geöffnet werden. Versuche es erneut.';

  @override
  String get contentMediaSettings => 'Externe Bilder';

  @override
  String get contentMediaConsent =>
      'Bilder in Profilen, Beatmap-Beschreibungen und Nachrichten werden von externen Servern geladen. Diese erhalten deine IP-Adresse und können Anfragen protokollieren. Die Auswahl gilt auf diesem Gerät für alle solchen Bilder und lässt sich im Kontomenü ändern. Avatare und Beatmap-Cover von osu! werden separat geladen.';

  @override
  String get contentMediaAllow => 'Bilder erlauben';

  @override
  String get contentMediaDecline => 'Jetzt nicht';

  @override
  String get contentMediaDisabled =>
      'Externe Bilder sind deaktiviert. Du kannst sie im Kontomenü aktivieren.';

  @override
  String get contentMediaSaveFailed =>
      'Die Einstellung konnte nicht gespeichert werden und kann nach einem Neustart zurückgesetzt sein.';

  @override
  String get contentImageUnsupported =>
      'Diese Bildadresse wird nicht unterstützt. Öffne die Originalseite.';

  @override
  String get profilePlayHistoryTitle => 'Spiele pro Monat';

  @override
  String rankingsPosition(int position) {
    final intl.NumberFormat positionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String positionString = positionNumberFormat.format(position);

    return 'Platz #$positionString';
  }

  @override
  String get rankingsPositionNotice =>
      'Die Plätze gelten für diese gefilterte Tabelle, nicht für den globalen PP-Rang. Zwischen Seitenabrufen kann sich die Rangliste ändern; aktualisiere sie.';

  @override
  String get rankingsCountrySelection => 'Land oder Region';

  @override
  String get rankingsCountrySearch => 'Ländername oder Code';

  @override
  String get rankingsCountryCatalogHint =>
      'Suche nach englischem Namen oder zweistelligem Code. Einige Einträge zeigen nur den Code. Die Verfügbarkeit der Rangliste hängt von osu! ab.';

  @override
  String get rankingsCountryCatalogFailed =>
      'Die Länderliste konnte nicht geladen werden.';

  @override
  String get rankingsCountryNoMatch => 'Keine passenden Länder.';

  @override
  String get rankingsEnd => 'Ende der verfügbaren Rangliste.';

  @override
  String get scoreHitsTitle => 'Treffergebnisse';

  @override
  String get scoreHitsExplanation =>
      'Die Namen entsprechen der API. Fehlende Werte sind nicht null; Maximalwerte beziehen sich auf einen perfekten Durchlauf, nicht auf Ziele pro Zeile.';

  @override
  String get scoreHitsAchieved => 'Erreicht';

  @override
  String get scoreHitsMaximum => 'Bei perfektem Durchlauf';

  @override
  String get scoreModSettingsTitle => 'Mod-Einstellungen';

  @override
  String get scoreModSettingsExplanation =>
      'Die Parameternamen entsprechen der API. Nur übermittelte Einstellungen werden angezeigt; Standardwerte werden nicht angenommen.';

  @override
  String get scoreNoModSettings =>
      'Keine expliziten Einstellungen übermittelt.';

  @override
  String get scoreDetailsUnavailable => 'Nicht verfügbar';

  @override
  String get scoreSettingEnabled => 'Aktiviert';

  @override
  String get scoreSettingDisabled => 'Deaktiviert';

  @override
  String get beatmapDescription => 'Beatmap-Beschreibung';

  @override
  String get contentPageUnavailable =>
      'Dieser Inhalt kann hier nicht angezeigt werden. Das Original kann geöffnet werden.';

  @override
  String get scoreDetailsTitle => 'Ergebnisdetails';

  @override
  String get scoreOpenBeatmap => 'Beatmap öffnen';

  @override
  String get scoreStandardisedTotal => 'Standardisierte Punktzahl';

  @override
  String get mapSetPlays => 'Set-Spielanzahl';

  @override
  String get mapFavourites => 'Favoriten';

  @override
  String get mapBpm => 'BPM';

  @override
  String get profileReplayHistoryTitle => 'Replay-Aufrufe pro Monat';

  @override
  String get profileReplayHistoryExplanation =>
      'Monate ohne Beobachtungen fehlen; fehlende Daten bedeuten nicht null.';

  @override
  String get profileAbout => 'Über mich';

  @override
  String get contentPageNotice =>
      'Externe Bilder folgen deiner gespeicherten Einstellung. Einbettungen öffnen sich nur im Original. Fehlen aufbereitete Inhalte, wird BBCode als Klartext angezeigt.';

  @override
  String get contentLinkFailed => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileOverview => 'Übersicht';

  @override
  String get profilePpLabel => 'Leistung (PP)';

  @override
  String get profileGlobalRankLabel => 'Weltrang';

  @override
  String get profileCountryRankLabel => 'Länderrang';

  @override
  String get profileStatisticsTitle => 'Statistik';

  @override
  String get profileAccuracyLabel => 'Genauigkeit';

  @override
  String get profilePlayCountLabel => 'Spielanzahl';

  @override
  String get profilePlayTimeLabel => 'Spielzeit';

  @override
  String get profileComboLabel => 'Maximale Kombo';

  @override
  String get profileValueUnavailable => 'Nicht verfügbar';

  @override
  String get profileGradesTitle => 'Ergebnisnoten';

  @override
  String get profileRankedScoreLabel => 'Ranglistenpunkte';

  @override
  String get profileTotalScoreLabel => 'Gesamtpunktzahl';

  @override
  String get profileTotalHitsLabel => 'Gesamttreffer';

  @override
  String get profileReplaysLabel => 'Replay-Aufrufe anderer';

  @override
  String get profileHistoryTitle => 'Rangverlauf';

  @override
  String get profileHistoryEmpty => 'Kein Rangverlauf für diesen Modus.';

  @override
  String get profileHistoryExplanation =>
      'API-Messwerte in Reihenfolge, keine Kalenderdaten. Lücken bedeuten fehlende Ränge.';

  @override
  String get profileSwitchingMode =>
      'Modus wird geladen. Die Daten des vorherigen Modus bleiben sichtbar.';

  @override
  String get profileUpdateFailed =>
      'Aktualisierung fehlgeschlagen. Bisherige Daten und Modus bleiben erhalten.';

  @override
  String profileDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString Std. $minutesString Min.';
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

    return '$progressString% zum nächsten Level';
  }

  @override
  String profileHistorySample(int index) {
    final intl.NumberFormat indexNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);

    return 'Messwert $indexString';
  }

  @override
  String get navigationSearch => 'Suche';

  @override
  String get navigationUnavailable => 'Diese Seite ist nicht verfügbar.';

  @override
  String get searchClear => 'Suche löschen';

  @override
  String get contentImage => 'Bild';

  @override
  String get contentImageLoading => 'Bild wird geladen…';

  @override
  String get contentImageFailed =>
      'Das Bild konnte nicht geladen werden. Es ist möglicherweise nicht verfügbar oder überschreitet die unterstützte Größe bzw. das Format.';

  @override
  String get contentImageOpen => 'Bild vergrößern';

  @override
  String get contentDisclosure => 'Verborgenen Inhalt anzeigen';

  @override
  String get contentUnsupported =>
      'Dieser eingebettete Inhalt ist auf der Originalseite verfügbar.';

  @override
  String get contentOriginal => 'Original öffnen';

  @override
  String get contentUnavailable =>
      'Inhalt in der Leseansicht nicht verfügbar. Öffne das Original.';

  @override
  String get uiCatalogMedia => 'Bilder und Abzeichen';

  @override
  String get uiCatalogCards => 'Spieler- und Inhaltskarten';

  @override
  String get uiCatalogCharts => 'Diagramme';

  @override
  String get uiCatalogStates => 'Inhaltszustände';

  @override
  String get uiCatalogSampleNotice =>
      'Nur Beispieldaten, keine aktuellen Spielerstatistiken. Vorhandene Tracksu-Grafiken zeigen das Bildlayout.';

  @override
  String get uiCatalogHistory => 'Rangverlauf';

  @override
  String get uiCatalogActivity => 'Spielaktivität';

  @override
  String get uiCatalogSinglePoint => 'Ein Datenpunkt';

  @override
  String get uiCatalogFlatSeries => 'Unveränderte Werte';

  @override
  String get uiCatalogOffline => 'Keine Verbindung';

  @override
  String get uiCatalogNoData => 'Noch keine Daten';

  @override
  String get uiCatalogChartHint =>
      'Tippen, ziehen oder den Regler nutzen, um einen Wert anzuzeigen. Kleinere Rangnummern stehen höher.';

  @override
  String get uiMetricPerformance => 'Leistungspunkte';

  @override
  String get uiMetricAccuracy => 'Genauigkeit';

  @override
  String get uiMetricGlobalRank => 'Weltrang';

  @override
  String get uiMetricPlayCount => 'Spielanzahl';

  @override
  String get uiMetricPlayTime => 'Spielzeit';

  @override
  String get uiCatalogTitle => 'UI kit';

  @override
  String get uiCatalogTheme => 'Design wechseln';

  @override
  String get uiCatalogTypography => 'Typografie und Oberflächen';

  @override
  String get uiCatalogButtons => 'Schaltflächen';

  @override
  String get uiCatalogInputs => 'Eingabe und Auswahl';

  @override
  String get uiCatalogFeedback => 'Rückmeldungen';

  @override
  String get uiCatalogNavigation => 'Navigation';

  @override
  String get uiCatalogConfirmMessage =>
      'Dies bestätigt nur eine Vorschauaktion. Konto und Daten bleiben unverändert.';

  @override
  String get newsTitle => 'Neuigkeiten';

  @override
  String get newsRefresh => 'Neuigkeiten aktualisieren';

  @override
  String get newsEmpty => 'Keine Neuigkeiten verfügbar.';

  @override
  String get newsLoadMore => 'Weitere Neuigkeiten laden';

  @override
  String get newsLoading => 'Neuigkeiten werden geladen…';

  @override
  String get newsKeepingContent =>
      'Bereits geladene Inhalte werden weiterhin angezeigt.';

  @override
  String get newsNotFound => 'Dieser Beitrag ist nicht verfügbar.';

  @override
  String get newsCancelled => 'Das Laden der Neuigkeiten wurde abgebrochen.';

  @override
  String get newsAccessDenied => 'Kein Zugriff auf Neuigkeiten.';

  @override
  String get newsInvalidResponse =>
      'Die Antwort mit den Neuigkeiten konnte nicht gelesen werden.';

  @override
  String get newsUnavailable =>
      'Neuigkeiten sind vorübergehend nicht verfügbar.';

  @override
  String get newsLinkFailed => 'Dieser Link konnte nicht geöffnet werden.';

  @override
  String get newsOriginal => 'Original öffnen';

  @override
  String get newsReaderNotice =>
      'Externe Bilder folgen deiner gespeicherten Einstellung. Einbettungen öffnen sich nur im Original.';

  @override
  String get spotlightsTitle => 'Spotlights';

  @override
  String get spotlightsChoose => 'Spotlight auswählen';

  @override
  String get spotlightsShowRanking => 'Ausgewähltes Spotlight anzeigen';

  @override
  String get spotlightsEmpty => 'Keine Spotlights verfügbar.';

  @override
  String get spotlightsMaps => 'Beatmap-Sets';

  @override
  String get spotlightsNoMaps =>
      'Keine Beatmap-Sets für dieses Spotlight und diesen Spielmodus.';

  @override
  String get spotlightsRankingLimit =>
      'Spotlight-Rangliste · bis zu 40 Spieler';

  @override
  String get spotlightsNotFound =>
      'Dieses Spotlight oder dieser Spielmodus ist nicht verfügbar.';

  @override
  String get appTitle => 'Tracksu';

  @override
  String get guestModeTitle => 'Gastmodus';

  @override
  String get guestSignedOutDescription =>
      'Öffentliche osu!-Daten als Gast ansehen. Melde dich an, um Kontofunktionen zu nutzen.';

  @override
  String get guestSignedInDescription =>
      'Du bist angemeldet. Öffentliche Inhalte sind auch ohne Konto zugänglich.';

  @override
  String get signInWithOsu => 'Mit osu! anmelden';

  @override
  String get signInWithAnotherAccount => 'Mit einem anderen Konto anmelden';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signingOut => 'Abmeldung läuft…';

  @override
  String get signOutFailed => 'Abmeldung fehlgeschlagen. Versuche es erneut.';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String get englishLanguage => 'Englisch';

  @override
  String get russianLanguage => 'Russisch';

  @override
  String get loginToOsu => 'Bei osu! anmelden';

  @override
  String get signingIn => 'Anmeldung läuft…';

  @override
  String get openingOsu => 'osu! wird geöffnet…';

  @override
  String get continueWithOsu => 'Mit osu! fortfahren';

  @override
  String get authorizationExpired =>
      'Diese Anmeldeanfrage ist abgelaufen. Versuche es erneut.';

  @override
  String get authorizationResponseUnavailable =>
      'Die Antwort auf die Anmeldeanfrage konnte nicht empfangen werden.';

  @override
  String get authorizationResponseMismatch =>
      'Die Antwort passt nicht zu diesem Anmeldeversuch.';

  @override
  String get authorizationCancelled =>
      'Die Autorisierung wurde abgebrochen oder verweigert.';

  @override
  String get authorizationResponseInvalid =>
      'Die Autorisierungsantwort ist ungültig.';

  @override
  String get authorizationPreparationFailed =>
      'Die osu!-Anmeldung konnte nicht vorbereitet werden.';

  @override
  String get authorizationLaunchFailed =>
      'Die osu!-Anmeldung konnte nicht geöffnet werden.';

  @override
  String get authorizationCompletionFailed =>
      'Die Anmeldung konnte nicht abgeschlossen werden.';

  @override
  String get authorizationIncomplete =>
      'Die Anmeldung wurde nicht abgeschlossen. Versuche es erneut.';

  @override
  String get viewMyProfile => 'Mein Profil anzeigen';

  @override
  String get profileSearchHint => 'Exakter Benutzername oder ID';

  @override
  String get profileSearchInvalid =>
      'Gib einen gültigen Benutzernamen oder eine positive ID ein.';

  @override
  String get rulesetOsu => 'osu!';

  @override
  String get rulesetTaiko => 'taiko';

  @override
  String get rulesetFruits => 'catch';

  @override
  String get rulesetMania => 'mania';

  @override
  String get profileLoading => 'Profil wird geladen…';

  @override
  String get profileUnavailable =>
      'Profil nicht verfügbar. Versuche es erneut.';

  @override
  String get retry => 'Erneut versuchen';

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

    return 'Leistung: $ppString';
  }

  @override
  String profileCountry(String country) {
    return 'Land: $country';
  }

  @override
  String profileAccuracy(double accuracy) {
    final intl.NumberFormat accuracyNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 2,
        );
    final String accuracyString = accuracyNumberFormat.format(accuracy);

    return 'Genauigkeit: $accuracyString %';
  }

  @override
  String profilePlayCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Spielanzahl: $countString';
  }

  @override
  String get profileSearchIntroduction =>
      'Öffne ein Spielerprofil mit dem exakten Benutzernamen oder der ID. Keine Anmeldung nötig.';

  @override
  String get profileSearchHelp =>
      'Wähle den Statistikmodus, gib den vollständigen Namen oder die ID ein und bestätige. Keine Vorschläge beim Tippen. Für numerische Namen: @.';

  @override
  String get profileOpen => 'Profil öffnen';

  @override
  String get profileSearch => 'Spieler suchen';

  @override
  String get profileRefreshing => 'Profil wird aktualisiert';

  @override
  String get profileRefresh => 'Aktualisieren';

  @override
  String get profileShowingPreviousData =>
      'Aktualisierung fehlgeschlagen. Bereits geladene Daten werden angezeigt.';

  @override
  String get profileNotFound =>
      'Spieler nicht gefunden. Prüfe den Namen oder die ID.';

  @override
  String get profileAccessDenied =>
      'osu! hat den Zugriff verweigert. Melde dich für dein eigenes Profil erneut an.';

  @override
  String get profileRateLimited =>
      'Zu viele Anfragen. Warte, bevor du es erneut versuchst.';

  @override
  String get profileConnectionFailed =>
      'Keine Verbindung möglich. Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get profileInvalidResponse =>
      'Der Server hat eine nicht unterstützte Profilantwort gesendet.';

  @override
  String get profileOnline => 'Online';

  @override
  String get profileOffline => 'Offline';

  @override
  String get profileSupporter => 'osu!supporter';

  @override
  String get profileNoStatistics =>
      'Noch keine Statistiken für diesen Spielmodus.';

  @override
  String get profileUnranked => 'Kein globaler Rang';

  @override
  String profileGlobalRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Weltrang: #$rankString';
  }

  @override
  String profileCountryRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Landesrang: #$rankString';
  }

  @override
  String profilePlayTime(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return 'Spielzeit: $hoursString Std.';
  }

  @override
  String profileMaximumCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'Höchste Combo: $comboString';
  }

  @override
  String get languageChangeFailed =>
      'Die Sprache konnte nicht gespeichert werden.';

  @override
  String get languageSelection => 'Sprache';

  @override
  String get account => 'Konto';

  @override
  String get scoresTitle => 'Ergebnisse';

  @override
  String get scoresBest => 'Beste';

  @override
  String get scoresRecent => 'Neueste';

  @override
  String get scoresRefresh => 'Ergebnisse aktualisieren';

  @override
  String get scoresLoading => 'Ergebnisse werden geladen…';

  @override
  String get scoresEmpty =>
      'Keine Ergebnisse für diesen Spieler und Spielmodus.';

  @override
  String get scoresLoadMore => 'Mehr laden';

  @override
  String get scoresKeepingContent =>
      'Bereits geladene Ergebnisse werden weiterhin angezeigt.';

  @override
  String get scoresCancelled => 'Das Laden wurde abgebrochen.';

  @override
  String get scoresNotFound => 'Ergebnisse konnten nicht gefunden werden.';

  @override
  String get scoresAccessDenied =>
      'osu! hat den Zugriff auf Ergebnisse verweigert.';

  @override
  String get scoresInvalidResponse =>
      'Der Server hat eine nicht unterstützte Ergebnisantwort gesendet.';

  @override
  String get scoresUnavailable =>
      'Ergebnisse sind vorübergehend nicht verfügbar.';

  @override
  String get scoresNoMods => 'Keine Mods';

  @override
  String get scoresNoPp => 'PP nicht verfügbar';

  @override
  String get scoresFailedPlay => 'Nicht bestanden';

  @override
  String scoresBeatmap(int id) {
    return 'Beatmap #$id';
  }

  @override
  String scoresGrade(String grade) {
    return 'Bewertung: $grade';
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

    return 'Punktzahl: $totalString';
  }

  @override
  String scoresMods(String mods) {
    return 'Mods: $mods';
  }

  @override
  String scoresPlayedAt(String date) {
    return 'Gespielt: $date';
  }

  @override
  String get beatmapsTitle => 'Beatmaps';

  @override
  String get beatmapsMostPlayed => 'Meistgespielt';

  @override
  String get beatmapsFavourite => 'Favoriten';

  @override
  String get beatmapsRanked => 'Ranked';

  @override
  String get beatmapsPending => 'Ausstehend';

  @override
  String get beatmapsGraveyard => 'Friedhof';

  @override
  String get beatmapsLoved => 'Loved';

  @override
  String get beatmapsGuest => 'Gast-Schwierigkeiten';

  @override
  String get beatmapsNominated => 'Nominiert';

  @override
  String get beatmapsRefresh => 'Beatmaps aktualisieren';

  @override
  String get beatmapsEmpty => 'Keine Beatmaps in dieser Kategorie.';

  @override
  String get beatmapsLoadMore => 'Weitere Beatmaps laden';

  @override
  String get beatmapsLoading => 'Beatmaps werden geladen…';

  @override
  String get beatmapsKeepingContent =>
      'Aktualisierung fehlgeschlagen. Bereits geladene Beatmaps werden weiterhin angezeigt.';

  @override
  String get beatmapsCancelled => 'Das Laden wurde abgebrochen.';

  @override
  String get beatmapsNotFound =>
      'Die Beatmaps dieses Spielers konnten nicht gefunden werden.';

  @override
  String get beatmapsAccessDenied => 'Beatmaps sind derzeit nicht zugänglich.';

  @override
  String get beatmapsInvalidResponse =>
      'Der Server hat eine unerwartete Beatmap-Antwort gesendet.';

  @override
  String get beatmapsUnavailable =>
      'Beatmaps konnten nicht geladen werden. Versuche es erneut.';

  @override
  String beatmapsSetFallback(int id) {
    return 'Beatmap-Set #$id';
  }

  @override
  String beatmapsMapFallback(int id) {
    return 'Beatmap #$id';
  }

  @override
  String beatmapsPlayCount(int count) {
    return 'Spiele dieses Spielers: $count';
  }

  @override
  String get beatmapTitle => 'Beatmap';

  @override
  String get beatmapNotFound => 'Beatmap nicht gefunden.';

  @override
  String get beatmapAccessDenied =>
      'Diese Beatmap oder Rangliste ist nicht zugänglich.';

  @override
  String get beatmapInvalidResponse => 'Unerwartete Beatmap-Antwort.';

  @override
  String get beatmapUnavailable =>
      'Beatmap-Daten konnten nicht geladen werden.';

  @override
  String get beatmapLeaderboard => 'Beste Ergebnisse';

  @override
  String get beatmapRefreshLeaderboard => 'Ergebnisse aktualisieren';

  @override
  String get beatmapNoScores => 'Keine Ergebnisse verfügbar.';

  @override
  String beatmapLeaderboardPlayer(int position, String name) {
    return '#$position · $name';
  }

  @override
  String beatmapPlayerId(int id) {
    return 'Spieler #$id';
  }

  @override
  String beatmapCreator(String name) {
    return 'Erstellt von $name';
  }

  @override
  String get beatmapRefresh => 'Beatmap aktualisieren';

  @override
  String get beatmapDifficulties => 'Schwierigkeitsgrade';

  @override
  String get beatmapNoDifficulties => 'Keine Schwierigkeitsgrade verfügbar.';

  @override
  String beatmapDifficultyInfo(String mode, double stars, int seconds) {
    return '$mode · $stars ★ · $seconds s';
  }

  @override
  String get rankingsTitle => 'Ranglisten';

  @override
  String get rankingsScore => 'Punktzahl';

  @override
  String get rankingsRefresh => 'Rangliste aktualisieren';

  @override
  String get rankingsEmpty => 'Keine Spieler gefunden.';

  @override
  String get rankingsLoadMore => 'Weitere Spieler laden';

  @override
  String get rankingsLoading => 'Rangliste wird geladen…';

  @override
  String get rankingsKeepingContent =>
      'Aktualisierung fehlgeschlagen. Die bisherige Rangliste wird angezeigt.';

  @override
  String get rankingsCancelled => 'Laden abgebrochen.';

  @override
  String get rankingsNotFound => 'Rangliste nicht gefunden.';

  @override
  String get rankingsAccessDenied => 'Rangliste nicht zugänglich.';

  @override
  String get rankingsInvalidResponse => 'Unerwartete Ranglistenantwort.';

  @override
  String get rankingsUnavailable => 'Rangliste konnte nicht geladen werden.';

  @override
  String rankingsRankedScore(int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Ranked-Punktzahl: $scoreString';
  }

  @override
  String get rankingsCountry => 'Ländercode';

  @override
  String get rankingsCountryInvalid =>
      'Gib einen Ländercode aus zwei Buchstaben ein.';

  @override
  String get rankingsWorldwide => 'Weltweit';

  @override
  String get rankingsAllKeys => 'Alle Tastenanzahlen';

  @override
  String get germanLanguage => 'Deutsch';

  @override
  String get frenchLanguage => 'Französisch';

  @override
  String get spanishLanguage => 'Spanisch';

  @override
  String get japaneseLanguage => 'Japanisch';

  @override
  String get chineseLanguage => 'Chinesisch (vereinfacht)';
}
