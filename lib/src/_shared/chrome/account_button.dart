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
/// own profile and sign out when authenticated; settings are always the last
/// item (the bar keeps two actions).
final class AccountButton extends StatefulWidget {
  const AccountButton({super.key});

  @override
  State<AccountButton> createState() => _AccountButtonState();
}

final class _AccountButtonState extends State<AccountButton> {
  /// Never waits for the opened page: a pushed page's future completes only
  /// on pop, and one removed another way (a tab re-tap resets the branch)
  /// left the button disabled for good. The menu closes on selection, so a
  /// second tap cannot double-fire.
  void _select(_AccountSelection selection) {
    final DepsContainer deps = DepsScope.of(context);
    unawaited(switch (selection) {
      _AccountSelection.signIn => deps.appRouter.openLogin(context),
      _AccountSelection.myProfile => deps.appRouter.openCurrentProfile(context),
      _AccountSelection.signOut => SignOutAction.show(context),
      _AccountSelection.settings => deps.appRouter.openSettings(context),
    });
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
  }) => IconButton(
    tooltip: context.t.account,
    onPressed: () => unawaited(_open(context, authenticated, image)),
    icon: authenticated && image != null
        ? UiAvatar.small(
            name: context.t.account,
            image: AppMedia.image(context, image),
          )
        : Icon(authenticated ? Icons.account_circle : Icons.person_outline),
  );

  /// The account sheet, in the app's sheet style instead of a stock popup
  /// menu: who is signed in, then option rows.
  Future<void> _open(
    BuildContext context,
    bool authenticated,
    Uri? image,
  ) async {
    final String? username = _AccountAvatar.of(DepsScope.of(context)).username;
    final _AccountSelection? selection = await UiModal.sheet<_AccountSelection>(
      context,
      title: context.t.account,
      builder: (BuildContext sheetContext) => _AccountSheet(
        authenticated: authenticated,
        username: username,
        image: image,
      ),
    );
    if (selection != null && mounted) _select(selection);
  }
}

final class _AccountSheet extends StatelessWidget {
  const _AccountSheet({
    required this.authenticated,
    required this.username,
    required this.image,
  });
  final bool authenticated;
  final String? username;
  final Uri? image;

  void _pick(BuildContext context, _AccountSelection selection) {
    if (ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop(selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    Widget row(_AccountSelection value, String label, IconData icon) =>
        UiOptionRow(
          label: label,
          icon: icon,
          onTap: () => _pick(context, value),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.sm,
        children: <Widget>[
          if (authenticated)
            Padding(
              padding: const EdgeInsets.only(bottom: UiSpace.sm),
              child: Row(
                spacing: UiSpace.md,
                children: <Widget>[
                  UiAvatar.small(
                    name: username ?? context.t.account,
                    image: image == null
                        ? null
                        : AppMedia.image(context, image),
                  ),
                  Expanded(
                    child: UiText.titleMedium(
                      username ?? context.t.account,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.verified_user_outlined, color: colors.primary),
                ],
              ),
            ),
          if (authenticated)
            row(
              _AccountSelection.myProfile,
              context.t.viewMyProfile,
              Icons.person_outline,
            )
          else
            row(_AccountSelection.signIn, context.t.signInWithOsu, Icons.login),
          row(
            _AccountSelection.settings,
            context.t.settingsTitle,
            Icons.settings_outlined,
          ),
          if (authenticated)
            row(_AccountSelection.signOut, context.t.signOut, Icons.logout),
        ],
      ),
    );
  }
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

  /// The signed-in player's name for the account sheet; null until loaded.
  String? username;
  StreamSubscription<SessionStatus>? _subscription;
  int _epoch = 0;

  Future<void> _load(SessionStatus status) async {
    final int epoch = ++_epoch;
    _repository.cancelPending();
    uri.value = null;
    username = null;
    if (status != SessionStatus.authenticated) return;
    try {
      final profile = await _repository.getCurrentProfile(
        ruleset: ProfileRuleset.osu,
      );
      if (epoch == _epoch) {
        username = profile.username;
        uri.value = profile.avatarUri;
      }
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

enum _AccountSelection { signIn, myProfile, signOut, settings }
