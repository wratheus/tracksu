import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tracksu/src/_shared/ruleset/ruleset_controller.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:http/http.dart' as http;
import 'package:tracksu/src/auth/data/app_links_oauth_callback_link_source.dart';
import 'package:tracksu/src/auth/data/auth_repository_impl.dart';
import 'package:tracksu/src/auth/data/local_osu_oauth_client_credentials.dart';
import 'package:tracksu/src/auth/data/oauth_client_credentials.dart';
import 'package:tracksu/src/auth/data/osu_oauth_remote_source.dart';
import 'package:tracksu/src/auth/data/public_access_repository_impl.dart';
import 'package:tracksu/src/_core/network/osu_public_authorization_interceptor.dart';
import 'package:tracksu/src/auth/domain/auth_repository.dart';
import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/network/osu_authorization_interceptor.dart';
import 'package:tracksu/src/_core/network/osu_api_headers_interceptor.dart';
import 'package:tracksu/src/_core/l10n/locale_controller.dart';
import 'package:tracksu/src/_core/theme/theme_controller.dart';
import 'package:tracksu/src/_core/router/app_router.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu_network/tracksu_network.dart';
import 'package:tracksu_storage/tracksu_storage.dart';
import 'package:tracksu/src/_shared/sharing/share_service.dart';
import 'package:tracksu/src/_shared/content/content_media_controller.dart';
import 'package:tracksu/src/_shared/audio/audio_playback_controller.dart';
import 'package:tracksu/src/_shared/media/cache_preference_controller.dart';
import 'package:tracksu/src/_shared/media/data/media_cache_repository.dart';

Future<DepsContainer> registerDependencies() async {
  const FlutterSecureStorage storage = FlutterSecureStorage();
  final TokenStore tokenStore = FlutterSecureTokenStore(storage: storage);
  final LocaleController localeController = LocaleController(
    localeStore: FlutterSecureLocaleStore(storage: storage),
  );
  await localeController.restore();
  final ThemeController themeController = ThemeController(
    store: FlutterSecureThemeStore(storage: storage),
  );
  await themeController.restore();
  final RulesetController rulesetController = RulesetController(
    store: FlutterSecureRulesetStore(storage: storage),
  );
  await rulesetController.restore();
  final MediaCacheRepository mediaCache = MediaCacheRepository();
  final ContentMediaController contentMediaController = ContentMediaController(
    repository: mediaCache,
    store: FlutterSecureContentMediaStore(storage: storage),
  );
  await contentMediaController.restore();
  final OAuthTransactionStore oauthTransactionStore =
      FlutterSecureOAuthTransactionStore(storage: storage);
  final OAuthCallbackLinkSource oauthCallbackLinkSource =
      AppLinksOAuthCallbackLinkSource();
  final Uri? initialOAuthCallbackUri = await oauthCallbackLinkSource
      .getInitialUri();
  final SessionController sessionController = SessionController(
    tokenStore: tokenStore,
  );
  await sessionController.restore();

  final OAuthClientCredentials oauthClientCredentials =
      const LocalOsuOAuthClientCredentials();
  final RestClient oauthRestClient = HttpRestClient(
    client: http.Client(),
    baseUri: Uri.https('osu.ppy.sh'),
  );
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteSource: OsuOAuthRemoteSource(
      clientCredentials: oauthClientCredentials,
      restClient: oauthRestClient,
    ),
    sessionController: sessionController,
  );

  final RestClient restClient = HttpRestClient(
    client: http.Client(),
    baseUri: Uri.https('osu.ppy.sh', '/api/v2'),
    interceptors: <RestClientInterceptor>[
      OsuApiHeadersInterceptor(
        languageCode: () => localeController.effectiveLanguageCode,
      ),
      OsuAuthorizationInterceptor(
        authRepository: authRepository,
        tokenProvider: sessionController,
      ),
    ],
  );

  final RestClient publicRestClient = HttpRestClient(
    client: http.Client(),
    baseUri: Uri.https('osu.ppy.sh', '/api/v2'),
    interceptors: <RestClientInterceptor>[
      OsuApiHeadersInterceptor(
        languageCode: () => localeController.effectiveLanguageCode,
      ),
      OsuPublicAuthorizationInterceptor(
        repository: PublicAccessRepositoryImpl(
          remoteSource: OsuOAuthRemoteSource(
            clientCredentials: oauthClientCredentials,
            restClient: oauthRestClient,
          ),
        ),
      ),
    ],
  );

  final PageCache pageCache = PageCache(
    identityRevision: () => sessionController.identityRevision,
  );
  // Cached pages hold API text in the previous language: drop them when the
  // language changes so the next visit loads localized data.
  localeController.addListener(pageCache.clear);
  final AudioPlaybackController audioPlaybackController =
      AudioPlaybackController(repository: mediaCache);
  final CachePreferenceController cachePreference = CachePreferenceController(
    store: FlutterSecureCachePreferenceStore(storage: storage),
    pageCache: pageCache,
    mediaCache: mediaCache,
    audio: audioPlaybackController,
  );
  await cachePreference.restore();

  return DepsContainer(
    mediaCache: mediaCache,
    audioPlaybackController: audioPlaybackController,
    cachePreference: cachePreference,
    pageCache: pageCache,
    appRouter: TracksuAppRouter(
      initialOAuthCallbackUri: initialOAuthCallbackUri,
    ),
    localeController: localeController,
    themeController: themeController,
    rulesetController: rulesetController,
    contentMediaController: contentMediaController,
    shareService: ShareService(),
    authRepository: authRepository,
    oauthClientCredentials: oauthClientCredentials,
    oauthCallbackLinkSource: oauthCallbackLinkSource,
    oauthRestClient: oauthRestClient,
    oauthTransactionStore: oauthTransactionStore,
    publicRestClient: publicRestClient,
    restClient: restClient,
    sessionController: sessionController,
    tokenStore: tokenStore,
  );
}
