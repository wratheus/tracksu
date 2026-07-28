import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';
import 'package:tracksu/src/_core/router/app_router.dart';

final class DepsContainer {
  const DepsContainer({
    required this.appRouter,
    required this.oauthCallbackLinkSource,
  });

  final TracksuAppRouter appRouter;
  final OAuthCallbackLinkSource oauthCallbackLinkSource;
}
