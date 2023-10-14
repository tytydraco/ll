import 'dart:convert';

import 'package:http/http.dart';

/// Generate all the strains from Leafly.
Stream<dynamic> fetchStrains() async* {
  final strains = <dynamic>[];

  const take = 20;
  var skip = 0;

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
    final strain = hits['strain'] as List<dynamic>;

    yield* Stream.fromIterable(strain);

    skip += take;
  }
}
