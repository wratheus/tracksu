import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/main.dart';
import 'package:tracksu/src/session/session_controller.dart';

final class GuestShell extends StatelessWidget {
  const GuestShell({super.key});

  @override
  Widget build(BuildContext context) =>
      const ProfileMain(actions: _AccountActions());
}

final class _AccountActions extends StatefulWidget {
  const _AccountActions();

  @override
  State<_AccountActions> createState() => _AccountActionsState();
}

final class _AccountActionsState extends State<_AccountActions> {
  bool _isLoggingOut = false;

  Future<void> _selectLocale(_LocaleSelection selection) async {
    final Locale? locale = switch (selection) {
      _LocaleSelection.system => null,
      _LocaleSelection.english => const Locale('en'),
      _LocaleSelection.russian => const Locale('ru'),
    };
    try {
      await DepsScope.of(context).localeController.select(locale);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.t.languageChangeFailed)));
      }
    }
  }

  Future<void> _selectAccount(_AccountSelection selection) async {
    if (_isLoggingOut) {
      return;
    }
    switch (selection) {
      case _AccountSelection.signIn:
        await DepsScope.of(context).appRouter.openLogin(context);
      case _AccountSelection.myProfile:
        context.read<ProfileBloc>().add(const CurrentProfileLoadRequested());
      case _AccountSelection.signOut:
        setState(() => _isLoggingOut = true);
        context.read<ProfileBloc>().add(const ProfileCleared());
        try {
          await DepsScope.of(context).authRepository.logout();
        } on Object {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(context.t.signOutFailed)));
          }
        } finally {
          if (mounted) {
            setState(() => _isLoggingOut = false);
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool authenticated =
        DepsScope.of(context).sessionController.status ==
        SessionStatus.authenticated;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          tooltip: context.t.rankingsTitle,
          icon: const Icon(Icons.leaderboard),
          onPressed: () async =>
              DepsScope.of(context).appRouter.openRankings(context),
        ),
        PopupMenuButton<_LocaleSelection>(
          tooltip: context.t.languageSelection,
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
        PopupMenuButton<_AccountSelection>(
          enabled: !_isLoggingOut,
          tooltip: _isLoggingOut ? context.t.signingOut : context.t.account,
          icon: Icon(
            authenticated ? Icons.account_circle : Icons.person_outline,
          ),
          onSelected: _selectAccount,
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<_AccountSelection>>[
                if (authenticated)
                  PopupMenuItem<_AccountSelection>(
                    value: _AccountSelection.myProfile,
                    child: Text(context.t.viewMyProfile),
                  ),
                PopupMenuItem<_AccountSelection>(
                  value: _AccountSelection.signIn,
                  child: Text(
                    authenticated
                        ? context.t.signInWithAnotherAccount
                        : context.t.signInWithOsu,
                  ),
                ),
                if (authenticated)
                  PopupMenuItem<_AccountSelection>(
                    value: _AccountSelection.signOut,
                    child: Text(context.t.signOut),
                  ),
              ],
        ),
      ],
    );
  }
}

enum _LocaleSelection { system, english, russian }

enum _AccountSelection { signIn, myProfile, signOut }
