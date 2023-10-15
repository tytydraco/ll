import 'dart:convert';

import 'package:http/http.dart';
import 'package:ll/src/util/safe_json.dart';

/// Generate all the strains from Leafly.
Stream<Map<String, dynamic>> fetchStrains() async* {
  const take = 20;
  var skip = 0;

  final fetchedIds = <int>{};

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

    // Break when server is done.
    if (req.statusCode != 200) break;

    final json = jsonDecode(req.body) as Map<String, dynamic>;
    final safeJson = SafeJson(json);
    final strains = safeJson.to('hits').get<List<dynamic>>('strain') ?? [];

    for (final strain in strains) {
      final strainSafe = SafeJson(strain as Map<String, dynamic>);
      final id = strainSafe.get<int>('id');

      if (id == null) continue;

      if (!fetchedIds.contains(id)) {
        fetchedIds.add(id);
        yield strain;
      }
    }

    skip += take;
  }
}
