import 'package:flutter/foundation.dart';

/// API Configuration
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.0.102:5000/api';
    }

    return 'http://localhost:5000/api';
  }

  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String profileEndpoint =
      '/auth/profile'; // Changed from /user/profile
}

/// Timeout durations for API calls
class ApiTimeouts {
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}

/// Error messages
class ErrorMessages {
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String emailAlreadyExists = 'Email already registered.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String invalidEmail = 'Invalid email format.';
  static const String passwordTooShort =
      'Password must be at least 6 characters.';
  static const String tokenExpired = 'Session expired. Please login again.';
}

/// Storage keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
}
