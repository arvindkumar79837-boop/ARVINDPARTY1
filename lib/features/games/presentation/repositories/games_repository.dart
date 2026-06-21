// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/games/presentation/repositories/games_repository.dart
// ARVIND PARTY - GAMES REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:arvind_party/core/constants/env_config.dart';
import 'package:arvind_party/core/services/auth_session_manager.dart';
import 'package:arvind_party/core/utils/api_exception.dart';
import 'package:arvind_party/core/constants/api_constants.dart';

class GamesRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  String? _getToken() {
    try {
      final token = Get.find<AuthSessionManager>().token;
      return token.value;
    } catch (_) {
      return null;
    }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  /// Play Lucky Wheel
  /// POST /api/games/lucky-wheel/spin
  Future<Map<String, dynamic>> playLuckyWheel() async {
    try {
      final response = await _dio.post(
        ApiConstants.luckyWheelSpin,
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Play Scratch Card
  /// POST /api/games/scratch-card/play
  Future<Map<String, dynamic>> playScratchCard() async {
    try {
      final response = await _dio.post(
        ApiConstants.scratchCardPlay,
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Get game leaderboard
  /// GET /api/games/leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final response = await _dio.get(
        ApiConstants.gameLeaderboard,
        options: _authOptions(),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = data['leaderboard'] as List<dynamic>? ?? [];
        return list.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to load leaderboard');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}
