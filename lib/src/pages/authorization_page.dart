import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/auth/domain/oauth_callback.dart';
import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';
import 'package:tracksu/src/guest/presentation/guest_shell.dart';
import 'package:tracksu/src/utils/color_contrasts.dart' as colors;
import 'package:tracksu_storage/tracksu_storage.dart';
import 'package:url_launcher/url_launcher.dart';

final class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.initialCallbackUri,
    this.startAuthorizationOnOpen = false,
  });

  final Uri? initialCallbackUri;
  final bool startAuthorizationOnOpen;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends State<LoginScreen>
    with WidgetsBindingObserver {
  final OAuthCallbackParser _callbackParser = const OAuthCallbackParser();

  StreamSubscription<Uri>? _callbackSubscription;
  Timer? _returnFallbackTimer;
  OAuthCallbackLinkSource? _callbackLinkSource;
  String? _expectedState;
  var _hasStartedAutomaticAuthorization = false;
  var _isCompletingLogin = false;
  var _isOpeningAuthorization = false;
  var _wasInExternalAuthorization = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

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
    unawaited(_handleInitialCallback());

    if (widget.startAuthorizationOnOpen && !_hasStartedAutomaticAuthorization) {
      _hasStartedAutomaticAuthorization = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_startAuthorization());
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _returnFallbackTimer?.cancel();
    unawaited(_callbackSubscription?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (_isOpeningAuthorization) {
          _wasInExternalAuthorization = true;
        }
        break;
      case AppLifecycleState.resumed:
        _scheduleReturnFallback();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _handleInitialCallback() async {
    final Uri? initialCallbackUri = widget.initialCallbackUri;
    if (initialCallbackUri == null) {
      return;
    }

    final OAuthTransactionStore transactionStore = DepsScope.of(context)
        .oauthTransactionStore;

    try {
      final PendingOAuthTransaction? transaction = await transactionStore
          .read();
      if (transaction == null || _isTransactionExpired(transaction)) {
        await transactionStore.clear();
        _showError('This authorization request has expired. Try again.');
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _expectedState = transaction.state;
        _isOpeningAuthorization = true;
      });
      await _handleIncomingUri(initialCallbackUri);
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
    _returnFallbackTimer?.cancel();
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
    final OAuthTransactionStore transactionStore = DepsScope.of(context)
        .oauthTransactionStore;

    try {
      await transactionStore.write(
        PendingOAuthTransaction(
          state: state,
          startedAt: DateTime.now().toUtc(),
        ),
      );
    } on Object {
      _showError('Unable to prepare osu! authorization.');
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _expectedState = state;
      _errorMessage = null;
      _isOpeningAuthorization = true;
      _wasInExternalAuthorization = false;
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
    final dependencies = DepsScope.of(context);
    setState(() {
      _isCompletingLogin = true;
    });

    try {
      await dependencies.authRepository.exchangeAuthorizationCode(code: code);
      await dependencies.oauthTransactionStore.clear();
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const GuestShell()),
        (Route<dynamic> route) => false,
      );
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
      _wasInExternalAuthorization = false;
    });
    unawaited(DepsScope.of(context).oauthTransactionStore.clear());
  }

  bool _isTransactionExpired(PendingOAuthTransaction transaction) {
    return DateTime.now().toUtc().difference(transaction.startedAt) >
        const Duration(minutes: 10);
  }

  void _scheduleReturnFallback() {
    if (!_wasInExternalAuthorization ||
        !_isOpeningAuthorization ||
        _isCompletingLogin) {
      return;
    }

    _wasInExternalAuthorization = false;
    _returnFallbackTimer?.cancel();
    _returnFallbackTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || !_isOpeningAuthorization || _isCompletingLogin) {
        return;
      }

      _showError('Authorization was not completed. Try again.');
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
              if (isBusy) ...<Widget>[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _isCompletingLogin ? 'Signing in...' : 'Opening osu!...',
                  textAlign: TextAlign.center,
                ),
              ],
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
