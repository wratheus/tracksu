import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Debug builds print what a Bloc reports through `addError`, so a block
/// that turns into an error notice says why in the console. Release builds
/// stay silent.
final class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) debugPrint('[${bloc.runtimeType}] $error');
  }
}
