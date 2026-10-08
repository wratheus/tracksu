import 'package:url_launcher/url_launcher.dart';

/// Opens web links without leaving Tracksu: an in-app browser sheet
/// (SFSafariViewController on iOS, Custom Tabs on Android) with the system's
/// own address bar, Done button and Safari/Chrome features. No cookies or
/// tokens of the app are shared with it.
///
/// Video sites open in their own app when installed. Non-web schemes and a
/// failed in-app sheet fall back to the system handler. OAuth sign-in and the
/// share composer keep their own launch modes and do not use this.
abstract final class ExternalLinks {
  static const Set<String> _appHosts = <String>{
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'youtu.be',
  };

  static Future<bool> open(Uri uri) async {
    final bool web = uri.isScheme('https') || uri.isScheme('http');
    if (web && !_appHosts.contains(uri.host.toLowerCase())) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
          return true;
        }
      } on Object {
        // Fall through to the system handler below.
      }
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
