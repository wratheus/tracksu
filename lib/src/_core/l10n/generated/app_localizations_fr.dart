// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get profilePreviousNames => 'Anciens pseudos';

  @override
  String get profileGroups => 'Groupes';

  @override
  String profileTeamTag(String tag) {
    return 'Équipe · $tag';
  }

  @override
  String get profileMedals => 'Médailles';

  @override
  String get profileMedalsView => 'Voir les médailles obtenues';

  @override
  String get profileMedalMetadataNotice =>
      'L’API du profil fournit les identifiants et dates d’obtention, mais pas les noms ni les images des médailles. Consultez la collection illustrée sur osu!.';

  @override
  String profileMedalId(int id) {
    return 'Médaille n°$id';
  }

  @override
  String get profileRankedPlay => 'Jeu classé';

  @override
  String get profileRankedPlayEmpty =>
      'Aucune statistique de jeu classé pour ce mode.';

  @override
  String profileRankedPool(int id) {
    return 'Pool n°$id';
  }

  @override
  String get profileProvisionalRating => 'Classement provisoire';

  @override
  String get profileRating => 'Évaluation';

  @override
  String get profileFirstPlaces => 'Premières places';

  @override
  String get profileRankedPoints => 'Points de match';

  @override
  String get profileDailyChallenge => 'Défi quotidien';

  @override
  String get profileDailyPlays => 'Défis joués';

  @override
  String get profileDailyCurrent => 'Série quotidienne actuelle';

  @override
  String get profileDailyBest => 'Meilleure série quotidienne';

  @override
  String get profileWeeklyCurrent => 'Série hebdomadaire actuelle';

  @override
  String get profileWeeklyBest => 'Meilleure série hebdomadaire';

  @override
  String get profileTop10 => 'Résultats dans le top 10 %';

  @override
  String get profileTop50 => 'Résultats dans le top 50 %';

  @override
  String profileDailyUpdated(String date) {
    return 'Dernière participation : $date';
  }

  @override
  String profileWeeklyUpdated(String date) {
    return 'Dernière série hebdomadaire : $date';
  }

  @override
  String get shareSystem => 'Autres applications…';

  @override
  String get shareCopy => 'Copier le lien';

  @override
  String get shareCopied => 'Lien copié';

  @override
  String get shareDestinationNotice =>
      'Choisissez le destinataire dans l’application ou le navigateur qui s’ouvre. Rien n’est publié automatiquement. Le lien mène à la page publique osu! ; l’aperçu dépend de l’application destinataire.';

  @override
  String get shareAction => 'Partager';

  @override
  String get shareBeatmapAction => 'Partager la beatmap';

  @override
  String get shareFailed =>
      'Impossible d’ouvrir le menu de partage. Réessayez.';

  @override
  String get contentMediaSettings => 'Images externes';

  @override
  String get contentMediaConsent =>
      'Les images des profils, descriptions de beatmaps et actualités sont téléchargées depuis des serveurs externes. Ceux-ci reçoivent votre adresse IP et peuvent enregistrer les requêtes. Ce choix concerne toutes ces images sur cet appareil et peut être modifié dans le menu du compte. Les avatars et couvertures osu! sont chargés séparément.';

  @override
  String get contentMediaAllow => 'Autoriser les images';

  @override
  String get contentMediaDecline => 'Pas maintenant';

  @override
  String get contentMediaDisabled =>
      'Les images externes sont désactivées. Vous pouvez les activer dans le menu du compte.';

  @override
  String get contentMediaSaveFailed =>
      'Impossible d’enregistrer ce choix. Il peut être réinitialisé au redémarrage.';

  @override
  String get contentImageUnsupported =>
      'Cette adresse d’image n’est pas prise en charge. Ouvrez la page originale.';

  @override
  String get profilePlayHistoryTitle => 'Parties par mois';

  @override
  String rankingsPosition(int position) {
    final intl.NumberFormat positionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String positionString = positionNumberFormat.format(position);

    return 'Position nº $positionString';
  }

  @override
  String get rankingsPositionNotice =>
      'Les positions concernent ce classement filtré, pas le rang mondial en PP. Le classement peut changer entre les pages ; actualisez pour le mettre à jour.';

  @override
  String get rankingsCountrySelection => 'Pays ou région';

  @override
  String get rankingsCountrySearch => 'Nom du pays ou code';

  @override
  String get rankingsCountryCatalogHint =>
      'Recherchez un nom anglais ou un code à deux lettres. Certaines entrées affichent uniquement le code. La disponibilité du classement dépend d’osu!.';

  @override
  String get rankingsCountryCatalogFailed =>
      'Impossible de charger la liste des pays.';

  @override
  String get rankingsCountryNoMatch => 'Aucun pays correspondant.';

  @override
  String get rankingsEnd => 'Fin du classement disponible.';

  @override
  String get scoreHitsTitle => 'Résultats des frappes';

  @override
  String get scoreHitsExplanation =>
      'Les noms correspondent à l’API. Une valeur absente n’est pas zéro ; les maxima décrivent une partie parfaite, pas un objectif par ligne.';

  @override
  String get scoreHitsAchieved => 'Obtenus';

  @override
  String get scoreHitsMaximum => 'Lors d’une partie parfaite';

  @override
  String get scoreModSettingsTitle => 'Paramètres des mods';

  @override
  String get scoreModSettingsExplanation =>
      'Les noms de l’API sont conservés. Seuls les paramètres fournis sont affichés, sans supposer de valeurs par défaut.';

  @override
  String get scoreNoModSettings => 'Aucun paramètre explicite fourni.';

  @override
  String get scoreDetailsUnavailable => 'Indisponible';

  @override
  String get scoreSettingEnabled => 'Activé';

  @override
  String get scoreSettingDisabled => 'Désactivé';

  @override
  String get beatmapDescription => 'Description de la beatmap';

  @override
  String get contentPageUnavailable =>
      'Ce contenu ne peut pas être affiché ici. Vous pouvez ouvrir l’original.';

  @override
  String get scoreDetailsTitle => 'Détails du résultat';

  @override
  String get scoreOpenBeatmap => 'Ouvrir la beatmap';

  @override
  String get scoreStandardisedTotal => 'Score standardisé';

  @override
  String get mapSetPlays => 'Parties du set';

  @override
  String get mapFavourites => 'Favoris';

  @override
  String get mapBpm => 'BPM';

  @override
  String get profileReplayHistoryTitle => 'Vues des replays par mois';

  @override
  String get profileReplayHistoryExplanation =>
      'Les mois sans observations sont omis ; une donnée absente ne vaut pas zéro.';

  @override
  String get profileAbout => 'À propos de moi';

  @override
  String get contentPageNotice =>
      'Les images externes suivent votre choix enregistré. Les contenus intégrés s’ouvrent dans la page originale. Sans contenu mis en forme, le BBCode apparaît en texte brut.';

  @override
  String get contentLinkFailed => 'Impossible d’ouvrir le lien.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileOverview => 'Aperçu';

  @override
  String get profilePpLabel => 'Performance (PP)';

  @override
  String get profileGlobalRankLabel => 'Classement mondial';

  @override
  String get profileCountryRankLabel => 'Classement national';

  @override
  String get profileStatisticsTitle => 'Statistiques';

  @override
  String get profileAccuracyLabel => 'Précision';

  @override
  String get profilePlayCountLabel => 'Parties jouées';

  @override
  String get profilePlayTimeLabel => 'Temps de jeu';

  @override
  String get profileComboLabel => 'Combo maximal';

  @override
  String get profileValueUnavailable => 'Indisponible';

  @override
  String get profileGradesTitle => 'Notes des scores';

  @override
  String get profileRankedScoreLabel => 'Score classé';

  @override
  String get profileTotalScoreLabel => 'Score total';

  @override
  String get profileTotalHitsLabel => 'Total des frappes';

  @override
  String get profileReplaysLabel => 'Replays vus par les autres';

  @override
  String get profileHistoryTitle => 'Historique du classement';

  @override
  String get profileHistoryEmpty => 'Aucun historique pour ce mode.';

  @override
  String get profileHistoryExplanation =>
      'Observations API dans l’ordre, sans dates calendaires. Les interruptions indiquent des rangs indisponibles.';

  @override
  String get profileSwitchingMode =>
      'Chargement du mode sélectionné. Les données du mode précédent restent affichées.';

  @override
  String get profileUpdateFailed =>
      'Échec de la mise à jour. Les données et le mode précédents sont conservés.';

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

    return 'Niveau $levelString';
  }

  @override
  String profileLevelProgress(int progress) {
    final intl.NumberFormat progressNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String progressString = progressNumberFormat.format(progress);

    return '$progressString% vers le niveau suivant';
  }

  @override
  String profileHistorySample(int index) {
    final intl.NumberFormat indexNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);

    return 'Observation $indexString';
  }

  @override
  String get navigationSearch => 'Recherche';

  @override
  String get navigationUnavailable => 'Cette page est indisponible.';

  @override
  String get searchClear => 'Effacer la recherche';

  @override
  String get contentImage => 'Image';

  @override
  String get contentImageLoading => 'Chargement de l’image…';

  @override
  String get contentImageFailed =>
      'Impossible de charger l’image. Elle est peut-être indisponible ou sa taille ou son format n’est pas pris en charge.';

  @override
  String get contentImageOpen => 'Agrandir l’image';

  @override
  String get contentDisclosure => 'Afficher le contenu masqué';

  @override
  String get contentUnsupported =>
      'Ce contenu intégré est disponible sur la page d’origine.';

  @override
  String get contentOriginal => 'Ouvrir l’original';

  @override
  String get contentUnavailable =>
      'Contenu indisponible dans le lecteur. Ouvrez l’original.';

  @override
  String get uiCatalogMedia => 'Images et badges';

  @override
  String get uiCatalogCards => 'Cartes de joueurs et de contenu';

  @override
  String get uiCatalogCharts => 'Graphiques';

  @override
  String get uiCatalogStates => 'États du contenu';

  @override
  String get uiCatalogSampleNotice =>
      'Données de démonstration, pas des statistiques réelles. Les visuels Tracksu existants illustrent la disposition des images.';

  @override
  String get uiCatalogHistory => 'Historique du classement';

  @override
  String get uiCatalogActivity => 'Activité de jeu';

  @override
  String get uiCatalogSinglePoint => 'Une observation';

  @override
  String get uiCatalogFlatSeries => 'Valeurs constantes';

  @override
  String get uiCatalogOffline => 'Aucune connexion';

  @override
  String get uiCatalogNoData => 'Aucune donnée pour le moment';

  @override
  String get uiCatalogChartHint =>
      'Touchez, faites glisser ou utilisez le curseur pour consulter une valeur. Les meilleurs rangs sont placés plus haut.';

  @override
  String get uiMetricPerformance => 'Points de performance';

  @override
  String get uiMetricAccuracy => 'Précision';

  @override
  String get uiMetricGlobalRank => 'Classement mondial';

  @override
  String get uiMetricPlayCount => 'Nombre de parties';

  @override
  String get uiMetricPlayTime => 'Temps de jeu';

  @override
  String get uiCatalogTitle => 'UI kit';

  @override
  String get uiCatalogTheme => 'Changer de thème';

  @override
  String get uiCatalogTypography => 'Typographie et surfaces';

  @override
  String get uiCatalogButtons => 'Boutons';

  @override
  String get uiCatalogInputs => 'Saisie et sélection';

  @override
  String get uiCatalogFeedback => 'Messages';

  @override
  String get uiCatalogNavigation => 'Navigation';

  @override
  String get uiCatalogConfirmMessage =>
      'Cette confirmation concerne uniquement un aperçu. Aucun compte ni aucune donnée ne sera modifié.';

  @override
  String get newsTitle => 'Actualités';

  @override
  String get newsRefresh => 'Actualiser les actualités';

  @override
  String get newsEmpty => 'Aucune actualité disponible.';

  @override
  String get newsLoadMore => 'Charger plus d’actualités';

  @override
  String get newsLoading => 'Chargement des actualités…';

  @override
  String get newsKeepingContent => 'Le contenu déjà chargé reste affiché.';

  @override
  String get newsNotFound => 'Cet article est indisponible.';

  @override
  String get newsCancelled => 'Le chargement des actualités a été annulé.';

  @override
  String get newsAccessDenied => 'Impossible d’accéder aux actualités.';

  @override
  String get newsInvalidResponse =>
      'Impossible de lire la réponse des actualités.';

  @override
  String get newsUnavailable =>
      'Les actualités sont temporairement indisponibles.';

  @override
  String get newsLinkFailed => 'Impossible d’ouvrir ce lien.';

  @override
  String get newsOriginal => 'Ouvrir l’original';

  @override
  String get newsReaderNotice =>
      'Les images externes suivent votre choix enregistré. Les contenus intégrés s’ouvrent dans la page originale.';

  @override
  String get spotlightsTitle => 'Spotlights';

  @override
  String get spotlightsChoose => 'Choisir un Spotlight';

  @override
  String get spotlightsShowRanking => 'Afficher le Spotlight sélectionné';

  @override
  String get spotlightsEmpty => 'Aucun Spotlight disponible.';

  @override
  String get spotlightsMaps => 'Sets de beatmaps';

  @override
  String get spotlightsNoMaps =>
      'Aucun set de beatmaps pour ce Spotlight et ce mode de jeu.';

  @override
  String get spotlightsRankingLimit =>
      'Classement Spotlight · jusqu’à 40 joueurs';

  @override
  String get spotlightsNotFound =>
      'Ce Spotlight ou ce mode de jeu est indisponible.';

  @override
  String get appTitle => 'Tracksu';

  @override
  String get guestModeTitle => 'Mode invité';

  @override
  String get guestSignedOutDescription =>
      'Consultez les données publiques d’osu! en tant qu’invité. Connectez-vous pour accéder aux fonctions du compte.';

  @override
  String get guestSignedInDescription =>
      'Vous êtes connecté. La consultation des données publiques reste accessible sans compte.';

  @override
  String get signInWithOsu => 'Se connecter avec osu!';

  @override
  String get signInWithAnotherAccount => 'Se connecter avec un autre compte';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signingOut => 'Déconnexion…';

  @override
  String get signOutFailed => 'Impossible de se déconnecter. Réessayez.';

  @override
  String get systemLanguage => 'Langue du système';

  @override
  String get englishLanguage => 'Anglais';

  @override
  String get russianLanguage => 'Russe';

  @override
  String get loginToOsu => 'Connexion à osu!';

  @override
  String get signingIn => 'Connexion…';

  @override
  String get openingOsu => 'Ouverture d’osu!…';

  @override
  String get continueWithOsu => 'Continuer avec osu!';

  @override
  String get authorizationExpired =>
      'Cette demande d’autorisation a expiré. Réessayez.';

  @override
  String get authorizationResponseUnavailable =>
      'Impossible de recevoir la réponse d’autorisation.';

  @override
  String get authorizationResponseMismatch =>
      'La réponse d’autorisation ne correspond pas à cette tentative de connexion.';

  @override
  String get authorizationCancelled =>
      'L’autorisation a été annulée ou refusée.';

  @override
  String get authorizationResponseInvalid =>
      'La réponse d’autorisation n’est pas valide.';

  @override
  String get authorizationPreparationFailed =>
      'Impossible de préparer l’autorisation osu!.';

  @override
  String get authorizationLaunchFailed =>
      'Impossible d’ouvrir l’autorisation osu!.';

  @override
  String get authorizationCompletionFailed =>
      'Impossible de terminer l’autorisation.';

  @override
  String get authorizationIncomplete =>
      'L’autorisation n’a pas été terminée. Réessayez.';

  @override
  String get viewMyProfile => 'Voir mon profil';

  @override
  String get profileSearchHint => 'Nom exact ou ID';

  @override
  String get profileSearchInvalid =>
      'Saisissez un nom d’utilisateur valide ou un ID positif.';

  @override
  String get rulesetOsu => 'osu!';

  @override
  String get rulesetTaiko => 'taiko';

  @override
  String get rulesetFruits => 'catch';

  @override
  String get rulesetMania => 'mania';

  @override
  String get profileLoading => 'Chargement du profil…';

  @override
  String get profileUnavailable => 'Profil indisponible. Réessayez.';

  @override
  String get retry => 'Réessayer';

  @override
  String profileId(int id) {
    return 'ID : $id';
  }

  @override
  String profilePerformance(double pp) {
    final intl.NumberFormat ppNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 0,
        );
    final String ppString = ppNumberFormat.format(pp);

    return 'Performance : $ppString';
  }

  @override
  String profileCountry(String country) {
    return 'Pays : $country';
  }

  @override
  String profileAccuracy(double accuracy) {
    final intl.NumberFormat accuracyNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 2,
        );
    final String accuracyString = accuracyNumberFormat.format(accuracy);

    return 'Précision : $accuracyString %';
  }

  @override
  String profilePlayCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Nombre de parties : $countString';
  }

  @override
  String get profileSearchIntroduction =>
      'Ouvrez un profil avec le nom exact ou l’ID du joueur. Aucune connexion requise.';

  @override
  String get profileSearchHelp =>
      'Choisissez le mode, saisissez le nom complet ou l’ID, puis validez. Pas de suggestions pendant la saisie. Pour un nom numérique, utilisez @.';

  @override
  String get profileOpen => 'Ouvrir le profil';

  @override
  String get profileSearch => 'Rechercher un joueur';

  @override
  String get profileRefreshing => 'Actualisation du profil';

  @override
  String get profileRefresh => 'Actualiser';

  @override
  String get profileShowingPreviousData =>
      'Échec de l’actualisation. Les données déjà chargées sont affichées.';

  @override
  String get profileNotFound => 'Joueur introuvable. Vérifiez le nom ou l’ID.';

  @override
  String get profileAccessDenied =>
      'Accès refusé par osu!. Pour votre propre profil, essayez de vous reconnecter.';

  @override
  String get profileRateLimited =>
      'Trop de requêtes. Patientez avant de réessayer.';

  @override
  String get profileConnectionFailed =>
      'Connexion impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get profileInvalidResponse =>
      'Le serveur a renvoyé une réponse de profil non prise en charge.';

  @override
  String get profileOnline => 'En ligne';

  @override
  String get profileOffline => 'Hors ligne';

  @override
  String get profileSupporter => 'osu!supporter';

  @override
  String get profileNoStatistics =>
      'Pas encore de statistiques pour ce mode de jeu.';

  @override
  String get profileUnranked => 'Pas de classement mondial';

  @override
  String profileGlobalRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Classement mondial : #$rankString';
  }

  @override
  String profileCountryRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Classement national : #$rankString';
  }

  @override
  String profilePlayTime(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return 'Temps de jeu : $hoursString h';
  }

  @override
  String profileMaximumCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'Combo maximal : $comboString';
  }

  @override
  String get languageChangeFailed => 'Impossible d’enregistrer la langue.';

  @override
  String get languageSelection => 'Langue';

  @override
  String get account => 'Compte';

  @override
  String get scoresTitle => 'Scores';

  @override
  String get scoresBest => 'Meilleurs';

  @override
  String get scoresRecent => 'Récents';

  @override
  String get scoresRefresh => 'Actualiser les scores';

  @override
  String get scoresLoading => 'Chargement des scores…';

  @override
  String get scoresEmpty => 'Aucun score pour ce joueur et ce mode de jeu.';

  @override
  String get scoresLoadMore => 'Charger plus';

  @override
  String get scoresKeepingContent =>
      'Les scores déjà chargés restent affichés.';

  @override
  String get scoresCancelled => 'Le chargement a été annulé.';

  @override
  String get scoresNotFound => 'Scores introuvables.';

  @override
  String get scoresAccessDenied => 'osu! a refusé l’accès aux scores.';

  @override
  String get scoresInvalidResponse =>
      'Le serveur a renvoyé une réponse de score non prise en charge.';

  @override
  String get scoresUnavailable =>
      'Les scores sont temporairement indisponibles.';

  @override
  String get scoresNoMods => 'Aucun mod';

  @override
  String get scoresNoPp => 'PP indisponibles';

  @override
  String get scoresFailedPlay => 'Partie échouée';

  @override
  String scoresBeatmap(int id) {
    return 'Beatmap n° $id';
  }

  @override
  String scoresGrade(String grade) {
    return 'Note : $grade';
  }

  @override
  String scoresCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'Combo : $comboString';
  }

  @override
  String scoresTotal(int total) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Score : $totalString';
  }

  @override
  String scoresMods(String mods) {
    return 'Mods : $mods';
  }

  @override
  String scoresPlayedAt(String date) {
    return 'Joué le : $date';
  }

  @override
  String get beatmapsTitle => 'Beatmaps';

  @override
  String get beatmapsMostPlayed => 'Les plus jouées';

  @override
  String get beatmapsFavourite => 'Favoris';

  @override
  String get beatmapsRanked => 'Classées';

  @override
  String get beatmapsPending => 'En attente';

  @override
  String get beatmapsGraveyard => 'Cimetière';

  @override
  String get beatmapsLoved => 'Loved';

  @override
  String get beatmapsGuest => 'Difficultés invitées';

  @override
  String get beatmapsNominated => 'Nominées';

  @override
  String get beatmapsRefresh => 'Actualiser les beatmaps';

  @override
  String get beatmapsEmpty => 'Aucune beatmap dans cette catégorie.';

  @override
  String get beatmapsLoadMore => 'Charger plus de beatmaps';

  @override
  String get beatmapsLoading => 'Chargement des beatmaps…';

  @override
  String get beatmapsKeepingContent =>
      'Actualisation impossible. Les beatmaps déjà chargées restent affichées.';

  @override
  String get beatmapsCancelled => 'Le chargement a été annulé.';

  @override
  String get beatmapsNotFound => 'Les beatmaps de ce joueur sont introuvables.';

  @override
  String get beatmapsAccessDenied =>
      'Les beatmaps sont actuellement inaccessibles.';

  @override
  String get beatmapsInvalidResponse =>
      'Le serveur a renvoyé une réponse de beatmap inattendue.';

  @override
  String get beatmapsUnavailable =>
      'Impossible de charger les beatmaps. Réessayez.';

  @override
  String beatmapsSetFallback(int id) {
    return 'Set de beatmaps n° $id';
  }

  @override
  String beatmapsMapFallback(int id) {
    return 'Beatmap n° $id';
  }

  @override
  String beatmapsPlayCount(int count) {
    return 'Parties du joueur : $count';
  }

  @override
  String get beatmapTitle => 'Beatmap';

  @override
  String get beatmapNotFound => 'Beatmap introuvable.';

  @override
  String get beatmapAccessDenied =>
      'Cette beatmap ou ce classement est inaccessible.';

  @override
  String get beatmapInvalidResponse => 'Réponse de beatmap inattendue.';

  @override
  String get beatmapUnavailable =>
      'Impossible de charger les données de la beatmap.';

  @override
  String get beatmapLeaderboard => 'Meilleurs scores';

  @override
  String get beatmapRefreshLeaderboard => 'Actualiser les scores';

  @override
  String get beatmapNoScores => 'Aucun score disponible.';

  @override
  String beatmapLeaderboardPlayer(int position, String name) {
    return '#$position · $name';
  }

  @override
  String beatmapPlayerId(int id) {
    return 'Joueur n° $id';
  }

  @override
  String beatmapCreator(String name) {
    return 'Créée par $name';
  }

  @override
  String get beatmapRefresh => 'Actualiser la beatmap';

  @override
  String get beatmapDifficulties => 'Difficultés';

  @override
  String get beatmapNoDifficulties => 'Aucune difficulté disponible.';

  @override
  String beatmapDifficultyInfo(String mode, double stars, int seconds) {
    return '$mode · $stars ★ · $seconds s';
  }

  @override
  String get rankingsTitle => 'Classements';

  @override
  String get rankingsScore => 'Score';

  @override
  String get rankingsRefresh => 'Actualiser le classement';

  @override
  String get rankingsEmpty => 'Aucun joueur trouvé.';

  @override
  String get rankingsLoadMore => 'Charger plus de joueurs';

  @override
  String get rankingsLoading => 'Chargement du classement…';

  @override
  String get rankingsKeepingContent =>
      'Actualisation impossible. Le classement déjà chargé est affiché.';

  @override
  String get rankingsCancelled => 'Chargement annulé.';

  @override
  String get rankingsNotFound => 'Classement introuvable.';

  @override
  String get rankingsAccessDenied => 'Classement inaccessible.';

  @override
  String get rankingsInvalidResponse => 'Réponse de classement inattendue.';

  @override
  String get rankingsUnavailable => 'Impossible de charger le classement.';

  @override
  String rankingsRankedScore(int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Score classé : $scoreString';
  }

  @override
  String get rankingsCountry => 'Code du pays';

  @override
  String get rankingsCountryInvalid =>
      'Saisissez un code de pays à deux lettres.';

  @override
  String get rankingsWorldwide => 'Monde entier';

  @override
  String get rankingsAllKeys => 'Tous les nombres de touches';

  @override
  String get germanLanguage => 'Allemand';

  @override
  String get frenchLanguage => 'Français';

  @override
  String get spanishLanguage => 'Espagnol';

  @override
  String get japaneseLanguage => 'Japonais';

  @override
  String get chineseLanguage => 'Chinois (simplifié)';
}
