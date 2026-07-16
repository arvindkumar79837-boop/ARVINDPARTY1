import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';

class NotificationsRepository {
  final _api = Get.find<ApiService>();

  String? _getToken() {
    try {
      final session = Get.find<AuthSessionManager>();
      return session.token.value;
    } catch (_) { return null; }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final response = await _api.get(
        ApiConstants.notifications,
        options: _authOptions(),
      );
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        final notifications = data['data'] as List<dynamic>? ?? [];
        return notifications.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch notifications');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.put(
        '${ApiConstants.notifications}/$notificationId/read',
        options: _authOptions(),
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
