import 'package:flutter/material.dart';
import 'package:tracksu/src/pages/authorization_page.dart';
import 'package:tracksu/src/guest/presentation/guest_shell.dart';

final class TracksuAppRouter {
  const TracksuAppRouter({this.initialOAuthCallbackUri});

  static const _oauthCallbackRoute = '/oauth-callback';

  final Uri? initialOAuthCallbackUri;

  String get initialRoute =>
      initialOAuthCallbackUri == null ? '/' : _oauthCallbackRoute;

  Future<void> openLogin(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(startAuthorizationOnOpen: true),
      ),
    );
  }

  Route<void> onGenerateRoute(RouteSettings settings) {
    if (settings.name == _oauthCallbackRoute) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            LoginScreen(initialCallbackUri: initialOAuthCallbackUri),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const GuestShell(),
    );
  }
}
