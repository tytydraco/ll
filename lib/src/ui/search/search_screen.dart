import 'package:flutter/foundation.dart';
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

  /// Match name OR other names...
  bool _matchesName(Strain strain) {
    if (_nameController.text.isEmpty) return true;

    final matchedName = strain.name
            ?.toLowerCase()
            .contains(_nameController.text.toLowerCase()) ??
        false;

    final matchedOtherNames = strain.otherNames
            ?.map((e) => e.toLowerCase())
            .toList()
            .contains(_nameController.text.toLowerCase()) ??
        false;

    return matchedName || matchedOtherNames;
  }

  bool _matchesDescription(Strain strain) {
    if (_descriptionController.text.isEmpty) return true;

    return strain.description
            ?.toLowerCase()
            .contains(_descriptionController.text.toLowerCase()) ??
        false;
  }

  bool _matchesRatingRange(Strain strain) {
    // If a min range is set...
    if (_ratingRange.start != 0) {
      // Do not match un-rated strains.
      if (strain.averageRating == null) return false;
      if (strain.averageRating! < _ratingRange.start) return false;
    }

    // If a max range is set...
    if (_ratingRange.end != _maxRatingRange) {
      // Do not match un-rated strains.
      if (strain.averageRating == null) return false;
      if (strain.averageRating! > _ratingRange.end) return false;
    }

    return true;
  }

  bool _matchesReviewCountRange(Strain strain) {
    // If a min range is set...
    if (_reviewCountRange.start != 0) {
      // Do not match un-reviewed strains.
      if (strain.numberOfReviews == null) return false;
      if (strain.numberOfReviews! < _reviewCountRange.start) return false;
    }

    // If a max range is set...
    if (_reviewCountRange.end != _maxReviewCountRange) {
      // Do not match un-reviewed strains.
      if (strain.numberOfReviews == null) return false;
      if (strain.numberOfReviews! > _reviewCountRange.end) return false;
    }

    return true;
  }

  bool _matchesThcRange(Strain strain) {
    // If a min range is set...
    if (_thcRange.start != 0) {
      // Do not match non-thc-rated strains.
      if (strain.thc == null) return false;
      if (strain.thc! < _thcRange.start) return false;
    }

    // If a max range is set...
    if (_thcRange.end != _maxThcRange) {
      // Do not match non-thc-rated strains.
      if (strain.thc == null) return false;
      if (strain.thc! > _thcRange.end) return false;
    }

    return true;
  }

  bool _matchesCategory(Strain strain) {
    if (_categories.isEmpty) return false;

    final isTraditional =
        ['indica', 'hybrid', 'sativa'].contains(strain.category?.toLowerCase());

    if (!isTraditional) {
      return _categories.contains('other');
    }

    return _categories.contains(strain.category?.toLowerCase());
  }

  bool _matchesTerpenes(Strain strain) {
    final sortedTerpenes = strain.terpenes?.entries.toList()
      ?..sort((a, b) {
        return (b.value ?? 0).compareTo(a.value ?? 0);
      });

    if (_primaryTerpene != null) {
      if (sortedTerpenes?[0].value == null) return false;
      if (sortedTerpenes?[0].key != _primaryTerpene!.toLowerCase()) {
        return false;
      }
    }

    if (_secondaryTerpene != null) {
      if (sortedTerpenes?[1].value == null) return false;
      if (sortedTerpenes?[1].key != _secondaryTerpene!.toLowerCase()) {
        return false;
      }
    }

    if (_tertiaryTerpene != null) {
      if (sortedTerpenes?[2].value == null) return false;
      if (sortedTerpenes?[2].key != _tertiaryTerpene!.toLowerCase()) {
        return false;
      }
    }

    return true;
  }

  bool _matchesEffects(Strain strain) {
    final sortedEffects = strain.effects?.entries.toList()
      ?..sort((a, b) {
        return (b.value ?? 0).compareTo(a.value ?? 0);
      });

    if (_primaryEffect != null) {
      if (sortedEffects?[0].value == null) return false;
      if (sortedEffects?[0].key != _primaryEffect!.toLowerCase()) {
        return false;
      }
    }

    if (_secondaryEffect != null) {
      if (sortedEffects?[1].value == null) return false;
      if (sortedEffects?[1].key != _secondaryEffect!.toLowerCase()) {
        return false;
      }
    }

    if (_tertiaryEffect != null) {
      if (sortedEffects?[2].value == null) return false;
      if (sortedEffects?[2].key != _tertiaryEffect!.toLowerCase()) {
        return false;
      }
    }

    return true;
  }

  Future<void> _search() async {
    final savedStrains = await getSavedStrains();

    // Search through all strains with criteria.
    final results = savedStrains.where((strain) {
      if (kDebugMode) print('> Matching "${strain.name}"...');

      if (kDebugMode) print('${strain.name}: Matching name...');
      if (!_matchesName(strain)) return false;
      if (kDebugMode) print('${strain.name}: Matching description...');
      if (!_matchesDescription(strain)) return false;
      if (kDebugMode) print('${strain.name}: Matching rating...');
      if (!_matchesRatingRange(strain)) return false;
      if (kDebugMode) print('${strain.name}: Matching reviews...');
      if (!_matchesReviewCountRange(strain)) return false;
      if (kDebugMode) print('${strain.name}: Matching THC...');
      if (!_matchesThcRange(strain)) return false;
      if (kDebugMode) print('${strain.name}: Matching category...');
      if (!_matchesCategory(strain)) return false;
      if (kDebugMode) print('${strain.name}: Matching terpenes...');
      if (!_matchesTerpenes(strain)) return false;
      if (kDebugMode) print('${strain.name}: Matching effects...');
      if (!_matchesEffects(strain)) return false;

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
