import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ll/src/data/strain.dart';
import 'package:ll/src/util/colors.dart';

/// A single strain list item.
class StrainListTile extends StatelessWidget {
  /// Creates a new [StrainListTile].
  const StrainListTile({
    required this.strain,
    this.onSelect,
    this.onDelete,
    this.leading,
    super.key,
  });

  /// The strain.
  final Strain strain;

  /// The leading widget.
  final Widget? leading;

  /// Triggered when user selects the strain.
  final void Function(Strain)? onSelect;

  /// Triggered when user deletes the strain.
  final void Function(Strain)? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(strain.name ?? 'N/A'),
      leading: leading,
      trailing: FaIcon(
        FontAwesomeIcons.canadianMapleLeaf,
        color: getStrainColor(strain.category),
      ),
      onTap: () => onSelect?.call(strain),
      onLongPress: () => onDelete?.call(strain),
    );
  }
}
