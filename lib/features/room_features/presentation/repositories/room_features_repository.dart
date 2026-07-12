import 'package:arvind_party/core/services/api_service.dart';
import 'package:get/get.dart';

class RoomFeaturesRepository {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> data) async {
    final response = await _api.post('/rooms/features/create', body: data);
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> followRoom(String roomId) async {
    final response = await _api.post('/rooms/features/$roomId/follow', body: {});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> unfollowRoom(String roomId) async {
    final response = await _api.delete('/rooms/features/$roomId/unfollow');
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getRoomFollowers(String roomId, {int page = 1, int limit = 50}) async {
    final response = await _api.get('/rooms/features/$roomId/followers', query: {'page': page, 'limit': limit});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getMyFollowedRooms({int page = 1, int limit = 20}) async {
    final response = await _api.get('/rooms/features/my/followed', query: {'page': page, 'limit': limit});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> promoteToAdmin(String roomId, String userId) async {
    final response = await _api.post('/rooms/features/promote-admin', body: {'roomId': roomId, 'userId': userId});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> demoteAdmin(String roomId, String userId) async {
    final response = await _api.post('/rooms/features/demote-admin', body: {'roomId': roomId, 'userId': userId});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getRoomAdminList(String roomId) async {
    final response = await _api.get('/rooms/features/$roomId/admins');
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getRoomLevel(String roomId) async {
    final response = await _api.get('/rooms/features/$roomId/level');
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> awardXp(String roomId, String action, {int multiplier = 1}) async {
    final response = await _api.post('/rooms/features/award-xp', body: {'roomId': roomId, 'action': action, 'multiplier': multiplier});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> updatePrivacy(String roomId, String roomType, {String password = ''}) async {
    final body = {'roomType': roomType};
    if (password.isNotEmpty) body['roomPassword'] = password;
    final response = await _api.put('/rooms/features/$roomId/privacy', body: body);
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> verifyRoomPassword(String roomId, String password) async {
    final response = await _api.post('/rooms/features/verify-password', body: {'roomId': roomId, 'password': password});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> setNotice(String roomId, Map<String, dynamic> noticeData) async {
    final response = await _api.put('/rooms/features/$roomId/notices', body: noticeData);
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getNotices(String roomId) async {
    final response = await _api.get('/rooms/features/$roomId/notices');
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getOnlineCount(String roomId) async {
    final response = await _api.get('/rooms/features/$roomId/online-count');
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getRoomLeaderboard(String period) async {
    final response = await _api.get('/rooms/features/leaderboard/$period');
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getRoomLeaderboardByLevel({int page = 1}) async {
    final response = await _api.get('/rooms/features/leaderboard/levels/all', query: {'page': page});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> trackTime(String roomId, String userId, int minutes) async {
    final response = await _api.post('/rooms/features/track-time', body: {'roomId': roomId, 'userId': userId, 'minutes': minutes});
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> getRoomDashboardInfo(String roomId) async {
    final response = await _api.get('/rooms/features/$roomId/dashboard');
    return response is Map ? Map<String, dynamic>.from(response) : {'success': false, 'message': 'Invalid response'};
  }
}