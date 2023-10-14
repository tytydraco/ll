import 'package:flutter/material.dart';
import 'package:ll/src/screens/home_screen.dart';
import 'package:ll/src/themes.dart';

void main() {
  runApp(const LL());
}

/// Leafly Lookup application.
class LL extends StatelessWidget {
  /// Creates a new [LL].
  const LL({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LL',
      theme: primaryTheme,
      home: const HomeScreen(),
    );
  }
}
