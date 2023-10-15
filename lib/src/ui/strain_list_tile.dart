import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ll/src/util/colors.dart';
import 'package:ll/src/util/safe_json.dart';

/// A single strain list item.
class StrainListTile extends StatelessWidget {
  /// Creates a new [StrainListTile].
  const StrainListTile({
    required this.strain,
    this.onSelect,
    this.leading,
    super.key,
  });

  /// The strain.
  final Map<String, dynamic> strain;

  /// The leading widget.
  final Widget? leading;

  /// Triggered when user selects the strain.
  final void Function(Map<String, dynamic> strain)? onSelect;

  @override
  Widget build(BuildContext context) {
    final strainSafe = SafeJson(strain);

    return ListTile(
      title: Text(strainSafe.get<String>('name') ?? 'N/A'),
      leading: leading,
      trailing: FaIcon(
        FontAwesomeIcons.canadianMapleLeaf,
        color: getStrainColor(strainSafe.get<String>('category')),
      ),
      onTap: () => onSelect?.call(strain),
    );
  }
}
