import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ll/src/api/leafly_api.dart';
import 'package:ll/src/storage/save_file.dart';
import 'package:ll/src/util/strain_colors.dart';

/// The search screen.
class SearchScreen extends StatefulWidget {
  /// Creates a new [SearchScreen].
  const SearchScreen({
    super.key,
    this.onSelect,
  });

  /// Triggered when user selects a strain.
  final void Function(Map<String, dynamic> strain)? onSelect;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Strain objects sorted by name number in ascending order.
  final _strains = SplayTreeSet<Map<String, dynamic>>((key1, key2) {
    return (key1['name'] as String)
        .toLowerCase()
        .compareTo((key2['name'] as String).toLowerCase());
  });

  var _filteredStrains = <Map<String, dynamic>>[];

  final _searchController = TextEditingController();

  Future<void> _loadSavedStrains() async {
    // Get strains to contents of save file.
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
    _strains.clear();
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
      final otherNamesRaw = strain['subtitle'] as String?;

      // No other names...
      if (otherNamesRaw == null) return [];

      // Remove "Aka strain A, strain B, ..." fluff => 'strain A,strainB,...'
      final otherNames = otherNamesRaw.replaceAll('aka', '').split(',');

      return otherNames;
    }

    // Ignore case.
    final reducedTerm = searchTerm.toLowerCase();

    // Filter for strains that contain the strain name or other names.
    final filteredStrains = _strains.where((rawStrain) {
      final strain = rawStrain;
      final name = strain['name'] as String? ?? 'N/A';
      final otherNames = getOtherNames(strain);

      if (name.toLowerCase().contains(reducedTerm)) return true;

      for (final otherName in otherNames) {
        if (otherName.toLowerCase().contains(reducedTerm)) return true;
      }

      return false;
    }).toList();

    return filteredStrains;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedStrains();
  }

  @override
  Widget build(BuildContext context) {
    if (_searchController.text.isEmpty) {
      _filteredStrains = _strains.toList();
    } else {
      _filteredStrains = _filterStrains(_searchController.text);
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
                    final strain = _filteredStrains[index];

                    return ListTile(
                      title: Text(strain['name'] as String? ?? 'N/A'),
                      trailing: FaIcon(
                        FontAwesomeIcons.canadianMapleLeaf,
                        color: getStrainColor(strain['category'] as String?),
                      ),
                      onTap: () => widget.onSelect?.call(strain),
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
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}