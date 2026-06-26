import 'package:get/get.dart';
import 'package:arvind_party/core/services/socket_service.dart';
import 'package:arvind_party/features/room_features/presentation/repositories/room_features_repository.dart';

class RoomFeaturesController extends GetxController {
  final RoomFeaturesRepository _repository = RoomFeaturesRepository();
  final SocketService _socketService = SocketService();

  final RxInt onlineCount = 0.obs;
  final RxInt roomLevel = 1.obs;
  final RxInt currentXp = 0.obs;
  final RxInt totalXp = 0.obs;
  final RxDouble xpProgress = 0.0.obs;
  final RxInt maxAdmins = 8.obs;
  final RxInt maxSeats = 12.obs;
  final RxInt adminSlotLimit = 8.obs;
  final RxInt seatCapacity = 12.obs;
  final RxString announcement = ''.obs;
  final RxString welcomeMessage = ''.obs;
  final RxString pinnedMessage = ''.obs;
  final RxString topic = ''.obs;
  final RxBool isFollowing = false.obs;
  final RxInt followerCount = 0.obs;
  final RxInt adminCount = 0.obs;
  final RxList followers = [].obs;
  final RxList admins = [].obs;
  final RxList chatMessages = [].obs;
  final RxList privateMessages = [].obs;
  final RxString roomType = 'PUBLIC'.obs;
  final RxString roomPassword = ''.obs;
  final RxList levelRewards = [].obs;
  final RxList unlockedBadges = [].obs;
  final RxList unlockedThemes = [].obs;
  final RxList unlockedEntryEffects = [].obs;
  final RxMap roomDashboardData = RxMap({});
  final RxBool isLoading = false.obs;
  final RxBool isLevelingUp = false.obs;

  String? currentRoomId;
  String? currentUserId;
  String? currentUserName;
  String? currentUserAvatar;

  @override
  void onClose() {
    leaveRoom();
    super.onClose();
  }

  void initSocketListeners() {
    _socketService.on('room-sync', (data) {
      roomLevel.value = data['level'] ?? 1;
      totalXp.value = data['totalXp'] ?? 0;
      maxAdmins.value = data['maxAdmins'] ?? 8;
      maxSeats.value = data['maxSeats'] ?? 12;
      announcement.value = data['announcement'] ?? '';
      welcomeMessage.value = data['welcomeMessage'] ?? '';
      pinnedMessage.value = data['pinnedMessage'] ?? '';
      topic.value = data['topic'] ?? '';
    });

    _socketService.on('online-count-update', (data) {
      onlineCount.value = data['onlineCount'] ?? 0;
    });

    _socketService.on('new-chat-message', (data) {
      chatMessages.insert(0, data);
    });

    _socketService.on('private-message', (data) {
      privateMessages.add(data);
    });

    _socketService.on('gift-received', (data) {
      chatMessages.insert(0, {
        'type': 'gift',
        'senderName': data['senderName'],
        'giftName': data['giftName'],
        'giftValue': data['giftValue'],
        'giftAnimationUrl': data['giftAnimationUrl'],
        'timestamp': data['timestamp']
      });
    });

    _socketService.on('notice-changed', (data) {
      final type = data['type'];
      if (type == 'announcement') announcement.value = data['content'] ?? '';
      if (type == 'marquee') welcomeMessage.value = data['content'] ?? '';
      if (type == 'pinned') pinnedMessage.value = data['content'] ?? '';
      if (type == 'topic') topic.value = data['content'] ?? '';
    });

    _socketService.on('room-leveled-up', (data) {
      roomLevel.value = data['newLevel'] ?? roomLevel.value;
      maxAdmins.value = data['maxAdmins'] ?? maxAdmins.value;
      maxSeats.value = data['maxSeats'] ?? maxSeats.value;
      isLevelingUp.value = true;
      if (data['badgeUrl'] != null && data['badgeUrl'].isNotEmpty) {
        unlockedBadges.add({
          'badgeId': 'level_${data['newLevel']}',
          'badgeName': 'Level ${data['newLevel']} Badge',
          'badgeUrl': data['badgeUrl']
        });
      }
      if (data['themeUnlocked'] != null && data['themeUnlocked'].isNotEmpty) {
        unlockedThemes.add({
          'themeId': data['themeUnlocked'],
          'themeName': data['themeUnlocked'].toString().replaceAll('_', ' ').capitalizeFirst!
        });
      }
      Future.delayed(const Duration(seconds: 3), () {
        isLevelingUp.value = false;
      });
    });

    _socketService.on('room-privacy-updated', (data) {
      roomType.value = data['roomType'] ?? 'PUBLIC';
    });

    _socketService.on('user-joined', (data) {
      onlineCount.value = data['onlineCount'] ?? onlineCount.value;
    });

    _socketService.on('user-left', (data) {
      if (data['onlineCount'] != null) {
        onlineCount.value = data['onlineCount'] ?? onlineCount.value;
      }
    });
  }

