import 'package:flutter/material.dart';
import 'package:tracksu/src/pages/login_page.dart';

final class TracksuAppRouter {
  const TracksuAppRouter();

  String get initialRoute => '/';

  Route<void> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => LoginPageWidget(),
    );
  }
}
