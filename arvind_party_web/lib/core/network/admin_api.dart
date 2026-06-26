// ═══════════════════════════════════════════════════════════════════════════
// WEB ADMIN API SERVICE (REFACTORED FOR SECURITY)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/auth_controller.dart';

// Securely define the API base URL using a compile-time variable.
const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:5000/api');

class AdminApi extends GetxService {
  late final Dio _dio;
  final GetStorage _storage = GetStorage();

  AdminApi() {
    _dio = Dio(BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _setupInterceptors();
  }

  /// Sets up Dio interceptors for automatic token injection and error handling.
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Automatically inject the auth token into the request header.
        final token = _storage.read('admin_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Automatically handle session expiry (401 errors).
        if (error.response?.statusCode == 401) {
          try {
            // Use AuthController to log out and redirect to login screen.
            Get.find<AuthController>().logout();
          } catch (_) {
            // Fallback if controller not found
            _storage.remove('admin_token');
            Get.offAllNamed('/login');
          }
        }
        return handler.next(error);
      },
    ));
  }

  /// Generic error handler to parse Dio errors into readable messages.
  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your internet connection.';
    }
    if (e.response?.data is Map) {
      return e.response!.data['message']?.toString() ?? 'An unknown server error occurred.';
    }
    return e.message ?? 'An unknown error occurred.';
  }

  // ===== HTTP METHODS (Now with secure interceptors and error handling) =====

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }
}