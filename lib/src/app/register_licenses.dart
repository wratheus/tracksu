import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Asset notices are not automatically discovered with dependency licenses.
void registerAssetLicenses() {
  LicenseRegistry.addLicense(() async* {
    final String text = await rootBundle.loadString('assets/licenses/exo2.txt');
    yield LicenseEntryWithLineBreaks(const <String>['Exo 2'], text);
  });
  LicenseRegistry.addLicense(() async* {
    final String text = await rootBundle.loadString(
      'assets/licenses/osu_legacy_flags.txt',
    );
    yield LicenseEntryWithLineBreaks(const <String>['osu! legacy flags'], text);
  });
}
