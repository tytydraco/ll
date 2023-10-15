import 'dart:collection';

import 'package:ll/src/data/strain.dart';

/// Strain objects sorted by name number in ascending order.
SplayTreeSet<Strain> createStrainsSet() => SplayTreeSet<Strain>(
      (key1, key2) => (key1.name?.toLowerCase() ?? 'N/A')
          .compareTo(key2.name?.toLowerCase() ?? 'N/A'),
    );
