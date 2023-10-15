import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ll/src/ui/details/cannabinoids_chart.dart';
import 'package:ll/src/ui/details/effects_chart.dart';
import 'package:ll/src/ui/details/notes_area.dart';
import 'package:ll/src/ui/details/terpene_chart.dart';
import 'package:ll/src/util/safe_json.dart';
import 'package:ll/src/util/strain_colors.dart';
import 'package:ll/src/util/string_ext.dart';

/// The details about the strain.
class DetailsScreen extends StatefulWidget {
  /// Creates a new [DetailsScreen].
  const DetailsScreen({
    required this.strain,
    this.showBack = true,
    super.key,
  });

  /// The strain JSON.
  final Map<String, dynamic> strain;

  /// Show the back button.
  final bool showBack;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBack,
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
        ],
      ),
      body: ListView(
        children: [
          //Image.network(widget.strain['nugImage'] as String),
          if (_strainSafe.get<String>('shortDescriptionPlain') != null) ...[
            _paramTile(
              'Description',
              _strainSafe.get<String>('shortDescriptionPlain'),
            ),
            const Divider(),
          ],
          if (_strainSafe.get<String>('subtitle') != null) ...[
            _paramTile(
              'Other names',
              _strainSafe.get<String>('subtitle'),
            ),
            const Divider(),
          ],
          if (_strainSafe.get<double>('averageRating') != null) ...[
            _paramTile(
              'Average rating',
              _strainSafe.get<double>('averageRating')!.toStringAsFixed(2),
            ),
            const Divider(),
          ],
          if (_strainSafe.get<int>('reviewCount') != null) ...[
            _paramTile(
              'Ratings',
              _strainSafe.get<int>('reviewCount'),
            ),
            const Divider(),
          ],
          if (_strainSafe.get<String>('category') != null ||
              _strainSafe.get<String>('phenotype') != null) ...[
            _paramTile(
              'Category',
              _getCategory(),
            ),
            const Divider(),
          ],
          if (_strainSafe.get<String>('strainTopTerp') != null) ...[
            _paramTile(
              'Main terpene',
              _strainSafe.get<String>('strainTopTerp'),
            ),
          ],
          TerpeneChart(strain: widget.strain),
          const Divider(),
          if (_strainSafe.get<String>('topEffect') != null)
            _paramTile(
              'Main effect',
              _strainSafe.get<String>('topEffect'),
            ),
          EffectsChart(strain: widget.strain),
          const Divider(),
          if (_strainSafe.get<double>('thc') != null)
            _paramTile(
              'Average THC content',
              '${_strainSafe.get<double>('thc')!.round()}%',
            ),
          CannabinoidsChart(strain: widget.strain),
          const Divider(),
          if (_strainSafe.get<String>('name') != null)
            NotesArea(strainName: _strainSafe.get<String>('name')!),
        ],
      ),
    );
  }
}
