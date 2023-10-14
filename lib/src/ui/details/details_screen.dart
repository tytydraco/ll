import 'package:flutter/material.dart';

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
    var formattedContent = content.toString();
    formattedContent = formattedContent.replaceFirst(
      formattedContent[0],
      formattedContent[0].toUpperCase(),
    );

    return ListTile(
      title: Text(title),
      subtitle: Text(formattedContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.strain['name'] as String),
      ),
      body: ListView(
        children: [
          Image.network(widget.strain['nugImage'] as String),
          _paramTile('Description', widget.strain['shortDescriptionPlain']),
          const Divider(),
          _paramTile('Other names', widget.strain['subtitle']),
          const Divider(),
          _paramTile('Id', widget.strain['id']),
          const Divider(),
          _paramTile('Average rating', widget.strain['averageRating']),
          const Divider(),
          _paramTile('Ratings', widget.strain['reviewCount']),
          const Divider(),
          _paramTile('Category', widget.strain['category']),
          const Divider(),
          _paramTile('Phenotype', widget.strain['phenotype']),
          const Divider(),
          _paramTile('THC %', '${(widget.strain['thc'] as double).round()}%'),
          const Divider(),
          _paramTile('Main terpene', widget.strain['strainTopTerp']),
          const Divider(),
          _paramTile('Main effect', widget.strain['topEffect']),
          const Divider(),
          _paramTile('Aroused', widget.strain['effects']['aroused']['score']),
          const Divider(),
          _paramTile('Creative', widget.strain['effects']['creative']['score']),
          const Divider(),
          _paramTile(
              'Energetic', widget.strain['effects']['creative']['score']),
          const Divider(),
          _paramTile('Euphoric', widget.strain['effects']['creative']['score']),
          const Divider(),
          _paramTile('Focused', widget.strain['effects']['creative']['score']),
          const Divider(),
          _paramTile('Giggly', widget.strain['effects']['giggly']['score']),
          const Divider(),
          _paramTile('Happy', widget.strain['effects']['happy']['score']),
          const Divider(),
          _paramTile('Hungry', widget.strain['effects']['hungry']['score']),
          const Divider(),
          _paramTile('Relaxed', widget.strain['effects']['relaxed']['score']),
          const Divider(),
          _paramTile('Sleepy', widget.strain['effects']['sleepy']['score']),
          const Divider(),
          _paramTile(
              'Talkative', widget.strain['effects']['talkative']['score']),
          const Divider(),
          _paramTile('Tingly', widget.strain['effects']['tingly']['score']),
          const Divider(),
          _paramTile('Uplifted', widget.strain['effects']['uplifted']['score']),
          const Divider(),
          _paramTile('Caryophyllene',
              widget.strain['terps']['caryophyllene']['score']),
          const Divider(),
          _paramTile('Humulene', widget.strain['terps']['humulene']['score']),
          const Divider(),
          _paramTile('Limonene', widget.strain['terps']['limonene']['score']),
          const Divider(),
          _paramTile('Linalool', widget.strain['terps']['linalool']['score']),
          const Divider(),
          _paramTile('Myrcene', widget.strain['terps']['myrcene']['score']),
          const Divider(),
          _paramTile('Ocimene', widget.strain['terps']['ocimene']['score']),
          const Divider(),
          _paramTile('Pinene', widget.strain['terps']['pinene']['score']),
          const Divider(),
          _paramTile(
              'Terpinolene', widget.strain['terps']['terpinolene']['score']),
          const Divider(),
          _paramTile('CBC', widget.strain['cannabinoids']['cbc']['order']),
          const Divider(),
          _paramTile('CBD', widget.strain['cannabinoids']['cbd']['order']),
          const Divider(),
          _paramTile('CBG', widget.strain['cannabinoids']['cbg']['order']),
          const Divider(),
          _paramTile('THC', widget.strain['cannabinoids']['thc']['order']),
          const Divider(),
          _paramTile('THCV', widget.strain['cannabinoids']['thcv']['order']),
          const Divider(),
        ],
      ),
    );
  }
}
