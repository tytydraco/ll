import 'package:flutter/material.dart';
import 'package:ll/src/storage/save_file.dart';
import 'package:ll/src/ui/details/details_screen.dart';
import 'package:ll/src/ui/search/search_screen.dart';
import 'package:ll/src/ui/strain_list_tile.dart';
import 'package:ll/src/util/safe_json.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bookmark strains for later..
class BookmarksScreen extends StatefulWidget {
  /// Creates a new [BookmarksScreen].
  const BookmarksScreen({
    super.key,
  });

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _strains = <Map<String, dynamic>>[];

  Future<void> _addStrain() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => SearchScreen(
          selectMode: true,
          onSelect: (strain) async {
            Navigator.pop(context);

            setState(() {
              _strains.add(strain);
            });

            await _saveBookmarks();
          },
        ),
      ),
    );
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final strainNames = _strains.map((strain) {
      final strainSafe = SafeJson(strain);
      return strainSafe.get<String>('name') ?? 'N/A';
    }).toSet();
    await prefs.setStringList('favorites', strainNames.toList());
  }

  Future<void> _getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final strainNames = prefs.getStringList('favorites') ?? [];

    final savedStrains = await getSavedStrains();
    final bookmarkedStrains = savedStrains.where((strain) {
      final strainSafe = SafeJson(strain);
      final strainName = strainSafe.get<String>('name') ?? 'N/A';

      return strainNames.contains(strainName);
    }).toList();

    setState(() {
      _strains
        ..clear()
        ..addAll(bookmarkedStrains);
    });
  }

  @override
  void initState() {
    super.initState();
    _getBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
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
        ],
      ),
      body: _strains.isNotEmpty
          ? ListView.separated(
              itemBuilder: (context, index) {
                final strain = _strains[index];
                return StrainListTile(
                  strain: strain,
                  leading: IconButton(
                    onPressed: () async {
                      setState(() {
                        _strains.removeAt(index);
                      });

                      await _saveBookmarks();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  onSelect: (strain) {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => DetailsScreen(strain: strain),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: _strains.length,
            )
          : const Center(
              child: Text('Add strains to bookmark.'),
            ),
    );
  }
}
