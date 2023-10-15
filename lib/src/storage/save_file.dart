import 'dart:convert';
import 'dart:io';

import 'package:ll/src/util/safe_json.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _saveFileName = 'll_saved_strains.json';
final _directory = getApplicationCacheDirectory();

/// Save the strains to the save file.
Future<void> setSavedStrains(List<Map<String, dynamic>> strains) async {
  final directory = await _directory;

  final saveFile = File('${directory.path}/$_saveFileName');
  await saveFile.writeAsString(jsonEncode(strains));
}

/// Fetch the strains from the save file.
Future<List<Map<String, dynamic>>> getSavedStrains() async {
  final directory = await _directory;

  final saveFile = File('${directory.path}/$_saveFileName');
  if (!saveFile.existsSync()) return [];

  final saveFileContents = await saveFile.readAsString();
  final saveFileJson = jsonDecode(saveFileContents) as List<dynamic>;

  return saveFileJson.cast<Map<String, dynamic>>().toList();
}

/// Fetch saved strains given the strain names.
Future<List<Map<String, dynamic>>> getSavedStrainsByName(
  List<String> strainNames,
) async {
  final savedStrains = await getSavedStrains();
  final strains = savedStrains.where((strain) {
    final strainSafe = SafeJson(strain);
    final strainName = strainSafe.get<String>('name') ?? 'N/A';
    return strainNames.contains(strainName);
  }).toList();

  return strains;
}

/// Fetch saved strains that are bookmarked.
Future<List<Map<String, dynamic>>> getSavedBookmarkedStrains() async {
  final prefs = await SharedPreferences.getInstance();
  final bookmarkedStrainNames = prefs.getStringList('bookmarks') ?? [];

  final savedStrains = await getSavedStrains();
  return savedStrains.where((strain) {
    final strainSafe = SafeJson(strain);
    final strainName = strainSafe.get<String>('name') ?? 'N/A';

    return bookmarkedStrainNames.contains(strainName);
  }).toList();
}
