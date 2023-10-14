import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ll/src/util/string_ext.dart';

/// Show the terpene content.
class TerpeneChart extends StatefulWidget {
  /// Creates a new [TerpeneChart].
  const TerpeneChart({
    required this.strain,
    super.key,
  });

  /// The strain.
  final Map<String, dynamic> strain;

  @override
  State<TerpeneChart> createState() => _TerpeneChartState();
}

class _TerpeneChartState extends State<TerpeneChart> {
  late final _terps = widget.strain['terps'] as Map<String, dynamic>;

  PieChartSectionData _buildSection(String effect, Color color) {
    return PieChartSectionData(
      showTitle: false,
      color: color,
      badgePositionPercentageOffset: 2,
      badgeWidget: Text(
        effect.capitalize(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
      value: _terps[effect]['score'] as double,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(100),
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 40,
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            sections: [
              _buildSection('caryophyllene', Colors.red),
              _buildSection('humulene', Colors.green),
              _buildSection('limonene', Colors.yellow),
              _buildSection('linalool', Colors.purple),
              _buildSection('myrcene', Colors.blue),
              _buildSection('ocimene', Colors.pink),
              _buildSection('pinene', Colors.brown),
              _buildSection('terpinolene', Colors.orange),
            ],
          ),
        ),
      ),
    );
  }
}
