import 'package:app_links/app_links.dart';
import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';

final class AppLinksOAuthCallbackLinkSource implements OAuthCallbackLinkSource {
  AppLinksOAuthCallbackLinkSource() : _appLinks = AppLinks();

  final AppLinks _appLinks;

  @override
  Future<Uri?> getInitialUri() => _appLinks.getInitialLink();

  @override
  Stream<Uri> get uriStream => _appLinks.uriLinkStream;
}
