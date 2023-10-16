import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ll/src/data/strain.dart';
import 'package:ll/src/ui/details/cannabinoids_chart.dart';
import 'package:ll/src/ui/details/effects_chart.dart';
import 'package:ll/src/ui/details/notes_area.dart';
import 'package:ll/src/ui/details/terpene_chart.dart';
import 'package:ll/src/util/colors.dart';
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
  final Strain strain;

  /// Show the back button.
  final bool showBack;

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

  Future<void> _copyStrainData() async {
    await Clipboard.setData(
      ClipboardData(text: jsonEncode(widget.strain)),
    );
  }

  bool _hasNestedProperties(
    Map<String, dynamic>? Function(Strain strain) getValue,
  ) {
    try {
      final nest = getValue(widget.strain);

      if (nest == null || nest.isEmpty) return false;

      for (final value in nest.values) {
        if (value != null) return true;
      }
    } catch (_) {}

    return false;
  }

  String? _getTopTerp() {
    try {
      final topTerps = widget.strain.terpenes?.entries.toList()
        ?..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
      return topTerps?.first.key;
    } catch (_) {
      return null;
    }
  }

  String? _getTopEffect() {
    try {
      final topTerps = widget.strain.effects?.entries.toList()
        ?..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
      return topTerps?.first.key;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.strain.name;
    final description = widget.strain.description;
    final otherNames = widget.strain.otherNames?.join(', ');
    final averageRating = widget.strain.averageRating;
    final reviewCount = widget.strain.numberOfReviews;
    final category = widget.strain.category;
    final topTerp = _getTopTerp();
    final topEffect = _getTopEffect();
    final thc = widget.strain.thc;

    final hasTerps = _hasNestedProperties((s) => s.terpenes);
    final hasEffects = _hasNestedProperties((s) => s.effects);
    final hasCannabinoids = _hasNestedProperties((s) => s.cannabinoids);

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
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
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
                _paramTile('Reviews', reviewCount),
                const Divider(),
              ],
              if (category != null) ...[
                _paramTile('Category', category),
                const Divider(),
              ],

              if (topTerp != null) _paramTile('Main terpene', topTerp),
              if (hasTerps) TerpeneChart(strain: widget.strain),
              if (topTerp != null || hasTerps) const Divider(),

              if (topEffect != null) _paramTile('Main effect', topEffect),
              if (hasEffects) EffectsChart(strain: widget.strain),
              if (topEffect != null || hasEffects) const Divider(),

              if (thc != null)
                _paramTile('Average THC content', '${thc.round()}%'),
              if (hasCannabinoids) CannabinoidsChart(strain: widget.strain),
              if (thc != null || hasCannabinoids) const Divider(),

              if (name != null) NotesArea(strainName: name),
            ],
          ),
        ),
      ),
    );
  }
}
