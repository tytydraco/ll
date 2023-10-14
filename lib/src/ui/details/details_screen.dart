import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ll/src/ui/compare/compare_screen.dart';
import 'package:ll/src/ui/details/cannabinoids_chart.dart';
import 'package:ll/src/ui/details/effects_chart.dart';
import 'package:ll/src/ui/details/terpene_chart.dart';
import 'package:ll/src/ui/search/search_screen.dart';
import 'package:ll/src/util/safe_json.dart';
import 'package:ll/src/util/strain_colors.dart';
import 'package:ll/src/util/string_ext.dart';
//import 'package:share_plus/share_plus.dart';

/// The details about the strain.
class DetailsScreen extends StatefulWidget {
  /// Creates a new [DetailsScreen].
  const DetailsScreen({
    required this.strain,
    super.key,
  });

  /// The strain JSON.
  final Map<String, dynamic> strain;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final _strainSafe = SafeJson(widget.strain);

  Widget _paramTile(String title, dynamic content) {
    final formattedContent = content.toString().capitalize();

    return ListTile(
      title: Text(title),
      subtitle: Text(formattedContent),
    );
  }

  String _getCategory() {
    final category = _strainSafe.get<String>('category');
    final phenotype = _strainSafe.get<String>('phenotype');

    if (category == null && phenotype != null) return phenotype;
    if (category != null && phenotype == null) return category;
    if (category == null && phenotype == null) return 'N/A';
    if (category == phenotype) return category!;

    return 'Category: $category\nPhenotype: $phenotype';
  }

  Future<void> _copyStrainData() async {
    await Clipboard.setData(
      ClipboardData(text: jsonEncode(widget.strain)),
    );
  }

  void _compareStrains() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(
          onSelect: (otherStrain) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (__) => CompareScreen(
                  strainA: widget.strain,
                  strainB: otherStrain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strainSafe.get<String>('name') ?? 'N/A'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  getStrainGradientColors(_strainSafe.get<String>('category')),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _copyStrainData,
            icon: const Icon(Icons.copy),
          ),
          IconButton(
            onPressed: _compareStrains,
            icon: const Icon(Icons.compare),
          ),
        ],
      ),
      body: ListView(
        children: [
          //Image.network(widget.strain['nugImage'] as String),
          _paramTile(
            'Description',
            (_strainSafe.get<String>('shortDescriptionPlain')) ?? 'N/A',
          ),
          const Divider(),
          _paramTile(
            'Main effect',
            (_strainSafe.get<String>('topEffect')) ?? 'N/A',
          ),
          const Divider(),
          _paramTile(
            'Other names',
            (_strainSafe.get<String>('subtitle')) ?? 'N/A',
          ),
          const Divider(),
          _paramTile(
            'Average rating',
            (_strainSafe.get<double>('averageRating') ?? -1).toStringAsFixed(2),
          ),
          const Divider(),
          _paramTile('Ratings', _strainSafe.get<int>('reviewCount') ?? 'N/A'),
          const Divider(),
          _paramTile(
            'Category',
            _getCategory(),
          ),
          const Divider(),
          _paramTile(
            'Average THC content',
            (_strainSafe.get<double>('thc') != null)
                ? '${_strainSafe.get<double>('thc')?.round()}%'
                : 'N/A',
          ),
          const Divider(),
          _paramTile(
            'Main terpene',
            _strainSafe.get<String>('strainTopTerp') ?? 'N/A',
          ),
          const Divider(),
          TerpeneChart(strain: widget.strain),
          const Divider(),
          EffectsChart(strain: widget.strain),
          const Divider(),
          CannabinoidsChart(strain: widget.strain),
        ],
      ),
    );
  }
}
