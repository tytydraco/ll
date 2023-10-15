import 'package:ll/src/util/safe_json.dart';
import 'package:ll/src/util/string_ext.dart';

/// Attempt to merge strain properties together.
class StrainMerge {
  /// Creates a new [StrainMerge].
  StrainMerge({
    required this.strains,
  });

  /// The strains to merge.
  final Set<Map<String, dynamic>> strains;

  double _mergeThc() {
    var thcStrainsAccountedFor = 0;
    var mergeStrainThc = 0.0;
    for (final strain in strains) {
      final strainSafe = SafeJson(strain);
      final thc = strainSafe.get<double>('thc');

      if (thc == null) continue;

      thcStrainsAccountedFor += 1;
      mergeStrainThc += thc;
    }
    return mergeStrainThc / thcStrainsAccountedFor;
  }

  String _mergeMainTerp() {
    final strainMainTerp = <String, int>{};
    for (final strain in strains) {
      final strainSafe = SafeJson(strain);
      final mainTerp = strainSafe.get<String>('strainTopTerp');
      if (mainTerp == null) continue;

      if (strainMainTerp.containsKey(mainTerp)) {
        strainMainTerp[mainTerp] = strainMainTerp[mainTerp]! + 1;
      } else {
        strainMainTerp[mainTerp] = 1;
      }
    }
    final mainTerps = strainMainTerp.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return mainTerps.first.key;
  }

  double _getPropAvg(double? Function(SafeJson strainSafe) getValue) {
    var score = 0.0;
    var accountedFor = 0;
    for (final strain in strains) {
      final strainSafe = SafeJson(strain);
      final value = getValue(strainSafe);

      if (value == null) continue;

      accountedFor += 1;
      score += value;
    }

    return score / accountedFor;
  }

  String _mergeTopEffect() {
    final topEffectScores = {
      'aroused': _getPropAvg(
        (s) => s.to('effects').to('aroused').get<double>('score'),
      ),
      'creative': _getPropAvg(
        (s) => s.to('effects').to('creative').get<double>('score'),
      ),
      'energetic': _getPropAvg(
        (s) => s.to('effects').to('energetic').get<double>('score'),
      ),
      'euphoric': _getPropAvg(
        (s) => s.to('effects').to('euphoric').get<double>('score'),
      ),
      'focused': _getPropAvg(
        (s) => s.to('effects').to('focused').get<double>('score'),
      ),
      'score': _getPropAvg(
        (s) => s.to('effects').to('giggly').get<double>('score'),
      ),
      'happy': _getPropAvg(
        (s) => s.to('effects').to('happy').get<double>('score'),
      ),
      'hungry': _getPropAvg(
        (s) => s.to('effects').to('hungry').get<double>('score'),
      ),
      'relaxed': _getPropAvg(
        (s) => s.to('effects').to('relaxed').get<double>('score'),
      ),
      'sleepy': _getPropAvg(
        (s) => s.to('effects').to('sleepy').get<double>('score'),
      ),
      'talkative': _getPropAvg(
        (s) => s.to('effects').to('talkative').get<double>('score'),
      ),
      'tingly': _getPropAvg(
        (s) => s.to('effects').to('tingly').get<double>('score'),
      ),
      'uplifted': _getPropAvg(
        (s) => s.to('effects').to('uplifted').get<double>('score'),
      ),
    };

    final topEffects = topEffectScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return topEffects.first.key.capitalize();
  }

  /// Merge the strains together and return the merged strain.
  Map<String, dynamic> merge() {
    final strainNames = strains.map((strain) {
      final strainSafe = SafeJson(strain);
      return strainSafe.get<String>('name') ?? 'N/A';
    }).toList();

    // New strain name will be "Merge of <strains>"
    final mergeStrainName = 'Merge of ${strainNames.join(', ')}';
    final mergeStrainDescription =
        'Merged strain created from the following strains: \n - '
        '${strainNames.join(', ')}';

    final strainCategories = strains.map((strain) {
      final strainSafe = SafeJson(strain);
      return strainSafe.get<String>('category');
    }).toSet();

    // If there are different strain types merged, it is a hybrid.
    final mergeStrainCategory =
        (strainCategories.length == 1) ? strainCategories.first : 'Hybrid';

    final topEffect = _mergeTopEffect();
    final mergeStrainThc = _mergeThc();
    final mainTerp = _mergeMainTerp();

    return <String, dynamic>{
      'name': mergeStrainName,
      'category': mergeStrainCategory,
      'shortDescriptionPlain': mergeStrainDescription,
      'topEffect': topEffect,
      'thc': mergeStrainThc,
      'strainTopTerp': mainTerp,
      'cannabinoids': {
        'cbc': {
          'percentile50': _getPropAvg(
            (s) => s.to('cannabinoids').to('cbc').get<double>('percentile50'),
          ),
        },
        'cbd': {
          'percentile50': _getPropAvg(
            (s) => s.to('cannabinoids').to('cbd').get<double>('percentile50'),
          ),
        },
        'cbg': {
          'percentile50': _getPropAvg(
            (s) => s.to('cannabinoids').to('cbg').get<double>('percentile50'),
          ),
        },
        'thc': {
          'percentile50': _getPropAvg(
            (s) => s.to('cannabinoids').to('thc').get<double>('percentile50'),
          ),
        },
        'thcv': {
          'percentile50': _getPropAvg(
            (s) => s.to('cannabinoids').to('thcv').get<double>('percentile50'),
          ),
        },
      },
      'effects': {
        'aroused': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('aroused').get<double>('score'),
          ),
        },
        'creative': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('creative').get<double>('score'),
          ),
        },
        'energetic': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('energetic').get<double>('score'),
          ),
        },
        'euphoric': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('euphoric').get<double>('score'),
          ),
        },
        'focused': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('focused').get<double>('score'),
          ),
        },
        'giggly': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('giggly').get<double>('score'),
          ),
        },
        'happy': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('happy').get<double>('score'),
          ),
        },
        'hungry': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('hungry').get<double>('score'),
          ),
        },
        'relaxed': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('relaxed').get<double>('score'),
          ),
        },
        'sleepy': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('sleepy').get<double>('score'),
          ),
        },
        'talkative': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('talkative').get<double>('score'),
          ),
        },
        'tingly': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('tingly').get<double>('score'),
          ),
        },
        'uplifted': {
          'score': _getPropAvg(
            (s) => s.to('effects').to('uplifted').get<double>('score'),
          ),
        },
      },
      'terps': {
        'caryophyllene': {
          'score': _getPropAvg(
            (s) => s.to('terps').to('caryophyllene').get<double>('score'),
          ),
        },
        'humulene': {
          'score': _getPropAvg(
            (s) => s.to('terps').to('humulene').get<double>('score'),
          ),
        },
        'limonene': {
          'score': _getPropAvg(
            (s) => s.to('terps').to('limonene').get<double>('score'),
          ),
        },
        'linalool': {
          'score': _getPropAvg(
            (s) => s.to('terps').to('linalool').get<double>('score'),
          ),
        },
        'myrcene': {
          'score': _getPropAvg(
            (s) => s.to('terps').to('myrcene').get<double>('score'),
          ),
        },
        'ocimene': {
          'score': _getPropAvg(
            (s) => s.to('terps').to('ocimene').get<double>('score'),
          ),
        },
        'pinene': {
          'score': _getPropAvg(
            (s) => s.to('terps').to('pinene').get<double>('score'),
          ),
        },
        'terpinolene': {
          'score': _getPropAvg(
            (s) => s.to('terps').to('terpinolene').get<double>('score'),
          ),
        },
      },
    };
  }
}
