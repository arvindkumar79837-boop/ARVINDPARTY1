import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class LuckyDrawRepository {
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

  /// Fetch all active lucky wheel rewards
  /// GET /api/games/lucky-wheel/rewards
  Future<List<Map<String, dynamic>>> fetchRewards() async {
    try {
      final response = await _dio.get(
        ApiConstants.luckyWheelRewards,
        options: _authOptions(),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final rewards = data['data'] as List<dynamic>? ?? [];
        return rewards.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch rewards');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Execute a lucky wheel spin
  /// POST /api/games/lucky-wheel/spin
  Future<Map<String, dynamic>> spin() async {
    try {
      final response = await _dio.post(
        ApiConstants.luckyWheelSpin,
        options: _authOptions(),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>? ?? data;
      }
      throw ApiException(message: data['message'] ?? 'Spin failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}
