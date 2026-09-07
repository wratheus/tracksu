import 'package:tracksu/src/auth/data/oauth_client_credentials.dart';
import 'package:tracksu/src/auth/domain/auth_repository.dart';
import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';
import 'package:tracksu/src/_core/router/app_router.dart';
import 'package:tracksu/src/_core/l10n/locale_controller.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu_network/tracksu_network.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

final class DepsContainer {
  const DepsContainer({
    required this.appRouter,
    required this.localeController,
    required this.authRepository,
    required this.oauthClientCredentials,
    required this.oauthCallbackLinkSource,
    required this.oauthRestClient,
    required this.oauthTransactionStore,
    required this.publicRestClient,
    required this.restClient,
    required this.sessionController,
    required this.tokenStore,
  });

  final TracksuAppRouter appRouter;
  final LocaleController localeController;
  final AuthRepository authRepository;
  final OAuthClientCredentials oauthClientCredentials;
  final OAuthCallbackLinkSource oauthCallbackLinkSource;
  final RestClient oauthRestClient;
  final OAuthTransactionStore oauthTransactionStore;
  final RestClient publicRestClient;
  final RestClient restClient;
  final SessionController sessionController;
  final TokenStore tokenStore;

  void close() {
    appRouter.dispose();
    sessionController.dispose();
    localeController.dispose();
    restClient.close();
    publicRestClient.close();
    oauthRestClient.close();
  }
}
