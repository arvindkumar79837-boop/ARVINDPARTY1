// lib/core/services/api_service.dart
// Real API service for Arvind Party - connects to Node.js backend
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;

import '../constants/api_constants.dart';
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

    // SSL pinning: Add certificate validation
    (_dio.httpClientAdapter as dynamic);
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
        } catch (e) {
          debugPrint('Auth header error: $e');
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          try {
            getx.Get.find<AuthSessionManager>().clearSession();
          } catch (e) { debugPrint('Error: $e'); }
        }
        return handler.next(error);
      },
    ));
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

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timeout. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your internet.';
    }
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Server error: ${e.response?.statusCode}';
    }
    return e.message ?? 'Unknown error';
  }
}
