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

  String _getStrainCategory(String? category, String? phenotype) {
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

  bool _hasCannabinoids() {
    return _strainSafe
                .to('cannabinoids')
                .to('thcv')
                .get<double>('percentile50') !=
            null ||
        _strainSafe.to('cannabinoids').to('cbg').get<double>('percentile50') !=
            null ||
        _strainSafe.to('cannabinoids').to('cbc').get<double>('percentile50') !=
            null ||
        _strainSafe.to('cannabinoids').to('thc').get<double>('percentile50') !=
            null ||
        _strainSafe.to('cannabinoids').to('cbd').get<double>('percentile50') !=
            null;
  }

  @override
  Widget build(BuildContext context) {
    final name = _strainSafe.get<String>('name');
    final description = _strainSafe.get<String>('shortDescriptionPlain');
    final otherNames = _strainSafe.get<String>('subtitle');
    final averageRating = _strainSafe.get<double>('averageRating');
    final reviewCount = _strainSafe.get<int>('reviewCount');
    final category = _strainSafe.get<String>('category');
    final phenotype = _strainSafe.get<String>('phenotype');
    final topTerp = _strainSafe.get<String>('strainTopTerp');
    final topEffect = _strainSafe.get<String>('topEffect');
    final thc = _strainSafe.get<double>('thc');

    final hasTerps = _strainSafe.to('terps').json?.isNotEmpty ?? false;
    final hasEffects = _strainSafe.to('effects').json?.isNotEmpty ?? false;
    final hasCannabinoids = _hasCannabinoids();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBack,
        title: Text(name ?? 'N/A'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: getStrainGradientColors(category),
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
          if (description != null) ...[
            _paramTile('Description', description),
            const Divider(),
          ],
          if (otherNames != null) ...[
            _paramTile('Other names', otherNames),
            const Divider(),
          ],
          if (averageRating != null) ...[
            _paramTile('Average rating', averageRating.toStringAsFixed(2)),
            const Divider(),
          ],
          if (reviewCount != null) ...[
            _paramTile('Ratings', reviewCount),
            const Divider(),
          ],
          if (category != null || phenotype != null) ...[
            _paramTile('Category', _getStrainCategory(category, phenotype)),
            const Divider(),
          ],

          if (topTerp != null) _paramTile('Main terpene', topTerp),
          if (hasTerps) TerpeneChart(strain: widget.strain),
          if (topTerp != null || hasTerps) const Divider(),

          if (topEffect != null) _paramTile('Main effect', topEffect),
          if (hasEffects) EffectsChart(strain: widget.strain),
          if (topEffect != null || hasEffects) const Divider(),

          if (thc != null) _paramTile('Average THC content', '${thc.round()}%'),
          if (hasCannabinoids) CannabinoidsChart(strain: widget.strain),
          if (thc != null || hasCannabinoids) const Divider(),

          if (name != null) NotesArea(strainName: name),
        ],
      ),
    );
  }
}
