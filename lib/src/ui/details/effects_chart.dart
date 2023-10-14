import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ll/src/util/safe_json.dart';
import 'package:ll/src/util/string_ext.dart';

/// Show the effects.
class EffectsChart extends StatefulWidget {
  /// Creates a new [EffectsChart].
  const EffectsChart({
    required this.strain,
    super.key,
  });

  /// The strain.
  final Map<String, dynamic> strain;

  @override
  State<EffectsChart> createState() => _EffectsChartState();
}

class _EffectsChartState extends State<EffectsChart> {
  late final _strainSafe = SafeJson(widget.strain);

  final _effectIndicies = <int, String>{
    -6: 'aroused',
    -5: 'creative',
    -4: 'energetic',
    -3: 'euphoric',
    -2: 'focused',
    -1: 'giggly',
    0: 'happy',
    1: 'hungry',
    2: 'relaxed',
    3: 'sleepy',
    4: 'talkative',
    5: 'tingly',
    6: 'uplifted',
  };

  BarChartGroupData _buildGroup(
    String effect,
    int x,
    Color color,
  ) {
    final score =
        _strainSafe.to('effects').to(effect).get<double>('score') ?? 0;

    final roundedValue = double.parse(score.toStringAsFixed(2));

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: roundedValue,
          color: color,
        ),
      ],
    );
  }

  double _getChartMaxMagnitude() {
    return _effectIndicies.values
        .map(
          (e) =>
              _strainSafe.to('effects').to(e).get<double>('score')?.abs() ?? 0,
        )
        .reduce(max);
  }

  @override
  Widget build(BuildContext context) {
    final chartMaxY = _getChartMaxMagnitude();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: BarChart(
            BarChartData(
              minY: -chartMaxY,
              maxY: chartMaxY,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 80,
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          _effectIndicies[value]!.capitalize(),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                _buildGroup('aroused', -6, Colors.red),
                _buildGroup('hungry', 1, Colors.redAccent),
                _buildGroup('energetic', -4, Colors.orange),
                _buildGroup('happy', 0, Colors.orangeAccent),
                _buildGroup('creative', -5, Colors.yellow),
                _buildGroup('giggly', -1, Colors.yellowAccent),
                _buildGroup('uplifted', 6, Colors.lightGreen),
                _buildGroup('focused', -2, Colors.green),
                _buildGroup('talkative', 4, Colors.greenAccent),
                _buildGroup('relaxed', 2, Colors.lightBlue),
                _buildGroup('tingly', 5, Colors.blue),
                _buildGroup('euphoric', -3, Colors.purple),
                _buildGroup('sleepy', 3, Colors.deepPurple),
              ],
              gridData: const FlGridData(
                show: false,
              ),
              borderData: FlBorderData(
                show: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
