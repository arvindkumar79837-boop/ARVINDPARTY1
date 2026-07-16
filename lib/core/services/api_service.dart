// lib/core/services/api_service.dart
// Real API service for Arvind Party - connects to Node.js backend
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;

import '../constants/api_constants.dart';
import '../utils/api_exception.dart';
import 'auth_session_manager.dart';

class ApiService extends getx.GetxService {
  late final Dio _dio;

  /// Convenience accessor for session manager
  AuthSessionManager get _authSession => getx.Get.find<AuthSessionManager>();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  @override
  void onInit() {
    super.onInit();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          final token = getx.Get.find<AuthSessionManager>().token.value;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // Auth token not available yet — proceed without Authorization header
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final authSession = getx.Get.find<AuthSessionManager>();
            await authSession.handleUnauthorized();
            final newToken = authSession.token.value;
            if (newToken != null && newToken.isNotEmpty) {
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final dio = Dio();
              try {
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (_) {
                // Retry failed — will return original error
              }
            }
          } catch (_) {
            // Session refresh failed — will return 401 error
          }
        }

        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout) {
          _showNetworkError();
        } else if (error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          _showTimeoutError();
        } else if (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500) {
          _showServerError();
        }

        return handler.next(error);
      },
    ));
  }

  void _showNetworkError() {
    if (getx.Get.isSnackbarOpen) return;
    getx.Get.snackbar(
      'No Internet',
      'Please check your internet connection',
      snackPosition: getx.SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2A2A3E),
      colorText: const Color(0xFFFF8906),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  void _showTimeoutError() {
    if (getx.Get.isSnackbarOpen) return;
    getx.Get.snackbar(
      'Timeout',
      'Request timed out. Please try again.',
      snackPosition: getx.SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2A2A3E),
      colorText: const Color(0xFFFF8906),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  void _showServerError() {
    if (getx.Get.isSnackbarOpen) return;
    getx.Get.snackbar(
      'Server Error',
      'Something went wrong on our end. Please try again later.',
      snackPosition: getx.SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2A2A3E),
      colorText: const Color(0xFFFF8906),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  Dio get dio => _dio;

  // ===== TOKEN MANAGEMENT =====
  void saveToken(String token) {
    _authSession.saveSession(token: token);
  }

  String? getToken() {
    return _authSession.token.value;
  }

  void clearToken() {
    _authSession.clearSession();
  }

  bool isLoggedIn() {
    return _authSession.hasToken();
  }

  // ===== HTTP METHODS =====
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final params = query ?? queryParams ?? queryParameters;
    try {
      final response = await _dio.get(endpoint, queryParameters: params, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data ?? body,
        queryParameters: query ?? queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data ?? body, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(endpoint, data: data ?? body, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(endpoint, data: data ?? body, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Multipart upload
  Future<dynamic> uploadFile(String endpoint, String filePath, String fieldName, {Map<String, dynamic>? extraFields}) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (extraFields != null) ...extraFields,
      });
      final response = await _dio.post(endpoint, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw ApiException.timeoutError();
    }
    if (e.type == DioExceptionType.connectionError) {
      throw ApiException.networkError();
    }
    if (e.response != null) {
      if (e.response?.statusCode == 401) {
        throw ApiException.unauthorized();
      }
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        throw ApiException(
          message: data['message'].toString(),
          statusCode: e.response?.statusCode,
          errors: data['errors'],
        );
      }
      throw ApiException(
        message: 'Server error: ${e.response?.statusCode}',
        statusCode: e.response?.statusCode,
      );
    }
    throw ApiException(message: e.message ?? 'Unknown error');
  }
}
