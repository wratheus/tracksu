import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/pages/authorization_page.dart';
import 'package:tracksu/src/session/session_controller.dart';

final class GuestShell extends StatelessWidget {
  const GuestShell({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionStatus sessionStatus = DepsScope.of(context)
        .sessionController
        .status;
    final ({String actionLabel, String description}) content =
        switch (sessionStatus) {
          SessionStatus.signedOut => (
            actionLabel: 'Sign in with osu!',
            description: 'Browse public osu! data as a guest. Signing in will add account features.',
          ),
          SessionStatus.authenticated => (
            actionLabel: 'Sign in with another account',
            description: 'You are signed in. Public browsing stays available without an account.',
          ),
        };

    return Scaffold(
      appBar: AppBar(title: const Text('Tracksu')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Guest mode'),
              const SizedBox(height: 12),
              Text(content.description, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const LoginScreen(startAuthorizationOnOpen: true),
                    ),
                  );
                },
                child: Text(content.actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
