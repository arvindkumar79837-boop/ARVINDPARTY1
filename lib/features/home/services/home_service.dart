// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/services/home_service.dart
// ARVIND PARTY - HOME SERVICE (Feed, Refresh, Notifications)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';

class HomeService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  final isRefreshing = false.obs;
  final lastRefreshTime = Rxn<DateTime>();

  Future<Map<String, dynamic>> fetchHomeFeed({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get('/home/feed', query: {
        'page': page,
        'limit': limit,
      });
      if (response is Map && response['success'] == true) {
        return Map<String, dynamic>.from(response['data'] ?? {});
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> refreshFeed() async {
    isRefreshing.value = true;
    try {
      await _apiService.post('/home/refresh');
      lastRefreshTime.value = DateTime.now();
    } catch (_) {
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(ApiConstants.notifications, query: {
        'page': page,
        'limit': limit,
      });
      if (response is Map && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<int> fetchUnreadNotificationCount() async {
    try {
      final response = await _apiService.get('${ApiConstants.notifications}/unread-count');
      if (response is Map && response['success'] == true) {
        return response['data']['count'] ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markNotificationsRead() async {
    try {
      await _apiService.post('${ApiConstants.notifications}/read-all');
    } catch (_) {
    }
  }

  Future<Map<String, dynamic>> fetchAnnouncements() async {
    try {
      final response = await _apiService.get('/home/announcements');
      if (response is Map && response['success'] == true) {
        return Map<String, dynamic>.from(response['data'] ?? {});
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchUserDashboard() async {
    try {
      final response = await _apiService.get('/home/dashboard');
      if (response is Map && response['success'] == true) {
        return Map<String, dynamic>.from(response['data'] ?? {});
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrendingRooms() async {
    try {
      final response = await _apiService.get('/rooms/trending');
      if (response is Map && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchOnlineFriends() async {
    try {
      final response = await _apiService.get('/social/friends/online');
      if (response is Map && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> reportContent(String contentType, String contentId, String reason) async {
    try {
      await _apiService.post('/moderation/report', body: {
        'contentType': contentType,
        'contentId': contentId,
        'reason': reason,
      });
    } catch (_) {
      rethrow;
    }
  }
}
