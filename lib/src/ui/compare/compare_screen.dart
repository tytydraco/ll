import 'package:flutter/material.dart';
import 'package:ll/src/storage/save_file.dart';
import 'package:ll/src/ui/details/details_screen.dart';
import 'package:ll/src/ui/search/search_screen.dart';
import 'package:ll/src/ui/strain_list_tile.dart';

/// Compare multiple strains against each other.
class CompareScreen extends StatefulWidget {
  /// Creates a new [CompareScreen].
  const CompareScreen({
    super.key,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _strains = <Map<String, dynamic>>[];

  Future<void> _addBookmarkedStrains() async {
    final bookmarkedStrains = await getSavedBookmarkedStrains();

    setState(() {
      _strains.addAll(bookmarkedStrains);
    });
  }

  Future<void> _addStrain() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => SearchScreen(
          selectMode: true,
          onSelect: (strain) {
            Navigator.pop(context);
            setState(() {
              _strains.add(strain);
            });
          },
        ),
      ),
    );
  }

  Future<void> _compare() async {
    if (_strains.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to compare.'),
        ),
      );
      return;
    }

    await Navigator.push(context, MaterialPageRoute<void>(
      builder: (context) {
        final pages = _strains.asMap().entries.map((e) {
          final index = e.key;
          final strain = e.value;

          return Flexible(
            child: DetailsScreen(
              strain: strain,
              showBack: index == 0,
            ),
          );
        }).toList();

        // Responsive layout; maximize usable space.
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > constraints.maxHeight) {
              return Row(
                children: pages,
              );
            } else {
              return Column(
                children: pages,
              );
            }
          },
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _addBookmarkedStrains,
            icon: const Icon(Icons.bookmark_add),
          ),
          IconButton(
            onPressed: _addStrain,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _compare,
        child: const Icon(Icons.compare),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _strains.isNotEmpty
          ? ListView.separated(
              itemBuilder: (context, index) {
                final strain = _strains[index];
                return StrainListTile(
                  strain: strain,
                  leading: IconButton(
                    onPressed: () {
                      setState(() {
                        _strains.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: _strains.length,
            )
          : const Center(
              child: Text('Add strains to compare.'),
            ),
    );
  }
}
