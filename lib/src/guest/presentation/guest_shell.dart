import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/pages/authorization_page.dart';
import 'package:tracksu/src/session/session_controller.dart';

final class GuestShell extends StatefulWidget {
  const GuestShell({super.key});

  @override
  State<GuestShell> createState() => _GuestShellState();
}

final class _GuestShellState extends State<GuestShell> {
  var _isLoggingOut = false;
  String? _logoutErrorMessage;

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await DepsScope.of(context).authRepository.logout();
    } on Object {
      if (mounted) {
        setState(() {
          _logoutErrorMessage = 'Unable to sign out. Try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

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
              if (_logoutErrorMessage case final String message) ...<Widget>[
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoggingOut
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen(
                              startAuthorizationOnOpen: true,
                            ),
                          ),
                        );
                      },
                child: Text(content.actionLabel),
              ),
              if (sessionStatus == SessionStatus.authenticated) ...<Widget>[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoggingOut ? null : _logout,
                  child: Text(_isLoggingOut ? 'Signing out...' : 'Sign out'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
