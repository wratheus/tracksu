import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/pages/authorization_page.dart';
import 'package:tracksu/src/profile/presentation/profile_main.dart';
import 'package:tracksu/src/session/session_controller.dart';

final class GuestShell extends StatefulWidget {
  const GuestShell({super.key});

  @override
  State<GuestShell> createState() => _GuestShellState();
}

final class _GuestShellState extends State<GuestShell> {
  var _isLoggingOut = false;
  String? _logoutErrorMessage;

  Future<void> _selectLocale(_LocaleSelection selection) {
    final Locale? locale = switch (selection) {
      _LocaleSelection.system => null,
      _LocaleSelection.english => const Locale('en'),
      _LocaleSelection.russian => const Locale('ru'),
    };
    return DepsScope.of(context).localeController.select(locale);
  }

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
          _logoutErrorMessage = context.t.signOutFailed;
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
            actionLabel: context.t.signInWithOsu,
            description: context.t.guestSignedOutDescription,
          ),
          SessionStatus.authenticated => (
            actionLabel: context.t.signInWithAnotherAccount,
            description: context.t.guestSignedInDescription,
          ),
        };

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.appTitle),
        actions: <Widget>[
          PopupMenuButton<_LocaleSelection>(
            icon: const Icon(Icons.language),
            onSelected: _selectLocale,
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_LocaleSelection>>[
                  PopupMenuItem<_LocaleSelection>(
                    value: _LocaleSelection.system,
                    child: Text(context.t.systemLanguage),
                  ),
                  PopupMenuItem<_LocaleSelection>(
                    value: _LocaleSelection.english,
                    child: Text(context.t.englishLanguage),
                  ),
                  PopupMenuItem<_LocaleSelection>(
                    value: _LocaleSelection.russian,
                    child: Text(context.t.russianLanguage),
                  ),
                ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(context.t.guestModeTitle),
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProfileMain(),
                      ),
                    );
                  },
                  child: Text(context.t.viewMyProfile),
                ),
                TextButton(
                  onPressed: _isLoggingOut ? null : _logout,
                  child: Text(
                    _isLoggingOut ? context.t.signingOut : context.t.signOut,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _LocaleSelection { system, english, russian }
