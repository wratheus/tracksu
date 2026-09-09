import 'dart:convert';

import 'package:flutter/services.dart';

abstract interface class RankingCountriesLocalSource {
  Future<Map<String, dynamic>> load();
}

final class AssetRankingCountriesLocalSource
    implements RankingCountriesLocalSource {
  const AssetRankingCountriesLocalSource();

  @override
  Future<Map<String, dynamic>> load() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );
    final Object? names = jsonDecode(
      await rootBundle.loadString('assets/models/countries.json'),
    );
    final RegExp flagPath = RegExp(
      r'^assets/icon_country_flags/([A-Z]{2})\.png$',
    );
    return <String, dynamic>{
      'names': names,
      'codes': <String>[
        for (final String path in manifest.listAssets())
          if (flagPath.firstMatch(path) case final RegExpMatch match)
            match.group(1)!,
      ],
    };
  }
}
