// ═══════════════════════════════════════════════════════════════════════════
// WEB ADMIN API SERVICE
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import '../constants/env_config.dart';

class AdminApi {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}