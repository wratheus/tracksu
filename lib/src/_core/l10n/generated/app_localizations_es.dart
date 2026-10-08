// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsCacheCalculating => 'Calculando el tamaño de la caché…';

  @override
  String get settingsCacheFailed =>
      'No se pudo acceder a la caché. Inténtalo de nuevo.';

  @override
  String settingsCacheConfirm(String size) {
    return '¿Eliminar $size MB de imágenes y audio? Tu cuenta y ajustes se conservan.';
  }

  @override
  String settingsCacheSize(String size) {
    return '$size MB';
  }

  @override
  String get audioPreview => 'Vista previa de audio';

  @override
  String get audioPlay => 'Reproducir';

  @override
  String get audioPause => 'Pausa';

  @override
  String get audioReplay => 'Repetir';

  @override
  String get audioCancel => 'Cancelar carga';

  @override
  String get audioLoading => 'Cargando audio…';

  @override
  String get audioPlaying => 'Reproduciendo';

  @override
  String get audioPaused => 'En pausa';

  @override
  String get audioCompleted => 'Finalizado';

  @override
  String get audioFailed =>
      'No se pudo reproducir el audio. Comprueba la conexión e inténtalo de nuevo.';

  @override
  String get audioFailedUnavailable =>
      'Esta vista previa de audio ya no está disponible.';

  @override
  String get audioFailedUnsupported =>
      'Este formato de audio no se puede reproducir en este dispositivo.';

  @override
  String get audioFailedFocus =>
      'Otra app está usando el audio. Inténtalo cuando termine.';

  @override
  String get audioFailedUnknown => 'No se pudo reproducir el audio.';

  @override
  String get audioSeek => 'Posición de reproducción';

  @override
  String get teamTitle => 'Equipo';

  @override
  String get teamLoading => 'Cargando equipo…';

  @override
  String get teamNotFound => 'Equipo no encontrado';

  @override
  String get teamAccessDenied =>
      'Este equipo no está disponible para su consulta.';

  @override
  String get teamFailed => 'No se pudo cargar el equipo. Inténtalo de nuevo.';

  @override
  String get teamOpen => 'Reclutamiento abierto';

  @override
  String get teamClosed => 'Reclutamiento cerrado';

  @override
  String teamSlots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plazas libres',
      one: '1 plaza libre',
      zero: 'Sin plazas libres',
    );
    return '$_temp0';
  }

  @override
  String teamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String teamCreated(String date) {
    return 'Creado el $date';
  }

  @override
  String teamDefaultMode(String mode) {
    return 'Modo principal: $mode';
  }

  @override
  String get teamDescription => 'Acerca del equipo';

  @override
  String get teamLeader => 'Líder del equipo';

  @override
  String teamLastVisit(String date) {
    return 'Última conexión: $date';
  }

  @override
  String get scoreGaugeReference =>
      'Escala de referencia de precisión de osu!lazer; SS requiere 100 % (su zona se amplía para hacerla visible). El grado procede del resultado: los fallos, mods y reglas antiguas también pueden influir.';

  @override
  String get settingsCache => 'Caché';

  @override
  String get settingsClearCache => 'Vaciar';

  @override
  String get settingsCacheDescription =>
      'Portadas y vistas previas de audio guardadas en este dispositivo.';

  @override
  String get settingsCacheCleared => 'Caché borrada';

  @override
  String get profileDailyEmpty =>
      'Este jugador aún no ha participado en el desafío diario.';

  @override
  String get aboutTitle => 'Acerca de Tracksu';

  @override
  String get aboutTabApp => 'Acerca de';

  @override
  String get settingsClearCacheTitle => '¿Vaciar la caché?';

  @override
  String get aboutHistoryShort =>
      'Tracksu existe desde 2021 y se ha desarrollado y rehecho varias veces.';

  @override
  String get aboutTabAuthors => 'Autores';

  @override
  String get aboutTabLicenses => 'Licencias';

  @override
  String get aboutRoleAuthor => 'Autor';

  @override
  String get aboutRoleCoauthor => 'Coautor';

  @override
  String get aboutThanksTitle => 'Gracias';

  @override
  String get aboutThanksBody =>
      'A ppy y al equipo de osu! por el juego y su API pública. A la comunidad de osu! por los mapas, los jugadores y las ideas. A los autores de las bibliotecas libres que aparecen en Licencias.';

  @override
  String get aboutDescription =>
      'Explora jugadores, puntuaciones, beatmaps y noticias de osu!.';

  @override
  String get aboutUnofficial =>
      'Un cliente independiente y no oficial, sin afiliación ni respaldo de ppy Pty Ltd.';

  @override
  String get aboutBuild => 'Versión instalada';

  @override
  String get aboutBuildUnavailable =>
      'No se pudo leer la versión de la aplicación instalada.';

  @override
  String aboutVersion(String version, String build) {
    return 'Versión $version · Compilación $build';
  }

  @override
  String get aboutProject => 'Proyecto en GitHub';

  @override
  String get aboutOsu => 'Sitio web de osu!';

  @override
  String get aboutLicensesDescription =>
      'Bibliotecas de código abierto y licencias de recursos';

  @override
  String get licensesIntro =>
      'Tracksu se basa en software de código abierto. Aquí están los paquetes de la app y los textos de licencia que sus autores piden mostrar.';

  @override
  String get licensesSearch => 'Buscar paquetes';

  @override
  String get licensesNoMatch => 'No hay paquetes que coincidan.';

  @override
  String licensesPackageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paquetes',
      one: '$count paquete',
    );
    return '$_temp0';
  }

  @override
  String get aboutLinkFailed => 'No se pudo abrir el enlace.';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Según el sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSaveFailed => 'No se pudo guardar el tema.';

  @override
  String get spotlightsParticipants => 'Participantes';

  @override
  String get spotlightsSearch => 'Nombre, año o ID';

  @override
  String get spotlightsNoMatch => 'No hay Spotlights coincidentes.';

  @override
  String spotlightsStartDate(String date) {
    return 'Fecha de inicio: $date';
  }

  @override
  String spotlightsEndDate(String date) {
    return 'Fecha de fin: $date';
  }

  @override
  String get spotlightsKindMonthly => 'Mensual';

  @override
  String get spotlightsKindBestOf => 'Lo mejor del año';

  @override
  String get spotlightsKindSpecial => 'Especial';

  @override
  String get spotlightsKindTheme => 'Temática';

  @override
  String get spotlightsRulesetUnavailable =>
      'No hay clasificación para este modo de juego.';

  @override
  String get spotlightsRulesetUnavailableHint =>
      'osu! solo mantuvo este Spotlight para algunos modos. Elige otro arriba.';

  @override
  String get spotlightsHomeDescription =>
      'Antiguas clasificaciones de osu!; la última fue en 2020. Los Spotlights ya no se organizan: los reemplazaron las Seasons.';

  @override
  String get spotlightsOpen => 'Archivo de Spotlights';

  @override
  String spotlightsDifficultyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dificultades en el conjunto',
      one: '$count dificultad en el conjunto',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSignOutConfirm =>
      '¿Cerrar sesión en este dispositivo? Tu perfil público de osu! seguirá disponible.';

  @override
  String get medalsLoading => 'Cargando medallas…';

  @override
  String get medalsFailed =>
      'No se pudieron cargar los detalles de las medallas desde osu!. Inténtalo de nuevo.';

  @override
  String get medalsEmpty => 'Aún no hay medallas obtenidas.';

  @override
  String get scoreMiss => 'Fallo';

  @override
  String get scoreFruit => 'Frutas';

  @override
  String get scoreDroplet => 'Gotas';

  @override
  String get scoreTinyDroplet => 'Gotas pequeñas';

  @override
  String get scoreTinyMiss => 'Gotas pequeñas perdidas';

  @override
  String get scoreJudgementPercentNotice =>
      'Los porcentajes corresponden a los juicios mostrados, no al progreso del mapa ni al combo máximo. Se excluyen los ticks de sliders y contadores técnicos legacy.';

  @override
  String get profilePreviousNames => 'Nombres anteriores';

  @override
  String get profileGroups => 'Grupos';

  @override
  String profileTeamTag(String tag) {
    return 'Equipo · $tag';
  }

  @override
  String get profileMedals => 'Medallas';

  @override
  String get profileMedalsView => 'Ver medallas obtenidas';

  @override
  String profileMedalId(int id) {
    return 'Medalla n.º $id';
  }

  @override
  String get profileRankedPlay => 'Juego clasificatorio';

  @override
  String get profileRankedPlayEmpty =>
      'No hay estadísticas clasificatorias para este modo.';

  @override
  String profileRankedPool(int id) {
    return 'Grupo n.º $id';
  }

  @override
  String get profileProvisionalRating => 'Clasificación provisional';

  @override
  String get profileRating => 'Puntuación';

  @override
  String get profileFirstPlaces => 'Primeros puestos';

  @override
  String get profileRankedPoints => 'Puntos de partida';

  @override
  String get profileDailyChallenge => 'Desafío diario';

  @override
  String get profileDailyPlays => 'Desafíos jugados';

  @override
  String get profileDailyCurrent => 'Racha diaria actual';

  @override
  String get profileDailyBest => 'Mejor racha diaria';

  @override
  String get profileWeeklyCurrent => 'Racha semanal actual';

  @override
  String get profileWeeklyBest => 'Mejor racha semanal';

  @override
  String get profileTop10 => 'Resultados en el 10 % superior';

  @override
  String get profileTop50 => 'Resultados en el 50 % superior';

  @override
  String profileDailyUpdated(String date) {
    return 'Última participación: $date';
  }

  @override
  String profileWeeklyUpdated(String date) {
    return 'Última racha semanal: $date';
  }

  @override
  String get shareSystem => 'Otras aplicaciones…';

  @override
  String get shareCopy => 'Copiar enlace';

  @override
  String get shareCopied => 'Enlace copiado';

  @override
  String get shareDestinationNotice =>
      'Elige un destinatario en la aplicación o el navegador que se abra. Nada se publica automáticamente. El enlace lleva a la página pública de osu!; la vista previa depende de la aplicación receptora.';

  @override
  String get shareAction => 'Compartir';

  @override
  String get shareBeatmapAction => 'Compartir mapa';

  @override
  String get shareFailed =>
      'No se pudo abrir el menú para compartir. Inténtalo de nuevo.';

  @override
  String get contentMediaSettings => 'Cargar imágenes';

  @override
  String get contentMediaConsent =>
      'Las portadas y avatares se cargan automáticamente. Desactívalo para ahorrar datos.';

  @override
  String get contentMediaAllow => 'Permitir imágenes';

  @override
  String get contentMediaDecline => 'Ahora no';

  @override
  String get contentMediaDisabled =>
      'Las imágenes están desactivadas. Actívalas en Ajustes.';

  @override
  String get contentMediaSaveFailed =>
      'No se pudo guardar la preferencia. Puede restablecerse al reiniciar la aplicación.';

  @override
  String get contentImageUnsupported =>
      'Esta dirección de imagen no es compatible. Abre la página original.';

  @override
  String get contentImagePaused => 'La carga de la imagen está en pausa.';

  @override
  String get profilePlayHistoryTitle => 'Partidas por mes';

  @override
  String rankingsPosition(int position) {
    final intl.NumberFormat positionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String positionString = positionNumberFormat.format(position);

    return 'Posición n.º $positionString';
  }

  @override
  String get rankingsPositionNotice =>
      'Las posiciones corresponden a esta tabla filtrada, no al rango mundial de PP. El ranking puede cambiar entre páginas; actualiza la lista.';

  @override
  String get rankingsCountrySelection => 'País o región';

  @override
  String get rankingsCountrySearch => 'Nombre del país o código';

  @override
  String get rankingsCountryCatalogHint =>
      'Busca un país por su nombre o código de dos letras. La disponibilidad de la clasificación depende de osu!.';

  @override
  String get rankingsCountryCatalogFailed =>
      'No se pudo cargar la lista de países.';

  @override
  String get rankingsCountryNoMatch => 'No hay países coincidentes.';

  @override
  String get rankingsEnd => 'Fin del ranking disponible.';

  @override
  String get scoreHitsTitle => 'Resultados de golpes';

  @override
  String get scoreHitsExplanation =>
      'Los nombres son los de la API. Los valores ausentes no son cero; los máximos describen una partida perfecta, no un objetivo por fila.';

  @override
  String get scoreHitsAchieved => 'Obtenidos';

  @override
  String get scoreHitsMaximum => 'En una partida perfecta';

  @override
  String get scoreModSettingsTitle => 'Ajustes de mods';

  @override
  String get scoreModSettingsExplanation =>
      'Se conservan los nombres de la API. Solo se muestran los ajustes enviados, sin suponer valores predeterminados.';

  @override
  String get scoreNoModSettings => 'No se enviaron ajustes explícitos.';

  @override
  String get scoreDetailsUnavailable => 'No disponible';

  @override
  String get scoreSettingEnabled => 'Activado';

  @override
  String get scoreSettingDisabled => 'Desactivado';

  @override
  String get beatmapDescription => 'Descripción del mapa';

  @override
  String get contentPageUnavailable =>
      'No se puede mostrar este contenido aquí. Puedes abrir el original.';

  @override
  String get scoreDetailsTitle => 'Detalles del resultado';

  @override
  String get scoreOpenBeatmap => 'Abrir beatmap';

  @override
  String get scoreStandardisedTotal => 'Puntuación estandarizada';

  @override
  String get mapSetPlays => 'Partidas del conjunto';

  @override
  String get mapFavourites => 'Favoritos';

  @override
  String get mapBpm => 'BPM';

  @override
  String get profileReplayHistoryTitle => 'Visualizaciones de replays por mes';

  @override
  String get profileReplayHistoryExplanation =>
      'Se omiten los meses sin observaciones; la falta de datos no significa cero.';

  @override
  String get profileAbout => 'Sobre mí';

  @override
  String get contentPageNotice =>
      'Las imágenes externas siguen tu preferencia guardada. El contenido incrustado se abre en la página original. Sin contenido con formato, el BBCode se muestra como texto plano.';

  @override
  String get contentLinkFailed => 'No se pudo abrir el enlace.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileOverview => 'Resumen';

  @override
  String get profilePpLabel => 'Rendimiento (PP)';

  @override
  String get profileGlobalRankLabel => 'Clasificación mundial';

  @override
  String get profileCountryRankLabel => 'Clasificación nacional';

  @override
  String get profileStatisticsTitle => 'Estadísticas';

  @override
  String get profileAccuracyLabel => 'Precisión';

  @override
  String get profilePlayCountLabel => 'Partidas jugadas';

  @override
  String get profilePlayTimeLabel => 'Tiempo de juego';

  @override
  String get profileComboLabel => 'Combo máximo';

  @override
  String get profileValueUnavailable => 'No disponible';

  @override
  String get profileNotRanked => 'Sin clasificar';

  @override
  String get profileGradesTitle => 'Calificaciones';

  @override
  String get profileRankedScoreLabel => 'Puntuación clasificada';

  @override
  String get profileTotalScoreLabel => 'Puntuación total';

  @override
  String get profileTotalHitsLabel => 'Total de aciertos';

  @override
  String get profileReplaysLabel => 'Repeticiones vistas por otros';

  @override
  String get profileHistoryTitle => 'Historial de clasificación';

  @override
  String get profileHistoryEmpty => 'No hay historial para este modo.';

  @override
  String get profileHistoryExplanation =>
      'Observaciones de la API en orden, no fechas. Los huecos indican rangos no disponibles.';

  @override
  String get profileSwitchingMode =>
      'Cargando el modo seleccionado. Se muestran los datos del modo anterior.';

  @override
  String get profileUpdateFailed =>
      'No se pudo actualizar. Se conservan los datos y el modo anteriores.';

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

    return 'Nivel $levelString';
  }

  @override
  String profileLevelProgress(int progress) {
    final intl.NumberFormat progressNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String progressString = progressNumberFormat.format(progress);

    return '$progressString% hacia el siguiente nivel';
  }

  @override
  String profileHistorySample(int index) {
    final intl.NumberFormat indexNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);

    return 'Observación $indexString';
  }

  @override
  String get navigationSearch => 'Buscar';

  @override
  String get navigationUnavailable => 'Esta página no está disponible.';

  @override
  String get searchClear => 'Borrar búsqueda';

  @override
  String get contentImage => 'Imagen';

  @override
  String get contentImageLoading => 'Cargando imagen…';

  @override
  String get contentImageFailed =>
      'No se pudo cargar la imagen. Puede no estar disponible o superar el tamaño o formato admitidos.';

  @override
  String get contentImageUnavailable =>
      'Esta imagen ya no está disponible en su origen.';

  @override
  String get contentImageNetwork =>
      'No se pudo conectar con el servidor de la imagen. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get contentImageFormat =>
      'Este formato de imagen no se puede mostrar.';

  @override
  String get contentImageTooLarge =>
      'Esta imagen es demasiado grande para mostrarla.';

  @override
  String get contentImageOpen => 'Ampliar imagen';

  @override
  String get contentDisclosure => 'Mostrar contenido oculto';

  @override
  String get contentUnsupported =>
      'Este contenido incrustado está disponible en la página original.';

  @override
  String get contentOriginal => 'Abrir original';

  @override
  String get contentUnavailable =>
      'Contenido no disponible en el lector. Abre el original.';

  @override
  String get uiCatalogMedia => 'Imágenes e insignias';

  @override
  String get uiCatalogCards => 'Tarjetas de jugadores y contenido';

  @override
  String get uiCatalogCharts => 'Gráficos';

  @override
  String get uiCatalogStates => 'Estados del contenido';

  @override
  String get uiCatalogSampleNotice =>
      'Datos de ejemplo, no estadísticas reales. Las imágenes existentes de Tracksu muestran la distribución visual.';

  @override
  String get uiCatalogHistory => 'Historial de clasificación';

  @override
  String get uiCatalogActivity => 'Actividad de juego';

  @override
  String get uiCatalogSinglePoint => 'Una observación';

  @override
  String get uiCatalogFlatSeries => 'Valores constantes';

  @override
  String get uiCatalogOffline => 'Sin conexión';

  @override
  String get uiCatalogNoData => 'Aún no hay datos';

  @override
  String get uiCatalogChartHint =>
      'Toca, arrastra o usa el control deslizante para ver un valor. Los números de rango menores aparecen más arriba.';

  @override
  String get uiMetricPerformance => 'Puntos de rendimiento';

  @override
  String get uiMetricAccuracy => 'Precisión';

  @override
  String get uiMetricGlobalRank => 'Clasificación mundial';

  @override
  String get uiMetricPlayCount => 'Partidas jugadas';

  @override
  String get uiMetricPlayTime => 'Tiempo de juego';

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
      'Las imágenes externas siguen tu preferencia guardada. El contenido incrustado se abre en la página original.';

  @override
  String get spotlightsTitle => 'Spotlights';

  @override
  String get spotlightsChoose => 'Elegir un Spotlight';

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
  String get spotlightsNotFound => 'Este Spotlight no está disponible.';

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
  String get profileSearchHint => 'Nombre o ID';

  @override
  String get profileSearchInvalid =>
      'Introduce un nombre de usuario válido o un ID positivo.';

  @override
  String get rulesetOsu => 'ctd';

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
          decimalDigits: 0,
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
      'Abre un perfil con el nombre exacto o ID del jugador. No necesitas iniciar sesión.';

  @override
  String get profileSearchHelp =>
      'Busca por nombre o introduce un ID exacto. Usa @ para un nombre exacto, incluidos los nombres numéricos.';

  @override
  String get profileOpen => 'Abrir perfil';

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
  String get profileSupporterInfo =>
      'Este jugador tiene osu!supporter: una suscripción voluntaria que mantiene osu! sin anuncios. Los supporters obtienen extras como más amigos, una portada de perfil y descargas de beatmaps en el juego.';

  @override
  String get actionGotIt => 'Entendido';

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
  String get beatmapsCategory => 'Categoría de beatmaps';

  @override
  String get scoresCategory => 'Tipo de resultados';

  @override
  String get beatmapsGroupPlayer => 'Jugador';

  @override
  String get beatmapsGroupMapper => 'Mapper';

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
    return 'Partidas del jugador: $count';
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
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Puntuación clasificada: $scoreString';
  }

  @override
  String get rankingsCountry => 'Código de país';

  @override
  String get rankingsCountryInvalid =>
      'Introduce un código de país de dos letras.';

  @override
  String get rankingsWorldwide => 'Todo el mundo';

  @override
  String get rankingsAllKeys => 'Todas';

  @override
  String get rankingsPlayers => 'Jugadores';

  @override
  String get rankingsTeams => 'Equipos';

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

  @override
  String get scrollToTop => 'Ir arriba';

  @override
  String get dailyTitle => 'Mapa del día';

  @override
  String dailyRemaining(String time) {
    return 'Quedan $time';
  }

  @override
  String dailyParticipants(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString jugadores',
      one: '$countString jugador',
    );
    return '$_temp0';
  }

  @override
  String get dailyNone => 'Ahora no hay desafío diario.';

  @override
  String get dailyLeaderboard => 'Clasificación del día';

  @override
  String get dailyOpenMap => 'Abrir mapa';

  @override
  String get dailyFailed => 'No se pudo cargar el mapa del día.';

  @override
  String get contentVideoPlay => 'Reproducir vídeo';

  @override
  String get contentVideoPause => 'Pausa';

  @override
  String get contentVideoFullscreen => 'Pantalla completa';

  @override
  String get contentVideoExitFullscreen => 'Salir de pantalla completa';

  @override
  String get contentVideoFailed => 'No se pudo reproducir el vídeo.';

  @override
  String get contentEmbedYoutube => 'Ver en YouTube';

  @override
  String contentEmbedOpen(String host) {
    return 'Abrir en $host';
  }

  @override
  String get commentsTitle => 'Comentarios';

  @override
  String commentsTitleCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString comentarios',
      one: '$countString comentario',
    );
    return '$_temp0';
  }

  @override
  String get commentsSortNew => 'Nuevos';

  @override
  String get commentsSortOld => 'Antiguos';

  @override
  String get commentsSortTop => 'Top';

  @override
  String get commentsLoading => 'Cargando comentarios';

  @override
  String get commentsFailed => 'No se pudieron cargar los comentarios.';

  @override
  String get commentsEmpty => 'Aún no hay comentarios.';

  @override
  String get commentsDeleted => 'Comentario eliminado';

  @override
  String get commentsEdited => 'editado';

  @override
  String get commentsPinned => 'Fijado';

  @override
  String get commentsUnknownUser => 'Usuario eliminado';

  @override
  String commentsVotes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString votos',
      one: '$countString voto',
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
      other: '$countString respuestas',
      one: '$countString respuesta',
    );
    return '$_temp0';
  }

  @override
  String get commentsHideReplies => 'Ocultar respuestas';

  @override
  String get commentsMoreReplies => 'Más respuestas';

  @override
  String get commentsJustNow => 'ahora mismo';

  @override
  String commentsMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $countString min',
      one: 'hace $countString min',
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
      other: 'hace $countString h',
      one: 'hace $countString h',
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
      other: 'hace $countString días',
      one: 'hace $countString día',
    );
    return '$_temp0';
  }

  @override
  String get rankingsCountries => 'Países';

  @override
  String rankingsCountryPlayers(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString jugadores activos',
      one: '$countString jugador activo',
    );
    return '$_temp0';
  }

  @override
  String get beatmapSearchTitle => 'Buscar beatmaps';

  @override
  String get beatmapSearchHomeDescription =>
      'Beatmaps de osu! rankeados, loved y otros';

  @override
  String get beatmapSearchHint => 'Título, artista o mapper';

  @override
  String get beatmapSearchStatus => 'Estado del beatmap';

  @override
  String get beatmapSearchLeaderboard => 'Con clasificación';

  @override
  String get beatmapSearchQualified => 'Calificados';

  @override
  String get beatmapSearchWip => 'En progreso';

  @override
  String get beatmapSearchAny => 'Cualquier estado';

  @override
  String get beatmapSearchEmpty => 'No se encontró nada.';

  @override
  String get beatmapSearchFailed => 'No se pudieron buscar beatmaps.';

  @override
  String beatmapSearchFound(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString beatmaps encontrados',
      one: '$countString beatmap encontrado',
    );
    return '$_temp0';
  }

  @override
  String get aboutBuiltWithFlutter => 'Desarrollado con Flutter';

  @override
  String get commentsReply => 'Responder';

  @override
  String get commentsVoteOnSite => 'Votar y responder se hace en osu.ppy.sh';

  @override
  String get dailyHistory => 'Días anteriores';

  @override
  String get dailyHistoryDescription =>
      'Mapas del día anteriores y clasificaciones finales';

  @override
  String get dailyHistoryLimit => 'Hasta 250 días recientes';

  @override
  String get dailyHistoryEmpty => 'No hay días anteriores disponibles';

  @override
  String get dailyPastUnavailable =>
      'El desafío de este día no está disponible';

  @override
  String get leaderboardModsTitle => 'Filtrar por mods';

  @override
  String get leaderboardModsAll => 'Todos los mods';

  @override
  String get leaderboardModsReset => 'Restablecer';

  @override
  String get leaderboardModsApply => 'Aplicar';

  @override
  String get beatmapKeys => 'Teclas';

  @override
  String get beatmapCircleSize => 'Tamaño de círculos (CS)';

  @override
  String get beatmapHpDrain => 'Pérdida de HP';

  @override
  String get beatmapAccuracy => 'Precisión (OD)';

  @override
  String get beatmapApproachRate => 'Velocidad de aparición (AR)';

  @override
  String get beatmapMaxCombo => 'Combo máximo';

  @override
  String get beatmapObjects => 'Objetos';

  @override
  String get beatmapPlays => 'Partidas';

  @override
  String get beatmapPassRate => 'Tasa de aprobación';

  @override
  String get beatmapSearchAnyMode => 'Todos';

  @override
  String get beatmapSearchGenre => 'Género';

  @override
  String get beatmapSearchAnyGenre => 'Cualquier género';

  @override
  String get beatmapSearchLanguage => 'Idioma';

  @override
  String get beatmapSearchAnyLanguage => 'Cualquier idioma';

  @override
  String get genreUnspecified => 'Sin especificar';

  @override
  String get genreVideoGame => 'Videojuego';

  @override
  String get genreAnime => 'Anime';

  @override
  String get genreRock => 'Rock';

  @override
  String get genrePop => 'Pop';

  @override
  String get genreOther => 'Otro';

  @override
  String get genreNovelty => 'Humorística';

  @override
  String get genreHipHop => 'Hip hop';

  @override
  String get genreElectronic => 'Electrónica';

  @override
  String get genreMetal => 'Metal';

  @override
  String get genreClassical => 'Clásica';

  @override
  String get genreFolk => 'Folk';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languageInstrumental => 'Instrumental';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageSwedish => 'Sueco';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageRussian => 'Ruso';

  @override
  String get languagePolish => 'Polaco';

  @override
  String get languageOther => 'Otro';

  @override
  String get languageUnspecified => 'Sin especificar';

  @override
  String get rankingsKudosu => 'Kudosu';

  @override
  String get rankingsKudosuHint =>
      'Clasificación por kudosu totales ganados ayudando a los mappers. Hasta 1000 jugadores.';

  @override
  String rankingsKudosuAvailable(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Kudosu disponibles: $countString';
  }

  @override
  String get unifiedSearchTitle => 'Buscar jugadores y mapas';

  @override
  String get unifiedSearchDescription => 'Jugadores, mapas e ID exactos';

  @override
  String get unifiedSearchMaps => 'Mapas';

  @override
  String get unifiedSearchPrompt => 'Escribe al menos dos caracteres';

  @override
  String get userSearchEmpty => 'No se encontraron jugadores';

  @override
  String get userSearchFailed => 'No se pudieron cargar los jugadores';

  @override
  String get userSearchLimit =>
      'Se muestran los primeros 100 jugadores. Afina la búsqueda.';
}
