// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room_features/presentation/controllers/room_features_controller.dart
// ARVIND PARTY - ROOM FEATURES CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:arvind_party/core/socket/socket_service.dart';
import 'package:get/get.dart';

class RoomFeaturesController extends GetxController {
  final SocketService _socketService = Get.find<SocketService>();

  // Level related
  final roomLevel = 1.obs;
  final totalXp = 0.obs;
  final xpProgress = 0.0.obs;
  final adminSlotLimit = 0.obs;

  // Room stats
  final onlineCount = 0.obs;
  final seatCapacity = 0.obs;

  // Rewards
  final unlockedBadges = <Map<String, dynamic>>[].obs;
  final unlockedThemes = <Map<String, dynamic>>[].obs;
  final unlockedEntryEffects = <Map<String, dynamic>>[].obs;

  // Social
  final followerCount = 0.obs;
  final adminCount = 0.obs;
  final followers = <Map<String, dynamic>>[].obs;
  final admins = <Map<String, dynamic>>[].obs;

  // Notices
  final welcomeMessage = ''.obs;
  final announcement = ''.obs;
  final pinnedMessage = ''.obs;
  final topic = ''.obs;

  // Room state
  String _currentRoomId = '';
  String _currentUserId = '';
  String _currentUserName = '';
  String _currentUserAvatar = '';

  @override
  void onInit() {
    super.onInit();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // Listen for room events
    _socketService.on('room:levelUpdate', (data) {
      if (data is Map) {
        roomLevel.value = data['level'] ?? 1;
        totalXp.value = data['totalXp'] ?? 0;
        xpProgress.value = (data['xpProgress'] ?? 0).toDouble();
        adminSlotLimit.value = data['adminSlotLimit'] ?? 0;
      }
    });

    _socketService.on('room:statsUpdate', (data) {
      if (data is Map) {
        onlineCount.value = data['onlineCount'] ?? 0;
        seatCapacity.value = data['seatCapacity'] ?? 0;
      }
    });

    _socketService.on('room:rewardsUpdate', (data) {
      if (data is Map) {
        unlockedBadges.value = List<Map<String, dynamic>>.from(data['badges'] ?? []);
        unlockedThemes.value = List<Map<String, dynamic>>.from(data['themes'] ?? []);
        unlockedEntryEffects.value = List<Map<String, dynamic>>.from(data['entryEffects'] ?? []);
      }
    });

    _socketService.on('room:socialUpdate', (data) {
      if (data is Map) {
        followerCount.value = data['followerCount'] ?? 0;
        adminCount.value = data['adminCount'] ?? 0;
        followers.value = List<Map<String, dynamic>>.from(data['followers'] ?? []);
        admins.value = List<Map<String, dynamic>>.from(data['admins'] ?? []);
      }
    });

    _socketService.on('room:noticesUpdate', (data) {
      if (data is Map) {
        welcomeMessage.value = data['welcomeMessage'] ?? '';
        announcement.value = data['announcement'] ?? '';
        pinnedMessage.value = data['pinnedMessage'] ?? '';
        topic.value = data['topic'] ?? '';
      }
    });
  }

  Future<void> joinRoom(
    String roomId,
    String userId, {
    required String userName,
    required String userAvatar,
  }) async {
    _currentRoomId = roomId;
    _currentUserId = userId;
    _currentUserName = userName;
    _currentUserAvatar = userAvatar;

    // Emit join room event
    _socketService.emit('room:join', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
    });

    // Request initial data
    _socketService.emit('room:getLevel', {'roomId': roomId});
    _socketService.emit('room:getStats', {'roomId': roomId});
    _socketService.emit('room:getRewards', {'roomId': roomId});
    _socketService.emit('room:getSocial', {'roomId': roomId});
    _socketService.emit('room:getNotices', {'roomId': roomId});
  }

  void leaveRoom() {
    if (_currentRoomId.isNotEmpty) {
      _socketService.emit('room:leave', {
        'roomId': _currentRoomId,
        'userId': _currentUserId,
      });
      _currentRoomId = '';
      _currentUserId = '';
    }
  }

  Future<void> promoteToAdmin(String roomId, String targetUserId) async {
    _socketService.emit('room:promoteAdmin', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'promotedBy': _currentUserId,
    });
  }

  Future<void> demoteAdmin(String roomId, String targetUserId) async {
    _socketService.emit('room:demoteAdmin', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'demotedBy': _currentUserId,
    });
  }

  Future<List<Map<String, dynamic>>> getLeaderboard(String period) async {
    // Simulate API call - replace with actual socket call or HTTP request
    try {
      final response = await _socketService.emitWithAck('room:getLeaderboard', {
        'roomId': _currentRoomId,
        'period': period,
      });

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getLevelLeaderboard() async {
    try {
      final response = await _socketService.emitWithAck('room:getLevelLeaderboard', {
        'roomId': _currentRoomId,
      });

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('Error fetching level leaderboard: $e');
    }
    return [];
  }

  void updateWelcomeMessage(String message) {
    _socketService.emit('room:updateWelcomeMessage', {
      'roomId': _currentRoomId,
      'message': message,
      'updatedBy': _currentUserId,
    });
  }

  void updateAnnouncement(String message) {
    _socketService.emit('room:updateAnnouncement', {
      'roomId': _currentRoomId,
      'message': message,
      'updatedBy': _currentUserId,
    });
  }

  void updatePinnedMessage(String message) {
    _socketService.emit('room:updatePinnedMessage', {
      'roomId': _currentRoomId,
      'message': message,
      'updatedBy': _currentUserId,
    });
  }

  void updateTopic(String topic) {
    _socketService.emit('room:updateTopic', {
      'roomId': _currentRoomId,
      'topic': topic,
      'updatedBy': _currentUserId,
    });
  }

  @override
  void onClose() {
    leaveRoom();
    super.onClose();
  }
}