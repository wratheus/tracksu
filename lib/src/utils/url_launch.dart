import 'package:url_launcher/url_launcher.dart';

Future<void> launchUniversalLink(Uri url) async {
  if (await canLaunchUrl(url)) {
    final bool nativeAppLaunch =
    await launchUrl(url);
    if (!nativeAppLaunch) {
      await launchUrl(url);
    }
  }
}