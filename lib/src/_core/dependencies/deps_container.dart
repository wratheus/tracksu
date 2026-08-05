import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';
import 'package:tracksu/src/_core/router/app_router.dart';
import 'package:tracksu/src/profile/domain/profile_repository.dart';
import 'package:tracksu_network/tracksu_network.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

final class DepsContainer {
  const DepsContainer({
    required this.appRouter,
    required this.oauthCallbackLinkSource,
    required this.profileRepository,
    required this.restClient,
    required this.tokenStore,
  });

  final TracksuAppRouter appRouter;
  final OAuthCallbackLinkSource oauthCallbackLinkSource;
  final ProfileRepository profileRepository;
  final RestClient restClient;
  final TokenStore tokenStore;

  void close() {
    restClient.close();
  }
}
