// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/blind_date/presentation/repositories/blind_date_repository.dart
// ARVIND PARTY - BLIND DATE REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class BlindDateRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  String? _getToken() {
    try {
      return Get.find<AuthSessionManager>().token.value;
    } catch (_) {
      return null;
    }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  /// Start searching for a blind date match
  /// POST /api/matchmaking/search
  Future<Map<String, dynamic>> searchMatch() async {
    try {
      final response = await _dio.post(
        ApiConstants.blindMatch,
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Stop searching for a match
  /// POST /api/matchmaking/stop
  Future<void> stopSearch() async {
    try {
      await _dio.post(
        ApiConstants.blindMatchStop,
        options: _authOptions(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}