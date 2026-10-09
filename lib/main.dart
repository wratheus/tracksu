import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/app/app_bloc_observer.dart';
import 'package:tracksu/src/app/bootstrap_app.dart';
import 'package:tracksu/src/app/register_licenses.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerAssetLicenses();
  Bloc.observer = const AppBlocObserver();
  runApp(const BootstrapApp());
}
