import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
  late final _cannabinoids =
      widget.strain['cannabinoids'] as Map<String, dynamic>;
  final _cannabinoidsIndicies = <int, String>{
    -2: 'cbc',
    -1: 'cbd',
    0: 'cbg',
    1: 'thc',
    2: 'thcv',
  };

  BarChartGroupData _buildGroup(
    String cannabinoid,
    int x,
    Color color,
  ) {
    final score = (_cannabinoids[cannabinoid] != null &&
            _cannabinoids[cannabinoid]['percentile50'] != null)
        ? _cannabinoids[cannabinoid]['percentile50'] as double
        : 0.0;

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
                _buildGroup('thcv', 2, Colors.red),
                _buildGroup('cbg', 0, Colors.orange),
                _buildGroup('cbc', -2, Colors.yellow),
                _buildGroup('thc', 1, Colors.green),
                _buildGroup('cbd', -1, Colors.blue),
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
