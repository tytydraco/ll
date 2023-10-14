import 'dart:convert';

import 'package:http/http.dart';

/// Generate all the strains from Leafly.
Stream<dynamic> fetchStrains() async* {
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
    final hits = json['hits'] as Map<String, dynamic>;
    final strains = hits['strain'] as List<dynamic>;

    for (final strain in strains) {
      final id = strain['id'] as int;
      if (!fetchedIds.contains(id)) {
        fetchedIds.add(id);
        yield strain;
      }
    }

    skip += take;
  }
}
