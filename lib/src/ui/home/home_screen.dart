import 'package:flutter/material.dart';
import 'package:ll/src/api/leafly_api.dart';
import 'package:ll/src/ui/details/details_screen.dart';

/// The home screen.
class HomeScreen extends StatefulWidget {
  /// Creates a new [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _strains = <dynamic>[];
  List<dynamic>? _filteredStrains;
  final _searchController = TextEditingController();

  Future<void> _updateStrains() async {
    await for (final strain in fetchStrains()) {
      setState(() {
        _strains.add(strain);
      });
    }
  }

  void _filterStrains(String searchTerm) {
    if (searchTerm == '') {
      setState(() {
        _filteredStrains = null;
      });

      return;
    }

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
      final strain = rawStrain as Map<String, dynamic>;
      final name = strain['name'] as String;
      final otherNames = getOtherNames(strain);

      if (name.toLowerCase().contains(reducedTerm)) return true;

      for (final otherName in otherNames) {
        if (otherName.toLowerCase().contains(reducedTerm)) return true;
      }

      return false;
    }).toList();

    setState(() {
      _filteredStrains = filteredStrains;
    });
  }

  Color _strainColor(String? category) {
    switch (category) {
      case 'Indica':
        return Colors.blue;
      case 'Hybrid':
        return Colors.green;
      case 'Sativa':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  void initState() {
    super.initState();
    _updateStrains();
  }

  @override
  Widget build(BuildContext context) {
    final strains = (_filteredStrains != null) ? _filteredStrains! : _strains;

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
          onChanged: _filterStrains,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _updateStrains,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final strain = strains[index] as Map<String, dynamic>;

            return ListTile(
              title: Text(strain['name'] as String),
              trailing: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: _strainColor(strain['category'] as String?),
                ),
              ),
              onTap: () {
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
          itemCount: strains.length,
        ),
      ),
    );
  }
}
