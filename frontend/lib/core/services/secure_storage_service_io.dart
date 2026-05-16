import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// IO/mobile implementation using flutter_secure_storage
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  /// Save a value
  static Future<void> save(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print('Error saving to secure storage: $e');
      rethrow;
    }
  }

  /// Retrieve a value
  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print('Error reading from secure storage: $e');
      return null;
    }
  }

  /// Delete a value
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('Error deleting from secure storage: $e');
      rethrow;
    }
  }

  /// Clear all values
  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
      rethrow;
    }
  }

  /// Check if a key exists
  static Future<bool> contains(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      print('Error checking if key exists: $e');
      return false;
    }
  }
}
