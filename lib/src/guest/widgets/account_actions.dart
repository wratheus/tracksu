import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu/src/profile/data/osu_profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_repository_impl.dart';
import 'package:tracksu/src/profile/domain/profile_repository.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class AccountActions extends StatefulWidget {
  const AccountActions({super.key});

  @override
  State<AccountActions> createState() => _AccountActionsState();
}

final class _AccountActionsState extends State<AccountActions> {
  bool _isLoggingOut = false;
  ProfileRepository? _profileRepository;
  StreamSubscription<SessionStatus>? _sessionSubscription;
  Uri? _avatar;
  int _avatarEpoch = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profileRepository != null) return;
    final deps = DepsScope.of(context);
    _profileRepository = ProfileRepositoryImpl(
      remoteSource: OsuProfileRemoteSource(
        restClient: deps.restClient,
        publicRestClient: deps.publicRestClient,
      ),
    );
    _sessionSubscription = deps.sessionController.statusChanges.listen(
      (SessionStatus status) => unawaited(_loadAvatar(status)),
    );
    unawaited(_loadAvatar(deps.sessionController.status));
  }

  Future<void> _loadAvatar(SessionStatus status) async {
    final int epoch = ++_avatarEpoch;
    _profileRepository?.cancelPending();
    if (_avatar != null && mounted) setState(() => _avatar = null);
    if (status != SessionStatus.authenticated) return;
    try {
      final profile = await _profileRepository!.getCurrentProfile(
        ruleset: ProfileRuleset.osu,
      );
      if (mounted && epoch == _avatarEpoch) {
        setState(() => _avatar = profile.avatarUri);
      }
    } on Object {
      // Identity decoration must not block the account menu on API failure.
    }
  }

  @override
  void dispose() {
    _avatarEpoch++;
    _profileRepository?.cancelPending();
    unawaited(_sessionSubscription?.cancel());
    super.dispose();
  }

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
      case _AccountSelection.mediaSettings:
        await DepsScope.of(context).appRouter.openSettings(context);
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
        UiIconButton.standard(
          tooltip: context.t.settingsTitle,
          icon: Icons.settings_outlined,
          onPressed: () =>
              DepsScope.of(context).appRouter.openSettings(context),
        ),
        PopupMenuButton<_LocaleSelection>(
          tooltip: context.t.languageSelection,
          icon: const Icon(Icons.language),
          onSelected: _selectLocale,
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<_LocaleSelection>>[
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.system,
                  child: _LanguageLabel(label: context.t.systemLanguage),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.english,
                  child: _LanguageLabel(
                    label: context.t.englishLanguage,
                    countryCode: 'GB',
                  ),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.russian,
                  child: _LanguageLabel(
                    label: context.t.russianLanguage,
                    countryCode: 'RU',
                  ),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.german,
                  child: _LanguageLabel(
                    label: context.t.germanLanguage,
                    countryCode: 'DE',
                  ),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.french,
                  child: _LanguageLabel(
                    label: context.t.frenchLanguage,
                    countryCode: 'FR',
                  ),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.spanish,
                  child: _LanguageLabel(
                    label: context.t.spanishLanguage,
                    countryCode: 'ES',
                  ),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.japanese,
                  child: _LanguageLabel(
                    label: context.t.japaneseLanguage,
                    countryCode: 'JP',
                  ),
                ),
                PopupMenuItem<_LocaleSelection>(
                  value: _LocaleSelection.chinese,
                  child: _LanguageLabel(
                    label: context.t.chineseLanguage,
                    countryCode: 'CN',
                  ),
                ),
              ],
        ),
        PopupMenuButton<_AccountSelection>(
          enabled: !_isLoggingOut,
          tooltip: _isLoggingOut ? context.t.signingOut : context.t.account,
          icon: authenticated && _avatar != null
              ? UiAvatar.small(
                  name: context.t.account,
                  image: NetworkImage(_avatar.toString()),
                )
              : Icon(
                  authenticated ? Icons.account_circle : Icons.person_outline,
                ),
          onSelected: _selectAccount,
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<_AccountSelection>>[
                PopupMenuItem<_AccountSelection>(
                  value: _AccountSelection.mediaSettings,
                  child: UiText.bodyMedium(context.t.settingsTitle),
                ),
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

enum _AccountSelection { signIn, myProfile, signOut, mediaSettings }

/// Flags are decorative locale hints, never a substitute for a language name.
final class _LanguageLabel extends StatelessWidget {
  const _LanguageLabel({required this.label, this.countryCode});
  final String label;
  final String? countryCode;

  @override
  Widget build(BuildContext context) => Row(
    spacing: UiSpace.md,
    children: <Widget>[
      ExcludeSemantics(
        child: countryCode == null
            ? const Icon(Icons.language, size: 24)
            : OsuCountryFlag(code: countryCode!, label: label),
      ),
      Expanded(child: UiText.bodyMedium(label)),
    ],
  );
}
