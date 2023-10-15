import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ll/src/data/strain.dart';
import 'package:ll/src/util/colors.dart';

/// Show the cannabinoid content.
class CannabinoidsChart extends StatefulWidget {
  /// Creates a new [CannabinoidsChart].
  const CannabinoidsChart({
    required this.strain,
    super.key,
  });

  /// The strain.
  final Strain strain;

  @override
  State<CannabinoidsChart> createState() => _CannabinoidsChartState();
}

class _CannabinoidsChartState extends State<CannabinoidsChart> {
  BarChartGroupData _buildGroup(int x, String name, double score) {
    final color = getCannabinoidColor(name);

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

  double _getChartMaxY() {
    final maxMagnitude = widget.strain.cannabinoids?.values
            .map((e) => e?.abs() ?? 0)
            .reduce(max) ??
        0;
    // Users need a visual comparison, so adapt to higher values but lock here.
    return max(maxMagnitude, 22);
  }

  @override
  Widget build(BuildContext context) {
    final barGroups = widget.strain.cannabinoids?.entries
        .toList()
        .asMap()
        .entries
        .map((e) => _buildGroup(e.key, e.value.key, e.value.value ?? 0))
        .toList();

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
                          widget.strain.cannabinoids!.keys
                              .toList()[value.toInt()]
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: barGroups,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }
}
