import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/auth/domain/oauth_callback.dart';
import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';
import 'package:tracksu/src/pages/home_page.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/utils/color_contrasts.dart' as colors;
import 'package:tracksu/src/utils/secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

final class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends State<LoginScreen> {
  final OAuthCallbackParser _callbackParser = const OAuthCallbackParser();

  StreamSubscription<Uri>? _callbackSubscription;
  OAuthCallbackLinkSource? _callbackLinkSource;
  String? _expectedState;
  var _isCompletingLogin = false;
  var _isOpeningAuthorization = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_callbackLinkSource != null) {
      return;
    }

    final OAuthCallbackLinkSource callbackLinkSource = DepsScope.of(context)
        .oauthCallbackLinkSource;
    _callbackLinkSource = callbackLinkSource;
    _callbackSubscription = callbackLinkSource.uriStream.listen(
      _onIncomingUri,
      onError: _onCallbackStreamError,
    );
    unawaited(_readInitialUri(callbackLinkSource));
  }

  @override
  void dispose() {
    unawaited(_callbackSubscription?.cancel());
    super.dispose();
  }

  Future<void> _readInitialUri(
    OAuthCallbackLinkSource callbackLinkSource,
  ) async {
    try {
      final Uri? initialUri = await callbackLinkSource.getInitialUri();
      if (initialUri != null) {
        await _handleIncomingUri(initialUri);
      }
    } on Object {
      _showError('Unable to receive the authorization response.');
    }
  }

  void _onIncomingUri(Uri uri) {
    unawaited(_handleIncomingUri(uri));
  }

  void _onCallbackStreamError(Object error, StackTrace stackTrace) {
    _showError('Unable to receive the authorization response.');
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    final OAuthCallbackResult callback = _callbackParser.parse(uri);
    final String? expectedState = _expectedState;

    if (expectedState == null || !_isOpeningAuthorization) {
      return;
    }

    switch (callback) {
      case OAuthAuthorizationCodeCallback(:final code, :final state):
        if (state != expectedState || _isCompletingLogin) {
          _showError(
            'The authorization response did not match this login attempt.',
          );
          return;
        }

        await _completeAuthorization(code);
      case OAuthAuthorizationErrorCallback(:final state):
        if (state != expectedState) {
          _showError(
            'The authorization response did not match this login attempt.',
          );
          return;
        }

        _showError('Authorization was cancelled or refused.');
      case OAuthRejectedCallback():
        _showError('The authorization response is invalid.');
    }
  }

  Future<void> _startAuthorization() async {
    if (_isOpeningAuthorization || _isCompletingLogin) {
      return;
    }

    final String state = _createState();
    final Uri authorizationUri = _createAuthorizationUri(state);

    setState(() {
      _expectedState = state;
      _errorMessage = null;
      _isOpeningAuthorization = true;
    });

    final bool launched = await launchUrl(
      authorizationUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      _showError('Unable to open osu! authorization.');
    }
  }

  Future<void> _completeAuthorization(String code) async {
    setState(() {
      _isCompletingLogin = true;
    });

    try {
      await DepsScope.of(context).authRepository
          .exchangeAuthorizationCode(code: code);
      await _loadUserMeToSecureStorage();
      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute<void>(builder: (_) => HomePage()));
    } on Object {
      _showError('Unable to finish authorization.');
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingLogin = false;
        });
      }
    }
  }

  Future<void> _loadUserMeToSecureStorage() async {
    final Profile profile = await DepsScope.of(context).profileRepository
        .getCurrentProfile(ruleset: ProfileRuleset.osu);
    await UserSecureStorage.setUserMeAvatarFromStorage(
      profile.avatarUri.toString(),
    );
    await UserSecureStorage.setUserMeUsernameFromStorage(profile.username);
  }

  Uri _createAuthorizationUri(String state) {
    return Uri.https('osu.ppy.sh', '/oauth/authorize', <String, String>{
      'client_id': DepsScope.of(context).oauthClientCredentials.clientId,
      'redirect_uri': OAuthCallbackParser.callbackUri,
      'response_type': 'code',
      'scope': 'public identify',
      'state': state,
    });
  }

  String _createState() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(
      32,
      (_) => random.nextInt(256),
      growable: false,
    );

    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = message;
      _isOpeningAuthorization = false;
      _isCompletingLogin = false;
      _expectedState = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy = _isOpeningAuthorization || _isCompletingLogin;

    return Scaffold(
      backgroundColor: colors.Palette.brown.shade200,
      appBar: AppBar(
        backgroundColor: colors.Palette.purple,
        title: const Text('Login to osu!'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isBusy) const CircularProgressIndicator(),
              if (_errorMessage case final String message) ...<Widget>[
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isBusy ? null : _startAuthorization,
                child: const Text('Continue with osu!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
