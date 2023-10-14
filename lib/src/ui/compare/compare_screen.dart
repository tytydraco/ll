import 'package:flutter/material.dart';
import 'package:ll/src/ui/details/details_screen.dart';

/// Compare two strains.
class CompareScreen extends StatelessWidget {
  /// Creates a new [CompareScreen].
  const CompareScreen({
    super.key,
    required this.strainA,
    required this.strainB,
  });

  /// The first strain.
  final Map<String, dynamic> strainA;

  /// The second strain.
  final Map<String, dynamic> strainB;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: DetailsScreen(strain: strainA),
        ),
        Flexible(
          child: DetailsScreen(strain: strainB),
        ),
      ],
    );
  }
}
