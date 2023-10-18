import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:ll/src/data/strain.dart';
import 'package:ll/src/util/safe_json.dart';

Strain _parseLeaflyJson(Map<String, dynamic> rawStrain) {
  final strainSafe = SafeJson(rawStrain);

  final subtitle = strainSafe.get<String>('subtitle');
  final otherNames = subtitle?.replaceAll('aka ', '').split(', ');

  final cannabinoids = {
    'cbc': strainSafe.to('cannabinoids').to('cbc').get<double>('percentile50'),
    'cbd': strainSafe.to('cannabinoids').to('cbd').get<double>('percentile50'),
    'cbg': strainSafe.to('cannabinoids').to('cbg').get<double>('percentile50'),
    'thc': strainSafe.to('cannabinoids').to('thc').get<double>('percentile50'),
    'thcv':
        strainSafe.to('cannabinoids').to('thcv').get<double>('percentile50'),
  };

  final effects = {
    'aroused': strainSafe.to('effects').to('aroused').get<double>('score'),
    'creative': strainSafe.to('effects').to('creative').get<double>('score'),
    'energetic': strainSafe.to('effects').to('energetic').get<double>('score'),
    'euphoric': strainSafe.to('effects').to('euphoric').get<double>('score'),
    'focused': strainSafe.to('effects').to('focused').get<double>('score'),
    'giggly': strainSafe.to('effects').to('giggly').get<double>('score'),
    'happy': strainSafe.to('effects').to('happy').get<double>('score'),
    'hungry': strainSafe.to('effects').to('hungry').get<double>('score'),
    'relaxed': strainSafe.to('effects').to('relaxed').get<double>('score'),
    'sleepy': strainSafe.to('effects').to('sleepy').get<double>('score'),
    'talkative': strainSafe.to('effects').to('talkative').get<double>('score'),
    'tingly': strainSafe.to('effects').to('tingly').get<double>('score'),
    'uplifted': strainSafe.to('effects').to('uplifted').get<double>('score'),
  };

  final terpenes = {
    'caryophyllene':
        strainSafe.to('terps').to('caryophyllene').get<double>('score'),
    'humulene': strainSafe.to('terps').to('humulene').get<double>('score'),
    'limonene': strainSafe.to('terps').to('limonene').get<double>('score'),
    'linalool': strainSafe.to('terps').to('linalool').get<double>('score'),
    'myrcene': strainSafe.to('terps').to('myrcene').get<double>('score'),
    'ocimene': strainSafe.to('terps').to('ocimene').get<double>('score'),
    'pinene': strainSafe.to('terps').to('pinene').get<double>('score'),
    'terpinolene':
        strainSafe.to('terps').to('terpinolene').get<double>('score'),
  };

  // If strain is '', replace with null.
  final categoryRaw = strainSafe.get<String>('category');
  final category = (categoryRaw?.isNotEmpty ?? false) ? categoryRaw : null;

  return Strain(
    averageRating: strainSafe.get<double>('averageRating'),
    category: category,
    name: strainSafe.get<String>('name'),
    imageUrl: strainSafe.get<String>('nugImage'),
    numberOfReviews: strainSafe.get<int>('reviewCount'),
    description: strainSafe.get<String>('shortDescriptionPlain'),
    otherNames: otherNames,
    thc: strainSafe.get<double>('thc'),
    cannabinoids: cannabinoids,
    effects: effects,
    terpenes: terpenes,
  );
}

/// Generate all the strains from Leafly.
Stream<Strain> fetchStrains() async* {
  const take = 20;
  var skip = 0;

  final fetchedIds = <int>{};

  int? prevHashCode;
  while (true) {
    final req = await get(
      Uri.parse(
        'https://consumer-api.leafly.com/api/strain_playlists/v2'
        '?enableNewFilters=false'
        '&skip=$skip'
        '&strain_playlist='
        '&take=$take',
      ),
    );

    // Break when server refuses.
    if (req.statusCode != 200) {
      if (kDebugMode) print(req.body);
      break;
    }
    ;

    // Break when we stop getting new data.
    if (req.body.hashCode == prevHashCode) break;
    prevHashCode = req.body.hashCode;

    final json = jsonDecode(req.body) as Map<String, dynamic>;
    final safeJson = SafeJson(json);
    final rawStrains = safeJson.to('hits').get<List<dynamic>>('strain') ?? [];

    for (final rawStrain in rawStrains) {
      final strainSafe = SafeJson(rawStrain as Map<String, dynamic>);
      final id = strainSafe.get<int>('id');

      if (id == null) continue;

      if (!fetchedIds.contains(id)) {
        fetchedIds.add(id);
        final strain = _parseLeaflyJson(rawStrain);
        yield strain;
      }
    }

    skip += take;
  }
}