  Future<void> joinRoom(String roomId, String userId, {String userName = '', String userAvatar = ''}) async {
    currentRoomId = roomId;
    currentUserId = userId;
    currentUserName = userName;
    currentUserAvatar = userAvatar;
    _socketService.emit('join-room', {'roomId': roomId, 'userId': userId});
    initSocketListeners();
    await loadRoomDashboard(roomId);
    await loadRoomLevel(roomId);
  }

  void leaveRoom() {
    if (currentRoomId != null) {
      _socketService.emit('leave-room', {
        'roomId': currentRoomId,
        'userId': currentUserId
      });
    }
    currentRoomId = null;
    currentUserId = null;
  }

  Future<void> loadRoomLevel(String roomId) async {
    try {
      final response = await _repository.getRoomLevel(roomId);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        roomLevel.value = data['currentLevel'] ?? 1;
        currentXp.value = data['currentXp'] ?? 0;
        totalXp.value = data['totalXpEarned'] ?? 0;
        xpProgress.value = (data['xpProgress'] as num?)?.toDouble() ?? 0.0;
        adminSlotLimit.value = data['levelConfig']?['adminSlots'] ?? 8;
        seatCapacity.value = data['levelConfig']?['seatCapacity'] ?? 12;
        if (data['unlockedBadges'] != null) unlockedBadges.value = List.from(data['unlockedBadges']);
        if (data['unlockedThemes'] != null) unlockedThemes.value = List.from(data['unlockedThemes']);
        if (data['unlockedEntryEffects'] != null) unlockedEntryEffects.value = List.from(data['unlockedEntryEffects']);
      }
    } catch (e) {
      print('loadRoomLevel error: $e');
    }
  }

  Future<void> loadRoomDashboard(String roomId) async {
    try {
      isLoading.value = true;
      final response = await _repository.getRoomDashboardInfo(roomId);
      if (response['success'] == true && response['data'] != null) {
        roomDashboardData.value = response['data'];
        final data = response['data'];
        followerCount.value = data['followerCount'] ?? 0;
        adminCount.value = data['adminCount'] ?? 0;
        onlineCount.value = data['onlineCount'] ?? 0;
        maxAdmins.value = data['maxAdmins'] ?? 8;
        maxSeats.value = data['maxSeats'] ?? 12;
        if (data['room'] != null) {
          announcement.value = data['room']['announcement'] ?? '';
          welcomeMessage.value = data['room']['welcomeMessage'] ?? '';
          pinnedMessage.value = data['room']['pinnedMessage'] ?? '';
          topic.value = data['room']['topic'] ?? '';
          roomType.value = data['room']['roomType'] ?? 'PUBLIC';
        }
        if (data['roomLevel'] != null) {
          roomLevel.value = data['roomLevel']['currentLevel'] ?? 1;
          totalXp.value = data['roomLevel']['totalXpEarned'] ?? 0;
          if (data['roomLevel']['unlockedBadges'] != null) {
            unlockedBadges.value = List.from(data['roomLevel']['unlockedBadges']);
          }
          if (data['roomLevel']['unlockedThemes'] != null) {
            unlockedThemes.value = List.from(data['roomLevel']['unlockedThemes']);
          }
        }
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('loadRoomDashboard error: $e');
    }
  }

  Future<void> followRoom(String roomId) async {
    try {
      final response = await _repository.followRoom(roomId);
      if (response['success'] == true) {
        isFollowing.value = true;
        followerCount.value = response['data']?['followerCount'] ?? followerCount.value + 1;
      }
    } catch (e) {
      print('followRoom error: $e');
    }
  }

  Future<void> unfollowRoom(String roomId) async {
    try {
      final response = await _repository.unfollowRoom(roomId);
      if (response['success'] == true) {
        isFollowing.value = false;
        followerCount.value = response['data']?['followerCount'] ?? followerCount.value - 1;
      }
    } catch (e) {
      print('unfollowRoom error: $e');
    }
  }

  Future<void> loadFollowers(String roomId, {int page = 1}) async {
    try {
      final response = await _repository.getRoomFollowers(roomId, page: page);
      if (response['success'] == true && response['data'] != null) {
        followers.value = List.from(response['data']['followers'] ?? []);
      }
    } catch (e) {
      print('loadFollowers error: $e');
    }
  }

  Future<void> loadAdmins(String roomId) async {
    try {
      final response = await _repository.getRoomAdminList(roomId);
      if (response['success'] == true && response['data'] != null) {
        admins.value = List.from(response['data']);
        adminCount.value = admins.length;
      }
    } catch (e) {
      print('loadAdmins error: $e');
    }
  }

  Future<bool> promoteToAdmin(String roomId, String userId) async {
    try {
      final response = await _repository.promoteToAdmin(roomId, userId);
      if (response['success'] == true) {
        adminCount.value++;
        await loadAdmins(roomId);
        return true;
      }
      return false;
    } catch (e) {
      print('promoteToAdmin error: $e');
      return false;
    }
  }

  Future<bool> demoteAdmin(String roomId, String userId) async {
    try {
      final response = await _repository.demoteAdmin(roomId, userId);
      if (response['success'] == true) {
        adminCount.value--;
        await loadAdmins(roomId);
        return true;
      }
      return false;
    } catch (e) {
      print('demoteAdmin error: $e');
      return false;
    }
  }

  Future<void> updatePrivacy(String roomId, String newRoomType, {String password = ''}) async {
    try {
      final response = await _repository.updatePrivacy(roomId, newRoomType, password: password);
      if (response['success'] == true) {
        roomType.value = newRoomType;
        if (password.isNotEmpty) roomPassword.value = password;
      }
    } catch (e) {
      print('updatePrivacy error: $e');
    }
  }

  Future<bool> verifyPassword(String roomId, String password) async {
    try {
      final response = await _repository.verifyRoomPassword(roomId, password);
      return response['data']?['access'] == true;
    } catch (e) {
      print('verifyPassword error: $e');
      return false;
    }
  }

  void updateNotice(String roomId, String type, String content) {
    _socketService.emit('notice-update', {
      'roomId': roomId,
      'type': type,
      'content': content,
      'userId': currentUserId
    });
  }

  void sendChatMessage(String roomId, String message, {bool isPrivate = false, String? targetUserId}) {
    _socketService.emit('send-chat-message', {
      'roomId': roomId,
      'message': message,
      'userId': currentUserId,
      'userName': currentUserName,
      'userAvatar': currentUserAvatar,
      'isPrivate': isPrivate,
      'targetUserId': targetUserId
    });
  }

  void sendGift(String roomId, int giftValue, {String giftName = 'Gift', String giftAnimationUrl = ''}) {
    _socketService.emit('send-gift', {
      'roomId': roomId,
      'giftValue': giftValue,
      'senderId': currentUserId,
      'senderName': currentUserName,
      'senderAvatar': currentUserAvatar,
      'giftName': giftName,
      'giftAnimationUrl': giftAnimationUrl
    });
  }

  void trackTime(String roomId, String userId, int minutes) {
    _socketService.emit('track-time', {
      'roomId': roomId,
      'userId': userId,
      'minutes': minutes
    });
  }

  void requestOnlineCount(String roomId) {
    _socketService.emit('request-online-count', {'roomId': roomId});
  }

  void broadcastLevelUp(String roomId, int newLevel, int xpGained) {
    _socketService.emit('level-up-broadcast', {
      'roomId': roomId,
      'newLevel': newLevel,
      'xpGained': xpGained
    });
  }

  Future<void> awardXp(String roomId, String action, {int multiplier = 1}) async {
    try {
      final response = await _repository.awardXp(roomId, action, multiplier: multiplier);
      if (response['success'] == true && response['data'] != null) {
        currentXp.value = response['data']['totalXp'] ?? currentXp.value;
        if (response['data']['leveledUp'] == true) {
          broadcastLevelUp(roomId, response['data']['newLevel'], response['data']['xpGained']);
          await loadRoomLevel(roomId);
        }
      }
    } catch (e) {
      print('awardXp error: $e');
    }
  }

  Future<List> getLeaderboard(String period) async {
    try {
      final response = await _repository.getRoomLeaderboard(period);
      if (response['success'] == true && response['data'] != null) {
        return List.from(response['data']['leaderboard'] ?? []);
      }
      return [];
    } catch (e) {
      print('getLeaderboard error: $e');
      return [];
    }
  }

  Future<List> getLevelLeaderboard({int page = 1}) async {
    try {
      final response = await _repository.getRoomLeaderboardByLevel(page: page);
      if (response['success'] == true && response['data'] != null) {
        return List.from(response['data']['leaderboard'] ?? []);
      }
      return [];
    } catch (e) {
      print('getLevelLeaderboard error: $e');
      return [];
    }
  }

  Future<List> getMyFollowedRooms({int page = 1}) async {
    try {
      final response = await _repository.getMyFollowedRooms(page: page);
      if (response['success'] == true && response['data'] != null) {
        return List.from(response['data']['rooms'] ?? []);
      }
      return [];
    } catch (e) {
      print('getMyFollowedRooms error: $e');
      return [];
    }
  }
}