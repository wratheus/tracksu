import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/auth/bloc/bloc.dart';
import 'package:tracksu/src/auth/domain/authorization.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class AuthorizationScreen extends StatefulWidget {
  const AuthorizationScreen({required this.params, super.key});
  final AuthorizationParams params;
  @override
  State<AuthorizationScreen> createState() => _AuthorizationScreenState();
}

final class _AuthorizationScreenState extends State<AuthorizationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthorizationBloc>().add(
          AuthorizationStarted(widget.params),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final AuthorizationEvent? event = switch (state) {
      AppLifecycleState.inactive ||
      AppLifecycleState.paused => const AuthorizationLeftApp(),
      AppLifecycleState.resumed => const AuthorizationReturned(),
      AppLifecycleState.detached || AppLifecycleState.hidden => null,
    };
    if (event != null) context.read<AuthorizationBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<AuthorizationBloc, AuthorizationState>(
        listenWhen: (_, AuthorizationState state) =>
            state is AuthorizationSuccessState,
        listener: (BuildContext context, _) =>
            DepsScope.of(context).appRouter.finishAuthorization(context),
        child: Scaffold(
          appBar: AppBar(title: UiText.titleLarge(context.t.loginToOsu)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(UiSpace.xl),
              child: BlocBuilder<AuthorizationBloc, AuthorizationState>(
                builder: (BuildContext context, AuthorizationState state) {
                  final bool busy = switch (state) {
                    AuthorizationIdleState() ||
                    AuthorizationFailureState() => false,
                    AuthorizationPreparingState() ||
                    AuthorizationWaitingState() ||
                    AuthorizationCompletingState() ||
                    AuthorizationSuccessState() => true,
                  };
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (busy)
                        UiContentState.loading(
                          title:
                              state is AuthorizationCompletingState ||
                                  state is AuthorizationSuccessState
                              ? context.t.signingIn
                              : context.t.openingOsu,
                        ),
                      if (state case AuthorizationFailureState(:final failure))
                        UiContentState.error(
                          title: switch (failure) {
                            AuthorizationFailure.expired =>
                              context.t.authorizationExpired,
                            AuthorizationFailure.responseUnavailable =>
                              context.t.authorizationResponseUnavailable,
                            AuthorizationFailure.mismatch =>
                              context.t.authorizationResponseMismatch,
                            AuthorizationFailure.cancelled =>
                              context.t.authorizationCancelled,
                            AuthorizationFailure.invalidResponse =>
                              context.t.authorizationResponseInvalid,
                            AuthorizationFailure.preparation =>
                              context.t.authorizationPreparationFailed,
                            AuthorizationFailure.launch =>
                              context.t.authorizationLaunchFailed,
                            AuthorizationFailure.completion =>
                              context.t.authorizationCompletionFailed,
                            AuthorizationFailure.incomplete =>
                              context.t.authorizationIncomplete,
                          },
                        ),
                      UiButton.primary(
                        onPressed: busy
                            ? null
                            : () => context.read<AuthorizationBloc>().add(
                                const AuthorizationRequested(),
                              ),
                        label: context.t.continueWithOsu,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
}
