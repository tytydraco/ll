import 'package:flutter/material.dart';

/// Dropdown menu for selecting an effect.
class EffectDropdown extends StatefulWidget {
  /// Creates a new [EffectDropdown].
  const EffectDropdown({
    required this.onSelect,
    super.key,
  });

  /// When the user selects an effect.
  final void Function(String? effect) onSelect;

  @override
  State<EffectDropdown> createState() => _EffectDropdownState();
}

class _EffectDropdownState extends State<EffectDropdown> {
  DropdownMenuEntry<String?> _buildMenuItem(String label, String? value) {
    return DropdownMenuEntry(
      value: value,
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String?>(
      dropdownMenuEntries: [
        _buildMenuItem('', null),
        _buildMenuItem('Aroused', 'aroused'),
        _buildMenuItem('Creative', 'creative'),
        _buildMenuItem('Energetic', 'energetic'),
        _buildMenuItem('Euphoric', 'euphoric'),
        _buildMenuItem('Focused', 'focused'),
        _buildMenuItem('Giggly', 'giggly'),
        _buildMenuItem('Happy', 'happy'),
        _buildMenuItem('Hungry', 'hungry'),
        _buildMenuItem('Relaxed', 'relaxed'),
        _buildMenuItem('Sleepy', 'sleepy'),
        _buildMenuItem('Talkative', 'talkative'),
        _buildMenuItem('Tingly', 'tingly'),
        _buildMenuItem('Uplifted', 'uplifted'),
      ],
      onSelected: (value) {
        widget.onSelect(value);
      },
    );
  }
}
