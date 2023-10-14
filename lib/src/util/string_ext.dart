/// String extensions.
extension StringExtension on String {
  /// Capitalize the first letter of the word.
  String capitalize() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
