import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ll/src/util/colors.dart';
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
    required this.score,
  });

  final String id;
  final Color color;
  final double score;
}

class _CannabinoidsChartState extends State<CannabinoidsChart> {
  late final _strainSafe = SafeJson(widget.strain);

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

  double _getChartMaxY(List<_Cannabinoid> cannabinoids) {
    final maxMagnitude = cannabinoids.map((e) => e.score.abs()).reduce(max);
    // Users need a visual comparison, so adapt to higher values but lock here.
    return max(maxMagnitude, 22);
  }

  List<_Cannabinoid> _getOrderedCannabinoids() {
    final cannaSafe = _strainSafe.to('cannabinoids');
    final cannabinoidNames = cannaSafe.json?.keys.toList();

    final cannabinoids = cannabinoidNames?.map((cannabinoid) {
      final noidSafe = cannaSafe.to(cannabinoid);
      final score = noidSafe.get<double>('percentile50') ?? 0;
      final color = getCannabinoidColor(cannabinoid);

      return _Cannabinoid(id: cannabinoid, color: color, score: score);
    }).toList();

    cannabinoids?.sort((a, b) {
      final orderA =
          _strainSafe.to('cannabinoids').to(a.id).get<int>('order') ?? 0;
      final orderB =
          _strainSafe.to('cannabinoids').to(b.id).get<int>('order') ?? 0;

      return orderB.compareTo(orderA);
    });

    return cannabinoids ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final cannabinoids = _getOrderedCannabinoids();
    final barGroups = cannabinoids
        .asMap()
        .entries
        .map((e) => _buildGroup(e.key, e.value))
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
              maxY: _getChartMaxY(cannabinoids),
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
                          cannabinoids[value.toInt()].id.toUpperCase(),
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
