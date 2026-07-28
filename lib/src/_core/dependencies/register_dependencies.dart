import 'package:http/http.dart' as http;
import 'package:tracksu/src/auth/data/app_links_oauth_callback_link_source.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/router/app_router.dart';
import 'package:tracksu_network/tracksu_network.dart';

Future<DepsContainer> registerDependencies() {
  return Future<DepsContainer>.value(
    DepsContainer(
      appRouter: const TracksuAppRouter(),
      oauthCallbackLinkSource: AppLinksOAuthCallbackLinkSource(),
      restClient: HttpRestClient(
        client: http.Client(),
        baseUri: Uri.https('osu.ppy.sh'),
      ),
    ),
  );
}
