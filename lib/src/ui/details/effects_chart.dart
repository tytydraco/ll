import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  late final _effects = widget.strain['effects'] as Map<String, dynamic>;

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
    final roundedValue =
        double.parse((_effects[effect]['score'] as double).toStringAsFixed(2));

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Effects',
            style: TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: BarChart(
            BarChartData(
              minY: -2,
              maxY: 2,
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
                            fontSize: 16,
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
      ],
    );
  }
}
