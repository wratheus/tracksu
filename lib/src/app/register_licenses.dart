import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Asset notices are not automatically discovered with dependency licenses.
void registerAssetLicenses() {
  LicenseRegistry.addLicense(() async* {
    final String text = await rootBundle.loadString(
      'assets/licenses/unicode_cldr.txt',
    );
    yield LicenseEntryWithLineBreaks(const <String>['Unicode CLDR'], text);
  });
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
  LicenseRegistry.addLicense(() async* {
    final String text = await rootBundle.loadString(
      'assets/licenses/osu_mod_icons.txt',
    );
    yield LicenseEntryWithLineBreaks(const <String>['osu! mod icons'], text);
  });
  LicenseRegistry.addLicense(() async* {
    final String text = await rootBundle.loadString(
      'assets/licenses/audio_decode_codecs.txt',
    );
    yield LicenseEntryWithLineBreaks(const <String>[
      'stb_vorbis',
      'minimp3',
    ], text);
  });
}
