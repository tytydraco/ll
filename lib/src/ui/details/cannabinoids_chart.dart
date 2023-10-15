import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ll/src/util/safe_json.dart';

/// Show the cannabinoid content.
class CannabinoidsChart extends StatefulWidget {
  /// Creates a new [CannabinoidsChart].
  const CannabinoidsChart({
    required this.strain,
    super.key,
  });

  /// The strain.
  final Map<String, dynamic> strain;

  @override
  State<CannabinoidsChart> createState() => _CannabinoidsChartState();
}

class _CannabinoidsChartState extends State<CannabinoidsChart> {
  late final _strainSafe = SafeJson(widget.strain);

  final _cannabinoidsIndicies = <int, String>{
    -2: 'thcv',
    -1: 'cbg',
    0: 'cbc',
    1: 'thc',
    2: 'cbd',
  };

  BarChartGroupData _buildGroup(
    String cannabinoid,
    int x,
    Color color,
  ) {
    final score = _strainSafe
            .to('cannabinoids')
            .to(cannabinoid)
            .get<double>('percentile50') ??
        0;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: score,
          color: color,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 2,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: 30,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 30,
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          _cannabinoidsIndicies[value]!.toUpperCase(),
                          textAlign: TextAlign.center,
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
                _buildGroup('thcv', -2, Colors.red),
                _buildGroup('cbg', -1, Colors.orange),
                _buildGroup('cbc', 0, Colors.yellow),
                _buildGroup('thc', 1, Colors.green),
                _buildGroup('cbd', 2, Colors.blue),
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
