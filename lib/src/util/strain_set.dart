import 'dart:collection';

import 'package:ll/src/util/safe_json.dart';

/// Strain objects sorted by name number in ascending order.
SplayTreeSet<Map<String, dynamic>> createStrainsSet() =>
    SplayTreeSet<Map<String, dynamic>>((key1, key2) {
      final strainSafe1 = SafeJson(key1);
      final strainSafe2 = SafeJson(key2);

      return (strainSafe1.get<String>('name') ?? 'N/A')
          .toLowerCase()
          .compareTo((strainSafe2.get<String>('name') ?? 'N/A').toLowerCase());
    });
