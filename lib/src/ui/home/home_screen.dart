import 'package:flutter/material.dart';
import 'package:ll/src/ui/details/details_screen.dart';
import 'package:ll/src/ui/strains/strains_screen.dart';

/// The home screen.
class HomeScreen extends StatelessWidget {
  /// Creates a new [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StrainsScreen(
      onSelect: (strain) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => DetailsScreen(strain: strain),
          ),
        );
      },
    );
  }
}
