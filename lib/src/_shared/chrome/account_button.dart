import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/preferences/sign_out_action.dart';
import 'package:tracksu/src/profile/data/osu_profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_repository_impl.dart';
import 'package:tracksu/src/profile/domain/profile_repository.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/session/session_controller.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Account entry point shown on every AppBar: sign in as a guest, or open the
/// own profile, switch account and sign out when authenticated.
final class AccountButton extends StatefulWidget {
  const AccountButton({super.key});

  @override
  State<AccountButton> createState() => _AccountButtonState();
}

final class _AccountButtonState extends State<AccountButton> {
  bool _busy = false;

  Future<void> _select(_AccountSelection selection) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final DepsContainer deps = DepsScope.of(context);
      switch (selection) {
        case _AccountSelection.signIn:
          await deps.appRouter.openLogin(context);
        case _AccountSelection.myProfile:
          await deps.appRouter.openCurrentProfile(context);
        case _AccountSelection.signOut:
          await SignOutAction.show(context);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DepsContainer deps = DepsScope.of(context);
    final SessionController session = deps.sessionController;
    final _AccountAvatar avatar = _AccountAvatar.of(deps);
    return StreamBuilder<SessionStatus>(
      stream: session.statusChanges,
      initialData: session.status,
      builder: (BuildContext context, AsyncSnapshot<SessionStatus> snapshot) =>
          ValueListenableBuilder<Uri?>(
            valueListenable: avatar.uri,
            builder: (BuildContext context, Uri? image, _) => _menu(
              context,
              authenticated: snapshot.data == SessionStatus.authenticated,
              image: image,
            ),
          ),
    );
  }

  Widget _menu(
    BuildContext context, {
    required bool authenticated,
    required Uri? image,
  }) => PopupMenuButton<_AccountSelection>(
    enabled: !_busy,
    tooltip: context.t.account,
    icon: authenticated && image != null
        ? UiAvatar.small(
            name: context.t.account,
            image: AppMedia.image(context, image),
          )
        : Icon(authenticated ? Icons.account_circle : Icons.person_outline),
    onSelected: (_AccountSelection selection) => unawaited(_select(selection)),
    itemBuilder: (BuildContext context) => <PopupMenuEntry<_AccountSelection>>[
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
  );
}

/// The account button now sits on every page, so the avatar is looked up once
/// per session change and shared instead of being fetched by each AppBar.
final class _AccountAvatar {
  _AccountAvatar._(this._session, this._repository) {
    _subscription = _session.statusChanges.listen(
      (SessionStatus status) => unawaited(_load(status)),
    );
    unawaited(_load(_session.status));
  }

  factory _AccountAvatar.of(DepsContainer deps) {
    final _AccountAvatar? current = _instance;
    if (current != null &&
        identical(current._session, deps.sessionController)) {
      return current;
    }
    current?._dispose();
    return _instance = _AccountAvatar._(
      deps.sessionController,
      ProfileRepositoryImpl(
        remoteSource: OsuProfileRemoteSource(
          restClient: deps.restClient,
          publicRestClient: deps.publicRestClient,
        ),
      ),
    );
  }

  static _AccountAvatar? _instance;
  final SessionController _session;
  final ProfileRepository _repository;
  final ValueNotifier<Uri?> uri = ValueNotifier<Uri?>(null);
  StreamSubscription<SessionStatus>? _subscription;
  int _epoch = 0;

  Future<void> _load(SessionStatus status) async {
    final int epoch = ++_epoch;
    _repository.cancelPending();
    uri.value = null;
    if (status != SessionStatus.authenticated) return;
    try {
      final profile = await _repository.getCurrentProfile(
        ruleset: ProfileRuleset.osu,
      );
      if (epoch == _epoch) uri.value = profile.avatarUri;
    } on Object {
      // Identity decoration must not block the account menu on API failure.
    }
  }

  void _dispose() {
    _epoch++;
    _repository.cancelPending();
    unawaited(_subscription?.cancel());
    uri.dispose();
  }
}

enum _AccountSelection { signIn, myProfile, signOut }

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
