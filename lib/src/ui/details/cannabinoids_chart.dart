import 'dart:math';

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

class _Cannabinoid {
  _Cannabinoid({
    required this.id,
    required this.color,
  });

  final String id;
  final Color color;
}

class _CannabinoidsChartState extends State<CannabinoidsChart> {
  late final _strainSafe = SafeJson(widget.strain);

  final _cannabinoidsIndicies = {
    -2: _Cannabinoid(id: 'thcv', color: Colors.red),
    -1: _Cannabinoid(id: 'cbg', color: Colors.orange),
    0: _Cannabinoid(id: 'cbc', color: Colors.yellow),
    1: _Cannabinoid(id: 'thc', color: Colors.green),
    2: _Cannabinoid(id: 'cbd', color: Colors.blue),
  };

  BarChartGroupData _buildGroup(int x, _Cannabinoid cannabinoid) {
    final score = _strainSafe
            .to('cannabinoids')
            .to(cannabinoid.id)
            .get<double>('percentile50') ??
        0;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: score,
          color: cannabinoid.color,
        ),
      ],
    );
  }

  double _getChartMaxY() {
    final maxMagnitude = _cannabinoidsIndicies.values
        .map(
          (e) =>
              _strainSafe
                  .to('cannabinoids')
                  .to(e.id)
                  .get<double>('percentile50')
                  ?.abs() ??
              0,
        )
        .reduce(max);

    // Users need a visual comparison, so adapt to higher values but lock here.
    return max(maxMagnitude, 22);
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
              maxY: _getChartMaxY(),
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
                          _cannabinoidsIndicies[value]!.id.toUpperCase(),
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
              barGroups: _cannabinoidsIndicies.entries
                  .map((e) => _buildGroup(e.key, e.value))
                  .toList(),
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
