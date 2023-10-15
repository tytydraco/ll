import 'package:flutter/material.dart';

/// Get the color for the strain.
Color getStrainColor(String? category) {
  switch (category?.toLowerCase()) {
    case 'indica':
      return Colors.blue;
    case 'hybrid':
      return Colors.green;
    case 'sativa':
      return Colors.red;
    default:
      return Colors.transparent;
  }
}

/// Returns two colors for a gradient given a category.
List<Color> getStrainGradientColors(String? category) {
  switch (category?.toLowerCase()) {
    case 'indica':
      return [Colors.deepPurple, Colors.blue];
    case 'hybrid':
      return [Colors.green, Colors.lightGreen];
    case 'sativa':
      return [Colors.red, Colors.pink];
    default:
      return [Colors.white70, Colors.black54];
  }
}

/// Returns the color corresponding to the cannabinoid.
Color getCannabinoidColor(String? cannabinoid) {
  switch (cannabinoid?.toLowerCase()) {
    case 'thcv':
      return Colors.red;
    case 'cbg':
      return Colors.orange;
    case 'cbc':
      return Colors.yellow;
    case 'thc':
      return Colors.green;
    case 'cbd':
      return Colors.blue;
    default:
      return Colors.black54;
  }
}
