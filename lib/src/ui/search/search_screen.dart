import 'package:flutter/material.dart';
import 'package:ll/src/data/strain.dart';
import 'package:ll/src/storage/save_file.dart';

/// Perform advanced queries.
class SearchScreen extends StatefulWidget {
  /// Creates a new [SearchScreen].
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _ratingRange = const RangeValues(0, 5);
  var _reviewCountRange = const RangeValues(0, 1000000);
  var _categories = <String>{'indica', 'hybrid', 'sativa'};

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
            true;
        if (!matchedName && matchedOtherNames) return false;
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
      if (strain.averageRating == null ||
          strain.averageRating! < _ratingRange.start ||
          strain.averageRating! > _ratingRange.end) {
        return false;
      }

      // Match review count...
      if (strain.numberOfReviews == null ||
          strain.numberOfReviews! < _reviewCountRange.start ||
          strain.numberOfReviews! > _reviewCountRange.end) {
        return false;
      }

      // Match categories...
      if (_categories.isEmpty) {
        // If categories == [], then disallow any strains that ARE valid
        // categories
        final matchesCategory = ['indica', 'hybrid', 'sativa']
            .contains(strain.category?.toLowerCase());
        if (matchesCategory) return false;
      } else {
        final matchesCategory =
            _categories.contains(strain.category?.toLowerCase());
        if (!matchesCategory) return false;
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
          fontSize: 18,
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
      body: ListView(
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
            max: 5,
            divisions: 50,
            labels: RangeLabels(
              _ratingRange.start.toString(),
              _ratingRange.end.toString(),
            ),
            onChanged: (value) {
              setState(() {
                final roundedStart =
                    double.parse(value.start.toStringAsFixed(2));
                final roundedEnd = double.parse(value.end.toStringAsFixed(2));
                _ratingRange = RangeValues(roundedStart, roundedEnd);
              });
            },
          ),
          const Divider(),
          _buildLabel('Reviews'),
          RangeSlider(
            values: _reviewCountRange,
            max: 1000000,
            divisions: 1000000,
            labels: RangeLabels(
              _reviewCountRange.start.round().toString(),
              _reviewCountRange.end.round().toString(),
            ),
            onChanged: (value) {
              setState(() {
                _reviewCountRange = value;
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
                  label: Text('Indica', style: TextStyle(fontSize: 18)),
                ),
                ButtonSegment(
                  value: 'hybrid',
                  label: Text('Hybrid', style: TextStyle(fontSize: 18)),
                ),
                ButtonSegment(
                  value: 'sativa',
                  label: Text('Sativa', style: TextStyle(fontSize: 18)),
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
        ],
      ),
    );
  }
}
