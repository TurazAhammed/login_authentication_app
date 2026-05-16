import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../models/user_model.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiService apiService;

  AuthRepository({required this.apiService});

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      print('Register request -> email: $email');
      final response = await apiService.post(
        endpoint: ApiConfig.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      print('Register response -> $response');
      return response;
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        endpoint: ApiConfig.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response['success']) {
        // Store tokens and user info
        final data = response['data'];
        await SecureStorageService.save(
          StorageKeys.accessToken,
          data['accessToken'],
        );
        await SecureStorageService.save(
          StorageKeys.refreshToken,
          data['refreshToken'],
        );
        await SecureStorageService.save(
          StorageKeys.userId,
          data['userId'].toString(),
        );
        await SecureStorageService.save(StorageKeys.userName, data['name']);
        await SecureStorageService.save(StorageKeys.userEmail, data['email']);
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await apiService.get(
        endpoint: ApiConfig.profileEndpoint,
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch profile: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final refreshToken = await SecureStorageService.read(
        StorageKeys.refreshToken,
      );

      final response = await apiService.post(
        endpoint: ApiConfig.logoutEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response['success']) {
        // Clear all stored data
        await SecureStorageService.clear();
      }

      return response;
    } catch (e) {
      // Clear data even if API call fails
      await SecureStorageService.clear();
      return {'success': true, 'message': 'Logged out', 'data': null};
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await SecureStorageService.read(StorageKeys.accessToken);
    return token != null;
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await SecureStorageService.read(StorageKeys.accessToken);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await SecureStorageService.read(StorageKeys.refreshToken);
  }
}
