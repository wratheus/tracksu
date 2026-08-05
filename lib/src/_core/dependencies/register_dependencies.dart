import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tracksu/src/auth/data/app_links_oauth_callback_link_source.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/network/osu_api_headers_interceptor.dart';
import 'package:tracksu/src/_core/router/app_router.dart';
import 'package:tracksu/src/profile/data/osu_profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_repository_impl.dart';
import 'package:tracksu_network/tracksu_network.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

Future<DepsContainer> registerDependencies() {
  final RestClient restClient = HttpRestClient(
    client: http.Client(),
    baseUri: Uri.https('osu.ppy.sh', '/api/v2'),
    interceptors: const <RestClientInterceptor>[OsuApiHeadersInterceptor()],
  );

  return Future<DepsContainer>.value(
    DepsContainer(
      appRouter: const TracksuAppRouter(),
      oauthCallbackLinkSource: AppLinksOAuthCallbackLinkSource(),
      profileRepository: ProfileRepositoryImpl(
        remoteSource: OsuProfileRemoteSource(restClient: restClient),
      ),
      restClient: restClient,
      tokenStore: FlutterSecureTokenStore(
        storage: const FlutterSecureStorage(),
      ),
    ),
  );
}
