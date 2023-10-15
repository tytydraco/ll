import 'package:ll/src/data/strain.dart';

/// Attempt to merge strain properties together.
class StrainMerge {
  /// Creates a new [StrainMerge].
  StrainMerge({
    required this.strains,
  });

  /// The strains to merge.
  final Set<Strain> strains;

  double? _mergeThc() {
    var thcStrainsAccountedFor = 0;
    var mergeStrainThc = 0.0;

    for (final strain in strains) {
      if (strain.thc == null) continue;

      thcStrainsAccountedFor += 1;
      mergeStrainThc += strain.thc!;
    }

    if (thcStrainsAccountedFor == 0) return null;
    return mergeStrainThc / thcStrainsAccountedFor;
  }

  double _getPropAvg(double? Function(Strain strain) getValue) {
    var score = 0.0;
    var accountedFor = 0;
    for (final strain in strains) {
      final value = getValue(strain);

      if (value == null) continue;

      accountedFor += 1;
      score += value;
    }

    return score / accountedFor;
  }

  /// Merge the strains together and return the merged strain.
  Strain merge() {
    final strainNames = strains.map((e) => e.name).toSet();

    // New strain name will be "Merge of <strains>"
    final mergeStrainName = 'Merge of ${strainNames.join(', ')}';
    final mergeStrainDescription =
        'Merged strain created from the following strains: \n - '
        '${strainNames.join(', ')}';

    final strainCategories = strains.map((e) => e.category).toSet();

    // If there are different strain types merged, it is a hybrid.
    final mergeStrainCategory =
        (strainCategories.length == 1) ? strainCategories.first : 'Hybrid';

    final mergeStrainThc = _mergeThc();

    return Strain(
      name: mergeStrainName,
      category: mergeStrainCategory,
      description: mergeStrainDescription,
      thc: mergeStrainThc,
      cannabinoids: {
        'cbc': _getPropAvg((s) => s.cannabinoids?['cbc']),
        'cbd': _getPropAvg((s) => s.cannabinoids?['cbd']),
        'cbg': _getPropAvg((s) => s.cannabinoids?['cbg']),
        'thc': _getPropAvg((s) => s.cannabinoids?['thc']),
        'thcv': _getPropAvg((s) => s.cannabinoids?['thcv']),
      },
      effects: {
        'aroused': _getPropAvg((s) => s.effects?['aroused']),
        'creative': _getPropAvg((s) => s.effects?['creative']),
        'energetic': _getPropAvg((s) => s.effects?['energetic']),
        'euphoric': _getPropAvg((s) => s.effects?['euphoric']),
        'focused': _getPropAvg((s) => s.effects?['focused']),
        'giggly': _getPropAvg((s) => s.effects?['giggly']),
        'happy': _getPropAvg((s) => s.effects?['happy']),
        'hungry': _getPropAvg((s) => s.effects?['hungry']),
        'relaxed': _getPropAvg((s) => s.effects?['relaxed']),
        'sleepy': _getPropAvg((s) => s.effects?['sleepy']),
        'talkative': _getPropAvg((s) => s.effects?['talkative']),
        'tingly': _getPropAvg((s) => s.effects?['tingly']),
        'uplifted': _getPropAvg((s) => s.effects?['uplifted']),
      },
      terpenes: {
        'caryophyllene': _getPropAvg((s) => s.terpenes?['caryophyllene']),
        'humulene': _getPropAvg((s) => s.terpenes?['humulene']),
        'limonene': _getPropAvg((s) => s.terpenes?['limonene']),
        'linalool': _getPropAvg((s) => s.terpenes?['linalool']),
        'myrcene': _getPropAvg((s) => s.terpenes?['myrcene']),
        'ocimene': _getPropAvg((s) => s.terpenes?['ocimene']),
        'pinene': _getPropAvg((s) => s.terpenes?['pinene']),
        'terpinolene': _getPropAvg((s) => s.terpenes?['terpinolene']),
      },
    );
  }
}
