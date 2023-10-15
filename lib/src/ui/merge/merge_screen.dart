import 'package:flutter/material.dart';
import 'package:ll/src/storage/save_file.dart';
import 'package:ll/src/ui/details/details_screen.dart';
import 'package:ll/src/ui/search/search_screen.dart';
import 'package:ll/src/ui/strain_list_tile.dart';
import 'package:ll/src/util/strain_merge.dart';
import 'package:ll/src/util/strain_set.dart';

/// Compare multiple strains against each other.
class MergeScreen extends StatefulWidget {
  /// Creates a new [MergeScreen].
  const MergeScreen({
    super.key,
  });

  @override
  State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  final _strains = createStrainsSet();

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

  Future<void> _merge() async {
    if (_strains.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to merge.'),
        ),
      );
      return;
    }

    if (_strains.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least two strains.'),
        ),
      );
      return;
    }

    final mergeStrain = StrainMerge(strains: _strains).merge();

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailsScreen(strain: mergeStrain),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge'),
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
            onPressed: _addStrain,
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                onTap: _addBookmarkedStrains,
                child: const Text('Import bookmarks'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Merge'),
        onPressed: _merge,
        icon: const Icon(Icons.merge),
      ),
      body: _strains.isNotEmpty
          ? ListView.separated(
              itemBuilder: (context, index) {
                final strain = _strains.toList()[index];

                return StrainListTile(
                  strain: strain,
                  leading: IconButton(
                    onPressed: () {
                      setState(() {
                        _strains.remove(strain);
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
              child: Text('Add strains to merge.'),
            ),
    );
  }
}
