import 'package:url_launcher/url_launcher.dart';

/// Leaves the app for the system handler: the browser for web pages, the
/// YouTube app for videos, mail for `mailto:`. The app itself never acts as a
/// browser (ADR-009); in-app viewing goes through `AppLinks`.
abstract final class ExternalLinks {
  static Future<bool> openInBrowser(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}
