import 'package:flutter/material.dart';
import 'package:ll/src/data/strain.dart';
import 'package:ll/src/storage/save_file.dart';
import 'package:ll/src/ui/search/effect_dropdown.dart';
import 'package:ll/src/ui/search/terpene_dropdown.dart';

/// Perform advanced queries.
class SearchScreen extends StatefulWidget {
  /// Creates a new [SearchScreen].
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

const _maxRatingRange = 5.0;
const _maxReviewCountRange = 1000.0;
const _maxThcRange = 100.0;

class _SearchScreenState extends State<SearchScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _ratingRange = const RangeValues(0, _maxRatingRange);
  var _reviewCountRange = const RangeValues(0, _maxReviewCountRange);
  var _thcRange = const RangeValues(0, _maxThcRange);
  var _categories = <String>{'indica', 'hybrid', 'sativa'};
  String? _primaryTerpene;
  String? _secondaryTerpene;
  String? _tertiaryTerpene;
  String? _primaryEffect;
  String? _secondaryEffect;
  String? _tertiaryEffect;

  Future<void> _search() async {
    final savedStrains = await getSavedStrains();

    // Search through all strains with criteria.
    final results = savedStrains.where((strain) {
      // Match name OR other names...
      if (_nameController.text.isNotEmpty) {
        final matchedName = strain.name
                ?.toLowerCase()
                .contains(_nameController.text.toLowerCase()) ??
            false;
        final matchedOtherNames = strain.otherNames
                ?.map((e) => e.toLowerCase())
                .toList()
                .contains(_nameController.text.toLowerCase()) ??
            false;
        if (!matchedName && !matchedOtherNames) return false;
      }

      // Match description...
      if (_descriptionController.text.isNotEmpty) {
        final matchedDescription = strain.description
                ?.toLowerCase()
                .contains(_descriptionController.text.toLowerCase()) ??
            false;
        if (!matchedDescription) return false;
      }

      // Match ratings...
      if (_ratingRange.start != 0) {
        if (strain.averageRating == null ||
            strain.averageRating! < _ratingRange.start ||
            (strain.averageRating! > _ratingRange.end ||
                _ratingRange.end == _maxRatingRange)) {
          return false;
        }
      }

      // Match review count...
      if (_reviewCountRange.start != 0) {
        if (strain.numberOfReviews == null ||
            strain.numberOfReviews! < _reviewCountRange.start ||
            (strain.numberOfReviews! > _reviewCountRange.end ||
                _reviewCountRange.end == _maxReviewCountRange)) {
          return false;
        }
      }

      // Match THC content...
      if (_thcRange.start != 0) {
        if (strain.thc == null ||
            strain.thc! < _thcRange.start ||
            (strain.thc! > _thcRange.end || _thcRange.end == _maxThcRange)) {
          return false;
        }
      }

      if (_categories.isNotEmpty) {
        final isTraditionalStrain = ['indica', 'hybrid', 'sativa']
            .contains(strain.category?.toLowerCase());

        if (isTraditionalStrain) {
          final matchesCategory =
              _categories.contains(strain.category?.toLowerCase());
          if (!matchesCategory) return false;
        } else {
          final isNonTraditionalAllowed = _categories.contains('other');
          if (!isNonTraditionalAllowed) return false;
        }
      } else {
        // Impossible query.
        return false;
      }

      // Calculate strain terpene contents...
      final sortedTerpenes = strain.terpenes?.entries.toList()
        ?..sort((a, b) {
          return (b.value ?? 0).compareTo(a.value ?? 0);
        });
      final strainPrimaryTerpene = sortedTerpenes?[0].key.toLowerCase();
      final strainSecondaryTerpene = sortedTerpenes?[1].key.toLowerCase();
      final strainTertiaryTerpene = sortedTerpenes?[2].key.toLowerCase();

      // Match primary terpene...
      if (_primaryTerpene != null && _primaryTerpene != strainPrimaryTerpene) {
        return false;
      }

      // Match secondary terpene...
      if (_secondaryTerpene != null &&
          _secondaryTerpene != strainSecondaryTerpene) {
        return false;
      }

      // Match tertiary terpene...
      if (_tertiaryTerpene != null &&
          _tertiaryTerpene != strainTertiaryTerpene) {
        return false;
      }

      // Calculate strain effect scores...
      final sortedEffects = strain.effects?.entries.toList()
        ?..sort((a, b) {
          return (b.value ?? 0).compareTo(a.value ?? 0);
        });
      final strainPrimaryEffect = sortedEffects?[0].key.toLowerCase();
      final strainSecondaryEffect = sortedEffects?[1].key.toLowerCase();
      final strainTertiaryEffect = sortedEffects?[2].key.toLowerCase();

      // Match primary effect...
      if (_primaryEffect != null && _primaryEffect != strainPrimaryEffect) {
        return false;
      }

      // Match secondary effect...
      if (_secondaryEffect != null &&
          _secondaryEffect != strainSecondaryEffect) {
        return false;
      }

      // Match tertiary effect...
      if (_tertiaryEffect != null && _tertiaryEffect != strainTertiaryEffect) {
        return false;
      }

      return true;
    }).toList();

    if (context.mounted) Navigator.pop<List<Strain>>(context, results);
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Search'),
        onPressed: _search,
        icon: const Icon(Icons.search),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              _buildLabel('Name'),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name...',
                ),
              ),
              const Divider(),
              _buildLabel('Description'),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Description...',
                ),
              ),
              const Divider(),
              _buildLabel('Rating'),
              RangeSlider(
                values: _ratingRange,
                max: _maxRatingRange,
                divisions: 50,
                labels: RangeLabels(
                  _ratingRange.start.toString(),
                  _ratingRange.end.toString() +
                      (_ratingRange.end == _maxRatingRange ? '+' : ''),
                ),
                onChanged: (value) {
                  setState(() {
                    final roundedStart =
                        double.parse(value.start.toStringAsFixed(2));
                    final roundedEnd =
                        double.parse(value.end.toStringAsFixed(2));
                    _ratingRange = RangeValues(roundedStart, roundedEnd);
                  });
                },
              ),
              const Divider(),
              _buildLabel('Reviews'),
              RangeSlider(
                values: _reviewCountRange,
                max: _maxReviewCountRange,
                divisions: 100,
                labels: RangeLabels(
                  _reviewCountRange.start.round().toString(),
                  _reviewCountRange.end.round().toString() +
                      (_reviewCountRange.end == _maxReviewCountRange
                          ? '+'
                          : ''),
                ),
                onChanged: (value) {
                  setState(() {
                    _reviewCountRange = value;
                  });
                },
              ),
              const Divider(),
              _buildLabel('Average THC content'),
              RangeSlider(
                values: _thcRange,
                max: _maxThcRange,
                divisions: 100,
                labels: RangeLabels(
                  '${_thcRange.start.round()}%',
                  '${_thcRange.end.round()}%'
                      '${_thcRange.end == _maxThcRange ? '+' : ''}',
                ),
                onChanged: (value) {
                  setState(() {
                    _thcRange = value;
                  });
                },
              ),
              const Divider(),
              _buildLabel('Category'),
              Padding(
                padding: const EdgeInsets.all(8),
                child: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: 'indica',
                      label: Text('Indica'),
                    ),
                    ButtonSegment(
                      value: 'hybrid',
                      label: Text('Hybrid'),
                    ),
                    ButtonSegment(
                      value: 'sativa',
                      label: Text('Sativa'),
                    ),
                    ButtonSegment(
                      value: 'other',
                      label: Text('Other'),
                    ),
                  ],
                  selected: _categories,
                  emptySelectionAllowed: true,
                  multiSelectionEnabled: true,
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _categories = selection;
                    });
                  },
                ),
              ),
              const Divider(),
              _buildLabel('Terpenes'),
              _buildLabel('Primary terpene'),
              TerpeneDropdown(
                onSelect: (terpene) {
                  setState(() {
                    _primaryTerpene = terpene;
                  });
                },
              ),
              _buildLabel('Secondary terpene'),
              TerpeneDropdown(
                onSelect: (terpene) {
                  setState(() {
                    _secondaryTerpene = terpene;
                  });
                },
              ),
              _buildLabel('Tertiary terpene'),
              TerpeneDropdown(
                onSelect: (terpene) {
                  setState(() {
                    _tertiaryTerpene = terpene;
                  });
                },
              ),
              const Divider(),
              _buildLabel('Effects'),
              _buildLabel('Primary effect'),
              EffectDropdown(
                onSelect: (effect) {
                  setState(() {
                    _primaryEffect = effect;
                  });
                },
              ),
              _buildLabel('Secondary effect'),
              EffectDropdown(
                onSelect: (effect) {
                  setState(() {
                    _secondaryEffect = effect;
                  });
                },
              ),
              _buildLabel('Tertiary effect'),
              EffectDropdown(
                onSelect: (effect) {
                  setState(() {
                    _tertiaryEffect = effect;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
