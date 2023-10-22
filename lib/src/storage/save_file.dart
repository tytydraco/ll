import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:ll/src/data/strain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _saveFileName = 'strain_database.json';
final _directory = getApplicationDocumentsDirectory();

/// Save the strains to the save file.
Future<void> setSavedStrains(List<Strain> strains) async {
  // Web client uses shared preferences.
  if (!kIsWeb) {
    final directory = await _directory;

    final saveFile = File('${directory.path}/$_saveFileName');
    await saveFile.writeAsString(jsonEncode(strains));
  } else {
    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(strains);
    final encodedJson = utf8.encode(json);
    final gzipJson = GZipEncoder().encode(encodedJson)!;
    final base64Json = base64.encode(gzipJson);

    await prefs.setString('strain_database', base64Json);
  }
}

/// Fetch the strains from the save file.
Future<List<Strain>> getSavedStrains() async {
  // Web client uses shared preferences.
  if (!kIsWeb) {
    final directory = await _directory;

    final saveFile = File('${directory.path}/$_saveFileName');
    if (!saveFile.existsSync()) return [];

    final saveFileContents = await saveFile.readAsString();
    final saveFileJson = jsonDecode(saveFileContents) as List<dynamic>;

    return saveFileJson
        .cast<Map<String, dynamic>>()
        .map(Strain.fromJson)
        .toList();
  } else {
    final prefs = await SharedPreferences.getInstance();

    final savedContent = prefs.getString('strain_database') ?? '';
    if (savedContent.isEmpty) return [];

    final base64Json = base64.decode(savedContent);
    final gzipJson = GZipDecoder().decodeBytes(base64Json);
    final rawJson = utf8.decode(gzipJson);

    final savedJson = jsonDecode(rawJson) as List<dynamic>;
    return savedJson.cast<Map<String, dynamic>>().map(Strain.fromJson).toList();
  }
}

/// Save a strain to the save file.
Future<void> addSavedStrain(Strain strain) async {
  final savedStrains = await getSavedStrains();
  savedStrains.add(strain);
  await setSavedStrains(savedStrains);
}

/// Fetch saved strains given the strain names.
Future<List<Strain>> getSavedStrainsByName(List<String> strainNames) async {
  final savedStrains = await getSavedStrains();
  final strains = savedStrains
      .where((strain) => strainNames.contains(strain.name ?? 'N/A'))
      .toList();

  return strains;
}

/// Fetch saved strains that are bookmarked.
Future<List<Strain>> getSavedBookmarkedStrains() async {
  final prefs = await SharedPreferences.getInstance();
  final bookmarkedStrainNames = prefs.getStringList('bookmarks') ?? [];

  return getSavedStrainsByName(bookmarkedStrainNames);
}
