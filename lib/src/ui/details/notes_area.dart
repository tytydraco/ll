import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A persistent notes area to track experiences.
class NotesArea extends StatefulWidget {
  /// Creates a new [NotesArea].
  const NotesArea({
    required this.strainName,
    super.key,
  });

  /// The strain name to attribute these notes to.
  final String strainName;

  @override
  State<NotesArea> createState() => _NotesAreaState();
}

class _NotesAreaState extends State<NotesArea> {
  final _noteController = TextEditingController();
  late final _key = '${widget.strainName}_note';

  Future<String> _getSavedNote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '';
  }

  Future<void> _setSavedNote(String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, content);
  }

  @override
  void initState() {
    super.initState();
    _getSavedNote().then((value) {
      setState(() {
        _noteController.text = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _noteController,
          onChanged: _setSavedNote,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Notes...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
