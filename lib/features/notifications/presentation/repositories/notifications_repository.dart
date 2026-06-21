import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class NotificationsRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final response = await _dio.get(
        ApiConstants.notifications,
        options: Options(headers: {'Authorization': 'Bearer ${_getToken()}'}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final notifications = data['data'] as List<dynamic>? ?? [];
        return notifications.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch notifications');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.put(
        '${ApiConstants.notifications}/$notificationId/read',
        options: Options(headers: {'Authorization': 'Bearer ${_getToken()}'}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  String? _getToken() {
    try {
      final session = Get.find<AuthSessionManager>();
      return session.token.value;
    } catch (_) {
      return null;
    }
  }
}
