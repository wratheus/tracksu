// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get uiCatalogTitle => 'UI kit';

  @override
  String get uiCatalogTheme => 'Cambiar tema';

  @override
  String get uiCatalogTypography => 'Tipografía y superficies';

  @override
  String get uiCatalogButtons => 'Botones';

  @override
  String get uiCatalogInputs => 'Entrada y selección';

  @override
  String get uiCatalogFeedback => 'Mensajes';

  @override
  String get uiCatalogNavigation => 'Navegación';

  @override
  String get uiCatalogConfirmMessage =>
      'Esto solo confirma una acción de vista previa. No se modificarán la cuenta ni los datos.';

  @override
  String get newsTitle => 'Noticias';

  @override
  String get newsRefresh => 'Actualizar noticias';

  @override
  String get newsEmpty => 'No hay noticias disponibles.';

  @override
  String get newsLoadMore => 'Cargar más noticias';

  @override
  String get newsLoading => 'Cargando noticias…';

  @override
  String get newsKeepingContent =>
      'Se sigue mostrando el contenido cargado anteriormente.';

  @override
  String get newsNotFound => 'Esta noticia no está disponible.';

  @override
  String get newsCancelled => 'Se canceló la carga de noticias.';

  @override
  String get newsAccessDenied => 'No se puede acceder a las noticias.';

  @override
  String get newsInvalidResponse => 'No se pudo leer la respuesta de noticias.';

  @override
  String get newsUnavailable =>
      'Las noticias no están disponibles temporalmente.';

  @override
  String get newsLinkFailed => 'No se pudo abrir este enlace.';

  @override
  String get newsOriginal => 'Abrir original';

  @override
  String get newsReaderNotice =>
      'Modo de lectura de texto. Las imágenes, los medios y el formato original están disponibles en el sitio web de osu!.';

  @override
  String get spotlightsTitle => 'Spotlights';

  @override
  String get spotlightsChoose => 'Elegir un Spotlight';

  @override
  String get spotlightsShowRanking => 'Mostrar el Spotlight seleccionado';

  @override
  String get spotlightsEmpty => 'No hay Spotlights disponibles.';

  @override
  String get spotlightsMaps => 'Conjuntos de beatmaps';

  @override
  String get spotlightsNoMaps =>
      'No hay conjuntos de beatmaps para este Spotlight y modo de juego.';

  @override
  String get spotlightsRankingLimit =>
      'Clasificación del Spotlight · hasta 40 jugadores';

  @override
  String get spotlightsNotFound =>
      'Este Spotlight o modo de juego no está disponible.';

  @override
  String get appTitle => 'Tracksu';

  @override
  String get guestModeTitle => 'Modo invitado';

  @override
  String get guestSignedOutDescription =>
      'Consulta los datos públicos de osu! como invitado. Inicia sesión para acceder a las funciones de cuenta.';

  @override
  String get guestSignedInDescription =>
      'Has iniciado sesión. Los datos públicos siguen estando disponibles sin cuenta.';

  @override
  String get signInWithOsu => 'Iniciar sesión con osu!';

  @override
  String get signInWithAnotherAccount => 'Iniciar sesión con otra cuenta';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signingOut => 'Cerrando sesión…';

  @override
  String get signOutFailed => 'No se pudo cerrar sesión. Inténtalo de nuevo.';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String get englishLanguage => 'Inglés';

  @override
  String get russianLanguage => 'Ruso';

  @override
  String get loginToOsu => 'Iniciar sesión en osu!';

  @override
  String get signingIn => 'Iniciando sesión…';

  @override
  String get openingOsu => 'Abriendo osu!…';

  @override
  String get continueWithOsu => 'Continuar con osu!';

  @override
  String get authorizationExpired =>
      'Esta solicitud de autorización ha caducado. Inténtalo de nuevo.';

  @override
  String get authorizationResponseUnavailable =>
      'No se pudo recibir la respuesta de autorización.';

  @override
  String get authorizationResponseMismatch =>
      'La respuesta de autorización no coincide con este intento de inicio de sesión.';

  @override
  String get authorizationCancelled =>
      'La autorización se canceló o se rechazó.';

  @override
  String get authorizationResponseInvalid =>
      'La respuesta de autorización no es válida.';

  @override
  String get authorizationPreparationFailed =>
      'No se pudo preparar la autorización de osu!.';

  @override
  String get authorizationLaunchFailed =>
      'No se pudo abrir la autorización de osu!.';

  @override
  String get authorizationCompletionFailed =>
      'No se pudo completar la autorización.';

  @override
  String get authorizationIncomplete =>
      'La autorización no se completó. Inténtalo de nuevo.';

  @override
  String get viewMyProfile => 'Ver mi perfil';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSearchHint => 'Nombre de usuario o ID';

  @override
  String get profileSearchInvalid =>
      'Introduce un nombre de usuario válido o un ID positivo.';

  @override
  String get rulesetOsu => 'osu!';

  @override
  String get rulesetTaiko => 'taiko';

  @override
  String get rulesetFruits => 'catch';

  @override
  String get rulesetMania => 'mania';

  @override
  String get profileLoading => 'Cargando perfil…';

  @override
  String get profileUnavailable =>
      'El perfil no está disponible. Inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

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

    return 'Rendimiento: $ppString';
  }

  @override
  String profileCountry(String country) {
    return 'País: $country';
  }

  @override
  String profileAccuracy(double accuracy) {
    final intl.NumberFormat accuracyNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 2,
        );
    final String accuracyString = accuracyNumberFormat.format(accuracy);

    return 'Precisión: $accuracyString %';
  }

  @override
  String profilePlayCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Partidas jugadas: $countString';
  }

  @override
  String get profileSearchIntroduction =>
      'Busca a un jugador de osu! para ver su perfil y estadísticas. No necesitas iniciar sesión.';

  @override
  String get profileSearchHelp =>
      'Añade @ delante de un nombre de usuario formado solo por números.';

  @override
  String get profileSearch => 'Buscar jugador';

  @override
  String get profileRefreshing => 'Actualizando perfil';

  @override
  String get profileRefresh => 'Actualizar';

  @override
  String get profileShowingPreviousData =>
      'No se pudo actualizar. Se muestran los datos cargados anteriormente.';

  @override
  String get profileNotFound =>
      'No se encontró al jugador. Comprueba el nombre o el ID.';

  @override
  String get profileAccessDenied =>
      'osu! denegó el acceso. Si es tu perfil, prueba a iniciar sesión de nuevo.';

  @override
  String get profileRateLimited =>
      'Demasiadas solicitudes. Espera antes de volver a intentarlo.';

  @override
  String get profileConnectionFailed =>
      'No se pudo conectar. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get profileInvalidResponse =>
      'El servidor devolvió una respuesta de perfil no compatible.';

  @override
  String get profileOnline => 'En línea';

  @override
  String get profileOffline => 'Desconectado';

  @override
  String get profileSupporter => 'osu!supporter';

  @override
  String get profileNoStatistics =>
      'Aún no hay estadísticas para este modo de juego.';

  @override
  String get profileUnranked => 'Sin posición global';

  @override
  String profileGlobalRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Posición global: #$rankString';
  }

  @override
  String profileCountryRank(int rank) {
    final intl.NumberFormat rankNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String rankString = rankNumberFormat.format(rank);

    return 'Posición nacional: #$rankString';
  }

  @override
  String profilePlayTime(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return 'Tiempo jugado: $hoursString h';
  }

  @override
  String profileMaximumCombo(int combo) {
    final intl.NumberFormat comboNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String comboString = comboNumberFormat.format(combo);

    return 'Combo máximo: $comboString';
  }

  @override
  String get languageChangeFailed => 'No se pudo guardar el idioma.';

  @override
  String get languageSelection => 'Idioma';

  @override
  String get account => 'Cuenta';

  @override
  String get scoresTitle => 'Resultados';

  @override
  String get scoresBest => 'Mejores';

  @override
  String get scoresRecent => 'Recientes';

  @override
  String get scoresRefresh => 'Actualizar resultados';

  @override
  String get scoresLoading => 'Cargando resultados…';

  @override
  String get scoresEmpty =>
      'No hay resultados para este jugador y modo de juego.';

  @override
  String get scoresLoadMore => 'Cargar más';

  @override
  String get scoresKeepingContent =>
      'Se siguen mostrando los resultados cargados anteriormente.';

  @override
  String get scoresCancelled => 'Se canceló la carga.';

  @override
  String get scoresNotFound => 'No se encontraron resultados.';

  @override
  String get scoresAccessDenied => 'osu! denegó el acceso a los resultados.';

  @override
  String get scoresInvalidResponse =>
      'El servidor devolvió una respuesta de resultados no compatible.';

  @override
  String get scoresUnavailable =>
      'Los resultados no están disponibles temporalmente.';

  @override
  String get scoresNoMods => 'Sin mods';

  @override
  String get scoresNoPp => 'PP no disponibles';

  @override
  String get scoresFailedPlay => 'Partida fallida';

  @override
  String scoresBeatmap(int id) {
    return 'Beatmap n.º $id';
  }

  @override
  String scoresGrade(String grade) {
    return 'Grado: $grade';
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

    return 'Puntuación: $totalString';
  }

  @override
  String scoresMods(String mods) {
    return 'Mods: $mods';
  }

  @override
  String scoresPlayedAt(String date) {
    return 'Jugado: $date';
  }

  @override
  String get beatmapsTitle => 'Beatmaps';

  @override
  String get beatmapsMostPlayed => 'Más jugados';

  @override
  String get beatmapsFavourite => 'Favoritos';

  @override
  String get beatmapsRanked => 'Clasificados';

  @override
  String get beatmapsPending => 'Pendientes';

  @override
  String get beatmapsGraveyard => 'Cementerio';

  @override
  String get beatmapsLoved => 'Loved';

  @override
  String get beatmapsGuest => 'Dificultades invitadas';

  @override
  String get beatmapsNominated => 'Nominados';

  @override
  String get beatmapsRefresh => 'Actualizar beatmaps';

  @override
  String get beatmapsEmpty => 'No hay beatmaps en esta categoría.';

  @override
  String get beatmapsLoadMore => 'Cargar más beatmaps';

  @override
  String get beatmapsLoading => 'Cargando beatmaps…';

  @override
  String get beatmapsKeepingContent =>
      'No se pudo actualizar. Se siguen mostrando los beatmaps cargados anteriormente.';

  @override
  String get beatmapsCancelled => 'Se canceló la carga.';

  @override
  String get beatmapsNotFound =>
      'No se encontraron los beatmaps de este jugador.';

  @override
  String get beatmapsAccessDenied =>
      'No se puede acceder a los beatmaps en este momento.';

  @override
  String get beatmapsInvalidResponse =>
      'El servidor devolvió una respuesta de beatmaps inesperada.';

  @override
  String get beatmapsUnavailable =>
      'No se pudieron cargar los beatmaps. Inténtalo de nuevo.';

  @override
  String beatmapsSetFallback(int id) {
    return 'Conjunto de beatmaps n.º $id';
  }

  @override
  String beatmapsMapFallback(int id) {
    return 'Beatmap n.º $id';
  }

  @override
  String beatmapsPlayCount(int count) {
    return 'Partidas: $count';
  }

  @override
  String get beatmapTitle => 'Beatmap';

  @override
  String get beatmapNotFound => 'No se encontró el beatmap.';

  @override
  String get beatmapAccessDenied =>
      'No se puede acceder a este beatmap o a su clasificación.';

  @override
  String get beatmapInvalidResponse => 'Respuesta de beatmap inesperada.';

  @override
  String get beatmapUnavailable =>
      'No se pudieron cargar los datos del beatmap.';

  @override
  String get beatmapLeaderboard => 'Mejores resultados';

  @override
  String get beatmapRefreshLeaderboard => 'Actualizar resultados';

  @override
  String get beatmapNoScores => 'No hay resultados disponibles.';

  @override
  String beatmapLeaderboardPlayer(int position, String name) {
    return '#$position · $name';
  }

  @override
  String beatmapPlayerId(int id) {
    return 'Jugador n.º $id';
  }

  @override
  String beatmapCreator(String name) {
    return 'Creado por $name';
  }

  @override
  String get beatmapRefresh => 'Actualizar beatmap';

  @override
  String get beatmapDifficulties => 'Dificultades';

  @override
  String get beatmapNoDifficulties => 'No hay dificultades disponibles.';

  @override
  String beatmapDifficultyInfo(String mode, double stars, int seconds) {
    return '$mode · $stars ★ · $seconds s';
  }

  @override
  String get rankingsTitle => 'Clasificaciones';

  @override
  String get rankingsScore => 'Puntuación';

  @override
  String get rankingsRefresh => 'Actualizar clasificación';

  @override
  String get rankingsEmpty => 'No se encontraron jugadores.';

  @override
  String get rankingsLoadMore => 'Cargar más jugadores';

  @override
  String get rankingsLoading => 'Cargando clasificación…';

  @override
  String get rankingsKeepingContent =>
      'No se pudo actualizar. Se muestra la clasificación cargada anteriormente.';

  @override
  String get rankingsCancelled => 'Carga cancelada.';

  @override
  String get rankingsNotFound => 'No se encontró la clasificación.';

  @override
  String get rankingsAccessDenied => 'No se puede acceder a la clasificación.';

  @override
  String get rankingsInvalidResponse =>
      'Respuesta de clasificación inesperada.';

  @override
  String get rankingsUnavailable => 'No se pudo cargar la clasificación.';

  @override
  String rankingsRankedScore(int score) {
    return 'Puntuación clasificada: $score';
  }

  @override
  String get rankingsCountry => 'Código de país';

  @override
  String get rankingsCountryHint =>
      'Dos letras, p. ej., JP o US; déjalo vacío para ver todos los países.';

  @override
  String get rankingsCountryInvalid =>
      'Introduce un código de país de dos letras.';

  @override
  String get rankingsApply => 'Aplicar país';

  @override
  String get rankingsWorldwide => 'Todo el mundo';

  @override
  String get rankingsAllKeys => 'Cualquier número de teclas';

  @override
  String get germanLanguage => 'Alemán';

  @override
  String get frenchLanguage => 'Francés';

  @override
  String get spanishLanguage => 'Español';

  @override
  String get japaneseLanguage => 'Japonés';

  @override
  String get chineseLanguage => 'Chino (simplificado)';
}
