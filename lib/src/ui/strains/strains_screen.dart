import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ll/src/api/leafly_api.dart';
import 'package:ll/src/data/strain.dart';
import 'package:ll/src/storage/save_file.dart';
import 'package:ll/src/ui/bookmarks/bookmarks_screen.dart';
import 'package:ll/src/ui/compare/compare_screen.dart';
import 'package:ll/src/ui/merge/merge_screen.dart';
import 'package:ll/src/ui/search/search_screen.dart';
import 'package:ll/src/ui/strain_list_tile.dart';
import 'package:ll/src/util/strain_set.dart';

/// The strains screen.
class StrainsScreen extends StatefulWidget {
  /// Creates a new [StrainsScreen].
  const StrainsScreen({
    super.key,
    this.onSelect,
    this.selectMode = false,
  });

  /// Triggered when user selects a strain.
  final void Function(Strain strain)? onSelect;

  /// Whether or not the user is trying to select a single strain. This will
  /// hide the unnecessary buttons.
  final bool selectMode;

  @override
  State<StrainsScreen> createState() => _StrainsScreenState();
}

class _StrainsScreenState extends State<StrainsScreen> {
  final _strains = createStrainsSet();
  final _filteredStrains = createStrainsSet();

  final _searchController = TextEditingController();

  Future<void> _loadSavedStrains() async {
    // Set strains to contents of save file.
    final savedStrains = await getSavedStrains();
    if (savedStrains.isNotEmpty) {
      setState(() {
        _strains.addAll(savedStrains);
      });
    }
  }

  Future<void> _updateStrains() async {
    // Fetch from the web.
    await for (final strain in fetchStrains()) {
      _strains
        ..removeWhere((e) => e.name == strain.name)
        ..add(strain);
      _updateFilter();

      if (kDebugMode) print('(Total: ${_strains.length})\t${strain.name}');
    }

    // Update the save file.
    await setSavedStrains(_strains.toList());
  }

  List<Strain> _filterStrains(String searchTerm) {
    if (searchTerm == '') return [];

    // Ignore case.
    final reducedTerm = searchTerm.toLowerCase();

    // Filter for strains that contain the strain name or other names.
    final filteredStrains = _strains.where((strain) {
      // Search by name...
      final name = strain.name ?? 'N/A';
      if (name.toLowerCase().contains(reducedTerm)) return true;

      // Search by other names...
      final otherNames = strain.otherNames ?? [];
      for (final otherName in otherNames) {
        if (otherName.toLowerCase().contains(reducedTerm)) return true;
      }

      return false;
    }).toList();

    return filteredStrains;
  }

  Future<void> _compareStrains() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const CompareScreen(),
      ),
    );
  }

  Future<void> _mergeStrains() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const MergeScreen(),
      ),
    );
  }

  Future<void> _showBookmarks() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const BookmarksScreen(),
      ),
    );
  }

  Future<void> _selectClipboardStrain() async {
    // Read clipboard data.
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final content = clipboard?.text;

    try {
      // Try to show detail screen for clipboard strain.
      final strainRaw = jsonDecode(content!) as Map<String, dynamic>;
      final strain = Strain.fromJson(strainRaw);
      widget.onSelect?.call(strain);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to parse clipboard strain.'),
        ),
      );
    }
  }

  Future<void> _importClipboardStrain() async {
    // Read clipboard data.
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final content = clipboard?.text;

    try {
      // Try to show detail screen for clipboard strain.
      final strainRaw = jsonDecode(content!) as Map<String, dynamic>;
      final strain = Strain.fromJson(strainRaw);

      _strains.add(strain);
      _updateFilter();

      await addSavedStrain(strain);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported "${strain.name ?? 'N/A'}".'),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to parse clipboard strain.'),
        ),
      );
    }
  }

  Future<void> _selectRandom() async {
    if (_strains.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No strains to choose.'),
        ),
      );
      return;
    }

    final randomIndex = Random().nextInt(_strains.length);
    final randomStrain = _strains.toList()[randomIndex];
    widget.onSelect?.call(randomStrain);
  }

  Future<void> _filterFromSearch() async {
    final strains = await Navigator.push(
      context,
      MaterialPageRoute<List<Strain>>(
        builder: (_) => const SearchScreen(),
      ),
    );

    // Ignore if user did not search.
    if (strains == null) return;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${strains.length} matches.'),
        ),
      );
    }

    setState(() {
      _searchController.clear();
      _filteredStrains.clear();
      if (strains.isNotEmpty) _filteredStrains.addAll(strains);
    });
  }

  Future<void> _askToDeleteStrain(Strain strain) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm deletion'),
            content: Text('Delete "${strain.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      _strains.remove(strain);
      _updateFilter();

      await setSavedStrains(_strains.toList());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${strain.name ?? 'N/A'}".'),
          ),
        );
      }
    }
  }

  void _updateFilter() {
    final searchTerm = _searchController.text;
    final newStrains =
        searchTerm.isNotEmpty ? _filterStrains(searchTerm) : _strains;

    setState(() {
      _filteredStrains
        ..clear()
        ..addAll(newStrains);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedStrains().whenComplete(_updateFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (_) => _updateFilter(),
        ),
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
          PopupMenuButton(
            onSelected: (value) {},
            itemBuilder: (context) => [
              if (!widget.selectMode) ...[
                PopupMenuItem<void>(
                  onTap: _showBookmarks,
                  child: const Text('Bookmarks'),
                ),
                PopupMenuItem<void>(
                  onTap: _mergeStrains,
                  child: const Text('Merge'),
                ),
                PopupMenuItem<void>(
                  onTap: _compareStrains,
                  child: const Text('Compare'),
                ),
              ],
              PopupMenuItem<void>(
                onTap: _importClipboardStrain,
                child: const Text('Import from clipboard'),
              ),
              PopupMenuItem<void>(
                onTap: _selectClipboardStrain,
                child: const Text('Select from clipboard'),
              ),
              PopupMenuItem<void>(
                onTap: _selectRandom,
                child: const Text('Random'),
              ),
              PopupMenuItem<void>(
                onTap: _filterFromSearch,
                child: const Text('Advanced search'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: RefreshIndicator(
            onRefresh: _updateStrains,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: _filteredStrains.isNotEmpty
                  ? ListView.separated(
                      itemBuilder: (context, index) {
                        final strain = _filteredStrains.toList()[index];
                        return StrainListTile(
                          strain: strain,
                          onSelect: widget.onSelect,
                          onDelete: _askToDeleteStrain,
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: _filteredStrains.length,
                    )
                  : const Center(
                      child: CustomScrollView(
                        slivers: [
                          SliverFillRemaining(
                            child: Center(
                              child: Text('No strains found.'),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
