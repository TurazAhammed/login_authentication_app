import 'dart:html' as html;

/// Web implementation using window.localStorage
class SecureStorageService {
  /// Save a value
  static Future<void> save(String key, String value) async {
    try {
      html.window.localStorage[key] = value;
    } catch (e) {
      print('Error saving to localStorage: $e');
      rethrow;
    }
  }

  /// Retrieve a value
  static Future<String?> read(String key) async {
    try {
      return html.window.localStorage[key];
    } catch (e) {
      print('Error reading from localStorage: $e');
      return null;
    }
  }

  /// Delete a value
  static Future<void> delete(String key) async {
    try {
      html.window.localStorage.remove(key);
    } catch (e) {
      print('Error deleting from localStorage: $e');
      rethrow;
    }
  }

  /// Clear all values
  static Future<void> clear() async {
    try {
      html.window.localStorage.clear();
    } catch (e) {
      print('Error clearing localStorage: $e');
      rethrow;
    }
  }

  /// Check if a key exists
  static Future<bool> contains(String key) async {
    try {
      return html.window.localStorage.containsKey(key);
    } catch (e) {
      print('Error checking if key exists: $e');
      return false;
    }
  }
}
