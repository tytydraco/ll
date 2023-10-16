import 'package:flutter/material.dart';

/// Dropdown menu for selecting a terpene.
class TerpeneDropdown extends StatefulWidget {
  /// Creates a new [TerpeneDropdown].
  const TerpeneDropdown({
    required this.onSelect,
    super.key,
  });

  /// When the user selects a terpene.
  final void Function(String? terpene) onSelect;

  @override
  State<TerpeneDropdown> createState() => _TerpeneDropdownState();
}

class _TerpeneDropdownState extends State<TerpeneDropdown> {
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
        _buildMenuItem('Caryophyllene', 'caryophyllene'),
        _buildMenuItem('Humulene', 'humulene'),
        _buildMenuItem('Limonene', 'limonene'),
        _buildMenuItem('Linalool', 'linalool'),
        _buildMenuItem('Myrcene', 'myrcene'),
        _buildMenuItem('Ocimene', 'ocimene'),
        _buildMenuItem('Pinene', 'pinene'),
        _buildMenuItem('Terpinolene', 'terpinolene'),
      ],
      onSelected: (value) {
        widget.onSelect(value);
      },
    );
  }
}
