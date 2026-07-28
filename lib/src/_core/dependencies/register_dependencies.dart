import 'package:tracksu/src/auth/data/app_links_oauth_callback_link_source.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/router/app_router.dart';

Future<DepsContainer> registerDependencies() {
  return Future<DepsContainer>.value(
    DepsContainer(
      appRouter: const TracksuAppRouter(),
      oauthCallbackLinkSource: AppLinksOAuthCallbackLinkSource(),
    ),
  );
}
