// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settingsCacheCalculating => 'Calcul de la taille du cache…';

  @override
  String get settingsCacheFailed => 'Impossible d’accéder au cache. Réessayez.';

  @override
  String settingsCacheConfirm(String size) {
    return 'Supprimer $size Mo d’images et d’audio ? Votre compte et vos réglages sont conservés.';
  }

  @override
  String settingsCacheSize(String size) {
    return '$size Mo';
  }

  @override
  String get audioPreview => 'Extrait audio';

  @override
  String get audioPlay => 'Écouter';

  @override
  String get audioPause => 'Pause';

  @override
  String get audioReplay => 'Réécouter';

  @override
  String get audioCancel => 'Annuler le chargement';

  @override
  String get audioLoading => 'Chargement audio…';

  @override
  String get audioPlaying => 'Lecture en cours';

  @override
  String get audioPaused => 'En pause';

  @override
  String get audioCompleted => 'Terminé';

  @override
  String get audioFailed =>
      'Impossible de lire cet audio. Vérifiez votre connexion et réessayez.';

  @override
  String get audioFailedUnavailable =>
      'Cet aperçu audio n’est plus disponible.';

  @override
  String get audioFailedUnsupported =>
      'Ce format audio ne peut pas être lu sur cet appareil.';

  @override
  String get audioFailedFocus =>
      'Une autre app utilise l’audio. Réessayez lorsqu’elle s’arrête.';

  @override
  String get audioFailedUnknown => 'Impossible de lire cet audio.';

  @override
  String get audioSeek => 'Position de lecture';

  @override
  String get teamTitle => 'Équipe';

  @override
  String get teamLoading => 'Chargement de l’équipe…';

  @override
  String get teamNotFound => 'Équipe introuvable';

  @override
  String get teamAccessDenied => 'Cette équipe ne peut pas être consultée.';

  @override
  String get teamFailed => 'Impossible de charger l’équipe. Réessayez.';

  @override
  String get teamOpen => 'Recrutement ouvert';

  @override
  String get teamClosed => 'Recrutement fermé';

  @override
  String teamSlots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places libres',
      one: '1 place libre',
      zero: 'Aucune place libre',
    );
    return '$_temp0';
  }

  @override
  String teamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String teamCreated(String date) {
    return 'Créée le $date';
  }

  @override
  String teamDefaultMode(String mode) {
    return 'Mode principal : $mode';
  }

  @override
  String get teamDescription => 'À propos de l’équipe';

  @override
  String get teamLeader => 'Chef d’équipe';

  @override
  String teamLastVisit(String date) {
    return 'Dernière connexion : $date';
  }

  @override
  String get scoreGaugeReference =>
      'Échelle de précision de référence osu!lazer ; SS exige 100 % (sa zone est agrandie pour être visible). Le grade provient du résultat : les ratés, mods et anciennes règles peuvent aussi l’influencer.';

  @override
  String get settingsCache => 'Cache';

  @override
  String get settingsClearCache => 'Vider';

  @override
  String get settingsCacheDescription =>
      'Couvertures et aperçus audio enregistrés sur cet appareil.';

  @override
  String get settingsCacheCleared => 'Cache vidé';

  @override
  String get profileDailyEmpty =>
      'Ce joueur n’a pas encore participé au défi quotidien.';

  @override
  String get aboutTitle => 'À propos de Tracksu';

  @override
  String get aboutTabApp => 'À propos';

  @override
  String get settingsClearCacheTitle => 'Vider le cache ?';

  @override
  String get aboutHistoryShort =>
      'Tracksu existe depuis 2021 et a été plusieurs fois développé et reconstruit.';

  @override
  String get aboutTabAuthors => 'Auteurs';

  @override
  String get aboutTabLicenses => 'Licences';

  @override
  String get aboutRoleAuthor => 'Auteur';

  @override
  String get aboutRoleCoauthor => 'Co-auteur';

  @override
  String get aboutThanksTitle => 'Merci';

  @override
  String get aboutThanksBody =>
      'À ppy et à l’équipe osu! pour le jeu et son API publique. À la communauté osu! pour les maps, les joueurs et les idées. Aux auteurs des bibliothèques libres listées dans Licences.';

  @override
  String get aboutDescription =>
      'Explorez les joueurs, scores, beatmaps et actualités d’osu!.';

  @override
  String get aboutUnofficial =>
      'Un client indépendant et non officiel, sans affiliation ni approbation de ppy Pty Ltd.';

  @override
  String get aboutBuild => 'Version installée';

  @override
  String get aboutBuildUnavailable =>
      'Impossible de lire la version de l’application installée.';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version · Build $build';
  }

  @override
  String get aboutProject => 'Projet sur GitHub';

  @override
  String get aboutOsu => 'Site d’osu!';

  @override
  String get aboutLicensesDescription =>
      'Bibliothèques open source et licences des ressources';

  @override
  String get licensesIntro =>
      'Tracksu repose sur des logiciels libres. Voici les paquets de l’app et les textes de licence que leurs auteurs demandent d’afficher.';

  @override
  String get licensesSearch => 'Rechercher un paquet';

  @override
  String get licensesNoMatch => 'Aucun paquet correspondant.';

  @override
  String licensesPackageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paquets',
      one: '$count paquet',
    );
    return '$_temp0';
  }

  @override
  String get aboutLinkFailed => 'Impossible d’ouvrir le lien.';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Suivre le système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSaveFailed => 'Impossible d’enregistrer le thème.';

  @override
  String get spotlightsParticipants => 'Participants';

  @override
  String get spotlightsSearch => 'Nom, année ou ID';

  @override
  String get spotlightsNoMatch => 'Aucun Spotlight correspondant.';

  @override
  String spotlightsStartDate(String date) {
    return 'Date de début : $date';
  }

  @override
  String spotlightsEndDate(String date) {
    return 'Date de fin : $date';
  }

  @override
  String get spotlightsKindMonthly => 'Mensuel';

  @override
  String get spotlightsKindBestOf => 'Meilleurs de l’année';

  @override
  String get spotlightsKindSpecial => 'Spécial';

  @override
  String get spotlightsKindTheme => 'Thématique';

  @override
  String get spotlightsRulesetUnavailable =>
      'Aucun classement pour ce mode de jeu.';

  @override
  String get spotlightsRulesetUnavailableHint =>
      'osu! n’a tenu ce Spotlight que pour certains modes. Choisissez-en un autre ci-dessus.';

  @override
  String get spotlightsHomeDescription =>
      'Anciens classements osu!, le dernier date de 2020. Les Spotlights ne sont plus organisés : les Seasons les ont remplacés.';

  @override
  String get spotlightsOpen => 'Archives des Spotlights';

  @override
  String spotlightsDifficultyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count difficultés dans le set',
      one: '$count difficulté dans le set',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSignOutConfirm =>
      'Se déconnecter sur cet appareil ? Votre profil osu! public restera accessible.';

  @override
  String get medalsLoading => 'Chargement des médailles…';

  @override
  String get medalsFailed =>
      'Impossible de charger les détails des médailles depuis osu!. Réessayez.';

  @override
  String get medalsEmpty => 'Aucune médaille obtenue.';

  @override
  String get scoreMiss => 'Raté';

  @override
  String get scoreFruit => 'Fruits';

  @override
  String get scoreDroplet => 'Gouttes';

  @override
  String get scoreTinyDroplet => 'Petites gouttes';

  @override
  String get scoreTinyMiss => 'Petites gouttes manquées';

  @override
  String get scoreJudgementPercentNotice =>
      'Les pourcentages portent sur les jugements affichés, pas sur la progression de la map ni le combo maximal. Les ticks de sliders et compteurs techniques legacy sont exclus.';

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
  String get contentMediaSettings => 'Charger les images';

  @override
  String get contentMediaConsent =>
      'Couvertures et avatars se chargent automatiquement. Désactivez pour économiser des données.';

  @override
  String get contentMediaAllow => 'Autoriser les images';

  @override
  String get contentMediaDecline => 'Pas maintenant';

  @override
  String get contentMediaDisabled =>
      'Les images sont désactivées. Activez-les dans les réglages.';

  @override
  String get contentMediaSaveFailed =>
      'Impossible d’enregistrer ce choix. Il peut être réinitialisé au redémarrage.';

  @override
  String get contentImageUnsupported =>
      'Cette adresse d’image n’est pas prise en charge. Ouvrez la page originale.';

  @override
  String get contentImagePaused => 'Le chargement de l’image est en pause.';

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
      'Recherchez un nom de pays ou un code à deux lettres. La disponibilité du classement dépend d’osu!.';

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
  String get profileOverview => 'Profil';

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
  String get profileNotRanked => 'Non classé';

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
  String get contentImageUnavailable =>
      'Cette image n’est plus disponible à sa source.';

  @override
  String get contentImageNetwork =>
      'Impossible de joindre le serveur de l’image. Vérifiez votre connexion et réessayez.';

  @override
  String get contentImageFormat =>
      'Ce format d’image ne peut pas être affiché.';

  @override
  String get contentImageTooLarge =>
      'Cette image est trop grande pour être affichée.';

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
  String get spotlightsNotFound => 'Ce Spotlight est indisponible.';

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
  String get profileSearchHint => 'Nom ou identifiant';

  @override
  String get profileSearchInvalid =>
      'Saisissez un nom d’utilisateur valide ou un ID positif.';

  @override
  String get rulesetOsu => 'ctd';

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
      'Recherchez un joueur par nom ou saisissez son identifiant exact. Utilisez @ pour un nom exact, même numérique.';

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
  String get profileSupporterInfo =>
      'Ce joueur a osu!supporter : un abonnement volontaire qui fait vivre osu! sans publicité. Les supporters ont des bonus comme plus d’amis, une bannière de profil et le téléchargement de beatmaps en jeu.';

  @override
  String get actionGotIt => 'Compris';

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
  String get scoresPinned => 'Épinglés';

  @override
  String get scoresFirsts => 'Premières places';

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
  String gradeSilver(String grade) {
    return '$grade argent';
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
  String get beatmapsCategory => 'Catégorie de beatmaps';

  @override
  String get scoresCategory => 'Type de résultats';

  @override
  String get beatmapsGroupPlayer => 'Joueur';

  @override
  String get beatmapsGroupMapper => 'Mappeur';

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
  String get rankingsAllKeys => 'Toutes';

  @override
  String get rankingsPlayers => 'Joueurs';

  @override
  String get rankingsTeams => 'Équipes';

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

  @override
  String get scrollToTop => 'Haut de page';

  @override
  String get dailyTitle => 'Map du jour';

  @override
  String dailyRemaining(String time) {
    return 'Encore $time';
  }

  @override
  String dailyParticipants(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString joueurs',
      one: '$countString joueur',
    );
    return '$_temp0';
  }

  @override
  String get dailyNone => 'Pas de défi du jour pour le moment.';

  @override
  String get dailyLeaderboard => 'Classement du jour';

  @override
  String get dailyOpenMap => 'Ouvrir la map';

  @override
  String get dailyFailed => 'Impossible de charger la map du jour.';

  @override
  String get contentVideoPlay => 'Lire la vidéo';

  @override
  String get contentVideoPause => 'Pause';

  @override
  String get contentVideoFullscreen => 'Plein écran';

  @override
  String get contentVideoExitFullscreen => 'Quitter le plein écran';

  @override
  String get contentVideoFailed => 'Impossible de lire la vidéo.';

  @override
  String get contentEmbedYoutube => 'Regarder sur YouTube';

  @override
  String contentEmbedOpen(String host) {
    return 'Ouvrir sur $host';
  }

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String commentsTitleCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString commentaires',
      one: '$countString commentaire',
    );
    return '$_temp0';
  }

  @override
  String get commentsSortNew => 'Récents';

  @override
  String get commentsSortOld => 'Anciens';

  @override
  String get commentsSortTop => 'Top';

  @override
  String get commentsLoading => 'Chargement des commentaires';

  @override
  String get commentsFailed => 'Impossible de charger les commentaires.';

  @override
  String get commentsEmpty => 'Aucun commentaire pour l\'instant.';

  @override
  String get commentsDeleted => 'Commentaire supprimé';

  @override
  String get commentsEdited => 'modifié';

  @override
  String get commentsPinned => 'Épinglé';

  @override
  String get commentsUnknownUser => 'Utilisateur supprimé';

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
      other: '$countString réponses',
      one: '$countString réponse',
    );
    return '$_temp0';
  }

  @override
  String get commentsHideReplies => 'Masquer les réponses';

  @override
  String get commentsMoreReplies => 'Plus de réponses';

  @override
  String get commentsJustNow => 'à l\'instant';

  @override
  String commentsMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $countString min',
      one: 'il y a $countString min',
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
      other: 'il y a $countString h',
      one: 'il y a $countString h',
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
      other: 'il y a $countString jours',
      one: 'il y a $countString jour',
    );
    return '$_temp0';
  }

  @override
  String get rankingsCountries => 'Pays';

  @override
  String rankingsCountryPlayers(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString joueurs actifs',
      one: '$countString joueur actif',
    );
    return '$_temp0';
  }

  @override
  String get beatmapSearchTitle => 'Recherche de beatmaps';

  @override
  String get beatmapSearchHomeDescription =>
      'Beatmaps osu! classées, aimées et autres';

  @override
  String get beatmapSearchHint => 'Titre, artiste ou mappeur';

  @override
  String get beatmapSearchStatus => 'Statut des beatmaps';

  @override
  String get beatmapSearchLeaderboard => 'Avec classement';

  @override
  String get beatmapSearchQualified => 'Qualifiées';

  @override
  String get beatmapSearchWip => 'En cours';

  @override
  String get beatmapSearchAny => 'Tout statut';

  @override
  String get beatmapSearchEmpty => 'Aucun résultat.';

  @override
  String get beatmapSearchFailed => 'Impossible de rechercher des beatmaps.';

  @override
  String beatmapSearchFound(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString beatmaps trouvées',
      one: '$countString beatmap trouvée',
    );
    return '$_temp0';
  }

  @override
  String get aboutBuiltWithFlutter => 'Développé avec Flutter';

  @override
  String get commentsReply => 'Répondre';

  @override
  String get commentsVoteOnSite => 'Voter et répondre se fait sur osu.ppy.sh';

  @override
  String get dailyHistory => 'Jours précédents';

  @override
  String get dailyHistoryDescription =>
      'Anciennes maps du jour et classements finaux';

  @override
  String get dailyHistoryLimit => 'Jusqu’à 250 jours récents';

  @override
  String get dailyHistoryEmpty => 'Aucun jour précédent disponible';

  @override
  String get dailyPastUnavailable => 'Le défi de ce jour est indisponible';

  @override
  String get leaderboardModsTitle => 'Filtrer par mods';

  @override
  String get leaderboardModsAll => 'Tous les mods';

  @override
  String get leaderboardModsReset => 'Réinitialiser';

  @override
  String get leaderboardModsApply => 'Appliquer';

  @override
  String get beatmapKeys => 'Touches';

  @override
  String get beatmapCircleSize => 'Taille des cercles (CS)';

  @override
  String get beatmapHpDrain => 'Perte de PV';

  @override
  String get beatmapAccuracy => 'Précision (OD)';

  @override
  String get beatmapApproachRate => 'Vitesse d’approche (AR)';

  @override
  String get beatmapMaxCombo => 'Combo max.';

  @override
  String get beatmapObjects => 'Objets';

  @override
  String get beatmapPlays => 'Parties';

  @override
  String get beatmapPassRate => 'Taux de réussite';

  @override
  String get beatmapSearchAnyMode => 'Tous';

  @override
  String get beatmapSearchGenre => 'Genre';

  @override
  String get beatmapSearchAnyGenre => 'Tous les genres';

  @override
  String get beatmapSearchLanguage => 'Langue';

  @override
  String get beatmapSearchAnyLanguage => 'Toutes les langues';

  @override
  String get genreUnspecified => 'Non spécifié';

  @override
  String get genreVideoGame => 'Jeu vidéo';

  @override
  String get genreAnime => 'Anime';

  @override
  String get genreRock => 'Rock';

  @override
  String get genrePop => 'Pop';

  @override
  String get genreOther => 'Autre';

  @override
  String get genreNovelty => 'Humoristique';

  @override
  String get genreHipHop => 'Hip-hop';

  @override
  String get genreElectronic => 'Électronique';

  @override
  String get genreMetal => 'Metal';

  @override
  String get genreClassical => 'Classique';

  @override
  String get genreFolk => 'Folk';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languageInstrumental => 'Instrumental';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageSwedish => 'Suédois';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languagePolish => 'Polonais';

  @override
  String get languageOther => 'Autre';

  @override
  String get languageUnspecified => 'Non spécifiée';

  @override
  String get rankingsKudosu => 'Kudosu';

  @override
  String get rankingsKudosuHint =>
      'Classement par total de kudosu gagnés en aidant les mappeurs. Jusqu’à 1 000 joueurs.';

  @override
  String rankingsKudosuAvailable(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Kudosu disponibles : $countString';
  }

  @override
  String get unifiedSearchTitle => 'Rechercher des joueurs et des beatmaps';

  @override
  String get unifiedSearchDescription =>
      'Joueurs, beatmaps et identifiants exacts';

  @override
  String get unifiedSearchMaps => 'Beatmaps';

  @override
  String get unifiedSearchPrompt => 'Saisissez au moins deux caractères';

  @override
  String get userSearchEmpty => 'Aucun joueur trouvé';

  @override
  String get userSearchFailed => 'Impossible de charger les joueurs';

  @override
  String get userSearchLimit =>
      'Les 100 premiers joueurs sont affichés. Affinez votre recherche.';

  @override
  String get profileActivity => 'Activité';

  @override
  String get activityEmpty => 'Aucune activité récente';

  @override
  String get activityLoading => 'Chargement de l\'activité';

  @override
  String get activityFailed => 'Impossible de charger l\'activité';

  @override
  String activityRank(int rank, String beatmap) {
    return 'Rang #$rank sur $beatmap';
  }

  @override
  String activityRankLost(String beatmap) {
    return 'Première place perdue sur $beatmap';
  }

  @override
  String activityMedal(String medal) {
    return 'Médaille « $medal » débloquée';
  }

  @override
  String activityPlaycount(String beatmap, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# fois',
      one: '# fois',
    );
    return '$beatmap a été jouée $_temp0';
  }

  @override
  String activityApproved(String beatmapset, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'ranked': 'classée',
      'approved': 'approuvée',
      'qualified': 'qualifiée',
      'loved': 'ajoutée aux Loved',
      'other': 'mise à jour',
    });
    return '$beatmapset a été $_temp0';
  }

  @override
  String activityUpload(String beatmapset) {
    return 'Nouvelle beatmap $beatmapset publiée';
  }

  @override
  String activityUpdate(String beatmapset) {
    return '$beatmapset mise à jour';
  }

  @override
  String activityRevive(String beatmapset) {
    return '$beatmapset ressuscitée du cimetière';
  }

  @override
  String activityDelete(String beatmapset) {
    return '$beatmapset a été supprimée';
  }

  @override
  String get activitySupportFirst => 'Premier soutien à osu! (osu!supporter)';

  @override
  String get activitySupportAgain => 'Soutient de nouveau osu!';

  @override
  String get activitySupportGift => 'osu!supporter reçu en cadeau';

  @override
  String activityUsernameChange(String previous, String current) {
    return 'Pseudo changé : $previous → $current';
  }

  @override
  String profileFollowers(int count) {
    return 'Abonnés : $count';
  }

  @override
  String profileMappingFollowers(int count) {
    return 'Abonnés aux beatmaps : $count';
  }

  @override
  String get hubTitle => 'osu!';

  @override
  String get changelogTitle => 'Changements';

  @override
  String get changelogLoading => 'Chargement des changements';

  @override
  String get changelogEmpty => 'Aucun changement pour le moment';

  @override
  String get changelogFailed => 'Impossible de charger les changements';

  @override
  String get changelogAllStreams => 'Tous';

  @override
  String changelogUsers(String count) {
    return '$count joueurs';
  }

  @override
  String get changelogTypeAdd => 'Ajouté';

  @override
  String get changelogTypeFix => 'Corrigé';

  @override
  String get changelogTypeMisc => 'Modifié';

  @override
  String get changelogOpenLink => 'Ouvrir dans le navigateur';

  @override
  String get settingsCacheEnabled => 'Utiliser le cache';

  @override
  String get eventsTitle => 'Événements';

  @override
  String get eventsLoading => 'Chargement des événements';

  @override
  String get eventsEmpty => 'Aucun événement pour le moment';

  @override
  String get eventsFailed => 'Impossible de charger les événements';

  @override
  String get eventsFilter => 'Type d\'événement';

  @override
  String get eventsAll => 'Tous les événements';

  @override
  String get eventsRanks => 'Classements';

  @override
  String get eventsMedals => 'Médailles';

  @override
  String get eventsBeatmaps => 'Beatmaps';

  @override
  String get eventsSupporters => 'Supporters et pseudos';

  @override
  String get wikiTitle => 'Wiki';

  @override
  String get wikiLoading => 'Chargement du wiki';

  @override
  String get wikiFailed => 'Impossible de charger le wiki';

  @override
  String get wikiNotFound => 'Article introuvable';

  @override
  String get wikiShownInEnglish =>
      'Pas encore traduit ; l\'article anglais est affiché.';

  @override
  String get wikiSearchHint => 'Article du wiki';

  @override
  String get wikiSearchHelp => 'Guides, règles, modes de jeu et tout sur osu!.';

  @override
  String get wikiNoResults => 'Aucun article trouvé';

  @override
  String get eventsLoadOlder => 'Charger plus ancien';

  @override
  String get changelogShowText => 'Afficher le texte';

  @override
  String get webPageLoading => 'Chargement de la page';

  @override
  String get webPageFailed => 'Impossible de charger la page';

  @override
  String get webPageOpenInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get eventsGroupEmpty => 'Aucun parmi les événements chargés';

  @override
  String get eventsGroupHint =>
      'Le filtre ne porte que sur les événements chargés. Chargez-en de plus anciens pour remonter plus loin.';

  @override
  String get forumTitle => 'Forum';

  @override
  String get forumLoading => 'Chargement du forum';

  @override
  String get forumFailed => 'Impossible de charger le forum';

  @override
  String get forumNotFound => 'Ce forum ou ce sujet n\'est pas disponible';

  @override
  String get forumEmpty => 'Aucun sujet pour le moment';

  @override
  String get forumSubforums => 'Sous-forums';

  @override
  String get forumTopics => 'Sujets';

  @override
  String get forumPinned => 'Épinglé';

  @override
  String get forumAnnouncement => 'Annonce';

  @override
  String get forumLocked => 'Verrouillé';

  @override
  String forumReplies(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString réponses',
      one: '$countString réponse',
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
      other: '$countString vues',
      one: '$countString vue',
    );
    return '$_temp0';
  }

  @override
  String get forumPostUnavailable => 'Ce message ne peut pas être affiché ici';

  @override
  String get settingsImages => 'Images';

  @override
  String get navigationHome => 'Accueil';

  @override
  String get dailyLeaderboardFinal => 'Classement final';

  @override
  String get packsTitle => 'Packs de beatmaps';

  @override
  String get packTitle => 'Pack de beatmaps';

  @override
  String get packsLoading => 'Chargement des packs';

  @override
  String get packsFailed => 'Impossible de charger les packs';

  @override
  String get packsNotFound => 'Ce pack n\'est pas disponible';

  @override
  String get packsEmpty => 'Aucun pack pour le moment';

  @override
  String get packsType => 'Type de pack';

  @override
  String get packsAllModes => 'Tous les modes';

  @override
  String get packsNoDiffReduction =>
      'Les mods de réduction de difficulté ne comptent pas';

  @override
  String packsSets(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString beatmapsets',
      one: '$countString beatmapset',
    );
    return '$_temp0';
  }

  @override
  String get packsTypeStandard => 'Standard';

  @override
  String get packsTypeFeatured => 'Featured Artist';

  @override
  String get packsTypeTournament => 'Tournoi';

  @override
  String get packsTypeLoved => 'Project Loved';

  @override
  String get packsTypeChart => 'Spotlights';

  @override
  String get packsTypeTheme => 'Thème';

  @override
  String get packsTypeArtist => 'Artiste/Album';

  @override
  String get packsHintStandard => 'Maps classées dans l’ordre de sortie';

  @override
  String get packsHintFeatured => 'Musique sous licence des artistes osu!';

  @override
  String get packsHintTournament => 'Mappools des tournois officiels';

  @override
  String get packsHintLoved => 'Classiques choisis par la communauté';

  @override
  String get packsHintChart => 'Maps des classements saisonniers';

  @override
  String get packsHintTheme => 'Maps sur un même thème';

  @override
  String get packsHintArtist => 'Un artiste ou un album';

  @override
  String get commentsSortTitle => 'Trier les commentaires';

  @override
  String get packsFilter => 'Nom ou tag, ex. S1500';

  @override
  String packsOpenTag(String tag) {
    return 'Ouvrir le pack $tag';
  }

  @override
  String get packsFilterEmpty => 'Aucun résultat parmi les packs chargés';

  @override
  String get packsLoadMore => 'Charger plus de packs';

  @override
  String get rulesetTitle => 'Mode de jeu';
}
