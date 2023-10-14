/// Safe JSON data traversal.
class SafeJson {
  /// Creates a new [SafeJson].
  SafeJson(this.json);

  /// The JSON data.
  final Map<String, dynamic>? json;

  /// Get a value.
  T? get<T>(String path) {
    if (json == null) return null;
    if (json![path] == null) return null;
    return json![path] as T?;
  }

  /// Get a deeper tree.
  SafeJson to(String path) {
    if (json == null) return SafeJson(null);
    if (json![path] == null) return SafeJson(null);
    return SafeJson(json![path] as Map<String, dynamic>);
  }
}
