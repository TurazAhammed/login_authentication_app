import 'dart:io';

import 'package:dio/dio.dart';
import '../constants.dart';
import 'secure_storage_service.dart';

/// Service for making API calls using Dio
class ApiService {
  late Dio _dio;

  ApiService() {
    print('API baseUrl: ${ApiConfig.baseUrl}');
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiTimeouts.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiTimeouts.receiveTimeout),
        sendTimeout: Duration(milliseconds: ApiTimeouts.sendTimeout),
        contentType: Headers.jsonContentType,
      ),
    );

    // Add interceptors
    _addInterceptors();
  }

  /// Add interceptors for request/response handling
  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              // Add access token to headers if it exists
              final accessToken = await SecureStorageService.read(
                StorageKeys.accessToken,
              );
              // Debug: log outgoing request and auth header in development
              try {
                print('API Request -> ${options.method} ${options.path}');
                print(
                  'Authorization header before request: ${accessToken != null ? 'Bearer ****' : 'none'}',
                );
              } catch (e) {
                // ignore logging errors
              }
              if (accessToken != null) {
                options.headers['Authorization'] = 'Bearer $accessToken';
              }
              return handler.next(options);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          // Handle 401 errors by attempting to refresh the access token and
          // retrying the original request once.
          final statusCode = error.response?.statusCode;
          final options = error.requestOptions;

          if (statusCode == 401) {
            // Prevent retry loops
            if (options.extra['retried'] == true) {
              print('Unauthorized: Token may be expired');
              return handler.next(error);
            }

            final refreshed = await refreshAccessToken();
            if (refreshed) {
              final newAccessToken = await SecureStorageService.read(
                StorageKeys.accessToken,
              );
              if (newAccessToken != null) {
                options.headers['Authorization'] = 'Bearer $newAccessToken';
              }
              options.extra['retried'] = true;

              try {
                final Response retryResponse = await _dio.fetch(options);
                return handler.resolve(retryResponse);
              } catch (e) {
                return handler.next(error);
              }
            }

            print('Unauthorized: Token may be expired');
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await SecureStorageService.read(
        StorageKeys.refreshToken,
      );
      print(
        'Attempting refreshAccessToken; refreshToken present: ${refreshToken != null}',
      );
      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      print('refreshAccessToken response status: ${response.statusCode}');
      try {
        print('refreshAccessToken response body: ${response.data}');
      } catch (e) {}

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['accessToken'];
        await SecureStorageService.save(
          StorageKeys.accessToken,
          newAccessToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      print('API Response -> POST $endpoint status: ${response.statusCode}');
      try {
        print('API Response body: ${response.data}');
      } catch (e) {}
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Generic GET request
  Future<Map<String, dynamic>> get({required String endpoint}) async {
    try {
      final response = await _dio.get(endpoint);
      print('API Response -> GET $endpoint status: ${response.statusCode}');
      try {
        print('API Response body: ${response.data}');
      } catch (e) {}
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Handle successful responses
  Map<String, dynamic> _handleResponse(Response response) {
    return {
      'success': response.data['success'] ?? false,
      'message': response.data['message'] ?? '',
      'data': response.data['data'],
      'statusCode': response.statusCode,
    };
  }

  /// Handle errors
  Map<String, dynamic> _handleError(DioException error) {
    String message = ErrorMessages.unknownError;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = ErrorMessages.networkError;
    } else if (error.response != null) {
      message = error.response?.data['message'] ?? ErrorMessages.serverError;
    } else if (error.error is SocketException) {
      message = ErrorMessages.networkError;
    }

    return {
      'success': false,
      'message': message,
      'data': null,
      'statusCode': error.response?.statusCode ?? 0,
    };
  }
}
