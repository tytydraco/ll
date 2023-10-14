import 'package:flutter/material.dart';
import 'package:ll/src/ui/details/cannabinoids_chart.dart';
import 'package:ll/src/ui/details/effects_chart.dart';
import 'package:ll/src/ui/details/terpene_chart.dart';
import 'package:ll/src/util/string_ext.dart';

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
  Widget _paramTile(String title, dynamic content) {
    final formattedContent = content.toString().capitalize();

    return ListTile(
      title: Text(title),
      subtitle: Text(formattedContent),
    );
  }

  String _getCategory() {
    final category = widget.strain['category'] as String?;
    final phenotype = widget.strain['phenotype'] as String?;

    if (category == null && phenotype != null) return phenotype;
    if (category != null && phenotype == null) return category;
    if (category == null && phenotype == null) return 'N/A';
    if (category == phenotype) return category!;

    return 'Category: $category\nPhenotype: $phenotype';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.strain['name'] as String),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          //Image.network(widget.strain['nugImage'] as String),
          _paramTile(
            'Description',
            (widget.strain['shortDescriptionPlain'] as String?) ?? 'N/A',
          ),
          const Divider(),
          _paramTile('Main effect', widget.strain['topEffect']),
          const Divider(),
          _paramTile(
            'Other names',
            (widget.strain['subtitle'] as String?) ?? 'N/A',
          ),
          const Divider(),
          _paramTile(
            'Average rating',
            (widget.strain['averageRating'] as double).toStringAsFixed(2),
          ),
          const Divider(),
          _paramTile('Ratings', widget.strain['reviewCount']),
          const Divider(),
          _paramTile('Category', _getCategory()),
          const Divider(),
          _paramTile(
            'Average THC content',
            '${(widget.strain['thc'] as double).round()}%',
          ),
          const Divider(),
          _paramTile('Main terpene', widget.strain['strainTopTerp']),
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
