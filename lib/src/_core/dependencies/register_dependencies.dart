import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final ContentMediaController contentMediaController = ContentMediaController(
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
      const OsuApiHeadersInterceptor(),
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
      const OsuApiHeadersInterceptor(),
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

  return DepsContainer(
    pageCache: PageCache(
      identityRevision: () => sessionController.identityRevision,
    ),
    appRouter: TracksuAppRouter(
      initialOAuthCallbackUri: initialOAuthCallbackUri,
    ),
    localeController: localeController,
    themeController: themeController,
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
