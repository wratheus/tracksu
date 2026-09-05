import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/auth/bloc/bloc.dart';
import 'package:tracksu/src/auth/data/authorization_repository_impl.dart';
import 'package:tracksu/src/auth/domain/authorization.dart';
import 'package:tracksu/src/auth/widgets/screen.dart';

final class AuthMain extends StatelessWidget {
  const AuthMain({this.params = const AuthorizationParams(), super.key});
  final AuthorizationParams params;
  @override
  Widget build(BuildContext context) => BlocProvider<AuthorizationBloc>(
    create: (_) {
      final dependencies = DepsScope.of(context);
      return AuthorizationBloc(
        repository: AuthorizationRepositoryImpl(
          store: dependencies.oauthTransactionStore,
          clientId: dependencies.oauthClientCredentials.clientId,
        ),
        authRepository: dependencies.authRepository,
        callbacks: dependencies.oauthCallbackLinkSource,
      );
    },
    child: AuthorizationScreen(params: params),
  );
}
