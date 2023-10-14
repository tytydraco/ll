import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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
