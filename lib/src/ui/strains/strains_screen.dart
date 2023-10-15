import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ll/src/api/leafly_api.dart';
import 'package:ll/src/storage/save_file.dart';
import 'package:ll/src/ui/bookmarks/bookmarks_screen.dart';
import 'package:ll/src/ui/compare/compare_screen.dart';
import 'package:ll/src/ui/merge/merge_screen.dart';
import 'package:ll/src/ui/strain_list_tile.dart';
import 'package:ll/src/util/safe_json.dart';
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
  final void Function(Map<String, dynamic> strain)? onSelect;

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
        _strains
          ..clear()
          ..addAll(savedStrains);
      });
    }
  }

  Future<void> _updateStrains() async {
    // Fetch from the web.
    await for (final strain in fetchStrains()) {
      setState(() {
        _strains.add(strain);
      });

      if (kDebugMode) print('Strains: ${_strains.length}');
    }

    // Update the save file.
    await setSavedStrains(_strains.toList());
  }

  List<Map<String, dynamic>> _filterStrains(String searchTerm) {
    if (searchTerm == '') return [];

    List<String> getOtherNames(Map<String, dynamic> strain) {
      final strainSafe = SafeJson(strain);
      final otherNamesRaw = strainSafe.get<String>('subtitle');

      // No other names...
      if (otherNamesRaw == null) return [];

      // Remove "Aka strain A, strain B, ..." fluff => 'strain A,strainB,...'
      final otherNames = otherNamesRaw.replaceAll('aka', '').split(',');

      return otherNames;
    }

    // Ignore case.
    final reducedTerm = searchTerm.toLowerCase();

    // Filter for strains that contain the strain name or other names.
    final filteredStrains = _strains.where((strain) {
      final strainSafe = SafeJson(strain);
      final name = strainSafe.get<String>('name') ?? 'N/A';
      final otherNames = getOtherNames(strain);

      if (name.toLowerCase().contains(reducedTerm)) return true;

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
      final strain = jsonDecode(content!) as Map<String, dynamic>;
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
      final strain = jsonDecode(content!) as Map<String, dynamic>;

      final strainSafe = SafeJson(strain);
      final strainName = strainSafe.get<String>('name') ?? 'N/A';

      setState(() {
        _strains.add(strain);
      });

      await addSavedStrain(strain);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported "$strainName".'),
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

  @override
  void initState() {
    super.initState();
    _loadSavedStrains();
  }

  @override
  Widget build(BuildContext context) {
    if (_searchController.text.isEmpty) {
      _filteredStrains
        ..clear()
        ..addAll(_strains);
    } else {
      _filteredStrains
        ..clear()
        ..addAll(_filterStrains(_searchController.text));
    }

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
          onChanged: (value) {
            setState(() {});
          },
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
              if (!widget.selectMode)
                PopupMenuItem<void>(
                  onTap: _showBookmarks,
                  child: const Text('Bookmarks'),
                ),
              if (!widget.selectMode)
                PopupMenuItem<void>(
                  onTap: _mergeStrains,
                  child: const Text('Merge'),
                ),
              if (!widget.selectMode)
                PopupMenuItem<void>(
                  onTap: _compareStrains,
                  child: const Text('Compare'),
                ),
              PopupMenuItem<void>(
                onTap: _importClipboardStrain,
                child: const Text('Import from clipboard'),
              ),
              PopupMenuItem<void>(
                onTap: _selectClipboardStrain,
                child: const Text('Select from clipboard'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
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
                          child: Text('Pull to update.'),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
