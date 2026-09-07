import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class AccountActions extends StatefulWidget {
  const AccountActions({super.key});

  @override
  State<AccountActions> createState() => _AccountActionsState();
}

final class _AccountActionsState extends State<AccountActions> {
  bool _isLoggingOut = false;

  Future<void> _selectLocale(_LocaleSelection selection) async {
    final Locale? locale = switch (selection) {
      _LocaleSelection.system => null,
      _LocaleSelection.english => const Locale('en'),
      _LocaleSelection.russian => const Locale('ru'),
      _LocaleSelection.german => const Locale('de'),
      _LocaleSelection.french => const Locale('fr'),
      _LocaleSelection.spanish => const Locale('es'),
      _LocaleSelection.japanese => const Locale('ja'),
      _LocaleSelection.chinese => const Locale('zh'),
    };
    try {
      await DepsScope.of(context).localeController.select(locale);
    } on Object {
      if (mounted) {
        UiFeedback.snack(context, message: context.t.languageChangeFailed);
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
        await DepsScope.of(context).appRouter.openCurrentProfile(context);
      case _AccountSelection.signOut:
        setState(() => _isLoggingOut = true);
        try {
          await DepsScope.of(context).authRepository.logout();
        } on Object {
          if (mounted) {
            UiFeedback.snack(context, message: context.t.signOutFailed);
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
    final SessionController session = DepsScope.of(context).sessionController;
    return StreamBuilder<SessionStatus>(
      stream: session.statusChanges,
      initialData: session.status,
      builder: (BuildContext context, AsyncSnapshot<SessionStatus> snapshot) =>
          _buildActions(context, snapshot.data == SessionStatus.authenticated),
    );
  }

  Widget _buildActions(BuildContext context, bool authenticated) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.german,
                  child: Text(context.t.germanLanguage),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.french,
                  child: Text(context.t.frenchLanguage),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.spanish,
                  child: Text(context.t.spanishLanguage),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.japanese,
                  child: Text(context.t.japaneseLanguage),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.chinese,
                  child: Text(context.t.chineseLanguage),
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

enum _LocaleSelection {
  system,
  english,
  russian,
  german,
  french,
  spanish,
  japanese,
  chinese,
}

enum _AccountSelection { signIn, myProfile, signOut }
