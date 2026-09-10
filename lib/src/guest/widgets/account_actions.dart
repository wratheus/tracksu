import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/preferences/language_picker.dart';
import 'package:tracksu/src/_shared/preferences/sign_out_action.dart';
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
  bool _busy = false;
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

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selectAccount(_AccountSelection selection) => _run(() async {
    final deps = DepsScope.of(context);
    switch (selection) {
      case _AccountSelection.settings:
        await deps.appRouter.openSettings(context);
      case _AccountSelection.signIn:
        await deps.appRouter.openLogin(context);
      case _AccountSelection.myProfile:
        await deps.appRouter.openCurrentProfile(context);
      case _AccountSelection.signOut:
        await SignOutAction.show(context);
    }
  });

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
          onPressed: _busy
              ? null
              : () => _run(
                  () => DepsScope.of(context).appRouter.openSettings(context),
                ),
        ),
        UiIconButton.standard(
          tooltip: context.t.languageSelection,
          icon: Icons.language,
          onPressed: _busy
              ? null
              : () => _run(() => LanguagePicker.show(context)),
        ),
        PopupMenuButton<_AccountSelection>(
          enabled: !_busy,
          tooltip: context.t.account,
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
                  value: _AccountSelection.settings,
                  child: _AccountMenuLabel(
                    label: context.t.settingsTitle,
                    icon: Icons.settings_outlined,
                  ),
                ),
                if (authenticated)
                  PopupMenuItem<_AccountSelection>(
                    value: _AccountSelection.myProfile,
                    child: _AccountMenuLabel(
                      label: context.t.viewMyProfile,
                      icon: Icons.person_outline,
                    ),
                  ),
                PopupMenuItem<_AccountSelection>(
                  value: _AccountSelection.signIn,
                  child: _AccountMenuLabel(
                    icon: Icons.login,
                    label: authenticated
                        ? context.t.signInWithAnotherAccount
                        : context.t.signInWithOsu,
                  ),
                ),
                if (authenticated)
                  PopupMenuItem<_AccountSelection>(
                    value: _AccountSelection.signOut,
                    child: _AccountMenuLabel(
                      label: context.t.signOut,
                      icon: Icons.logout,
                    ),
                  ),
              ],
        ),
      ],
    );
  }
}

enum _AccountSelection { signIn, myProfile, signOut, settings }

final class _AccountMenuLabel extends StatelessWidget {
  const _AccountMenuLabel({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    spacing: UiSpace.md,
    children: <Widget>[
      Icon(icon),
      Expanded(child: UiText.bodyMedium(label)),
    ],
  );
}
