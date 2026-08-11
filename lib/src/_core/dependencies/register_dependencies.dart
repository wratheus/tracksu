import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tracksu/src/auth/data/app_links_oauth_callback_link_source.dart';
import 'package:tracksu/src/auth/data/auth_repository_impl.dart';
import 'package:tracksu/src/auth/data/local_osu_oauth_client_credentials.dart';
import 'package:tracksu/src/auth/data/oauth_client_credentials.dart';
import 'package:tracksu/src/auth/data/osu_oauth_remote_source.dart';
import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/network/osu_authorization_interceptor.dart';
import 'package:tracksu/src/_core/network/osu_api_headers_interceptor.dart';
import 'package:tracksu/src/_core/router/app_router.dart';
import 'package:tracksu/src/profile/data/osu_profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_repository_impl.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu_network/tracksu_network.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

Future<DepsContainer> registerDependencies() async {
  const FlutterSecureStorage storage = FlutterSecureStorage();
  final TokenStore tokenStore = FlutterSecureTokenStore(storage: storage);
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

  final RestClient restClient = HttpRestClient(
    client: http.Client(),
    baseUri: Uri.https('osu.ppy.sh', '/api/v2'),
    interceptors: <RestClientInterceptor>[
      const OsuApiHeadersInterceptor(),
      OsuAuthorizationInterceptor(tokenProvider: sessionController),
    ],
  );

  return DepsContainer(
    appRouter: TracksuAppRouter(
      initialOAuthCallbackUri: initialOAuthCallbackUri,
    ),
    authRepository: AuthRepositoryImpl(
      remoteSource: OsuOAuthRemoteSource(
        clientCredentials: oauthClientCredentials,
        restClient: oauthRestClient,
      ),
      sessionController: sessionController,
    ),
    oauthClientCredentials: oauthClientCredentials,
    oauthCallbackLinkSource: oauthCallbackLinkSource,
    oauthRestClient: oauthRestClient,
    oauthTransactionStore: oauthTransactionStore,
    profileRepository: ProfileRepositoryImpl(
      remoteSource: OsuProfileRemoteSource(restClient: restClient),
    ),
    restClient: restClient,
    sessionController: sessionController,
    tokenStore: tokenStore,
  );
}
