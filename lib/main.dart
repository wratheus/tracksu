import 'package:flutter/widgets.dart';
import 'package:tracksu/src/app/bootstrap_app.dart';
import 'package:tracksu/src/app/register_licenses.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerAssetLicenses();
  runApp(const BootstrapApp());
}
