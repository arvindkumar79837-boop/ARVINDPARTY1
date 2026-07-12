// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/controllers/room_controller.dart
// ARVIND PARTY - ROOM CONTROLLER (extends LiveRoomController)
// Added: Room Varieties, PK Battles, Daily Tasks, Cosmetics, Room Ranking
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/services/api_service.dart';
import '../../models/room_models.dart';
import 'live_room_controller.dart';

class RoomController extends LiveRoomController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ─── Room Identity (extended) ──────────────────────────────
  final Rx<RoomModel?> currentRoom = Rxn<RoomModel?>();
  final rooms = <RoomModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRoomType = 'PUBLIC'.obs;
  final RxString selectedCategory = 'voice'.obs;

  // ─── Room Background & Cosmetics ───────────────────────────
  final selectedBackgroundName = ''.obs;
  final selectedBackgroundUrl = ''.obs;
  final selectedThemeColor = '#FF6B6B'.obs;
  final availableBackgrounds = <RoomBackground>[].obs;
  final ownedBackgrounds = <RoomBackground>[].obs;

  // ─── Voice Effects & Audio ───────────────────────────────────
  final selectedVoiceEffect = VoiceEffect.none.obs;
  final isNoiseCancellation = false.obs;
  final isSpatialAudio = false.obs;

  // ─── Member Management ──────────────────────────────────────
  @override
  final members = <RoomMemberModel>[].obs;
  final bannedUsers = <Map<String, dynamic>>[].obs;
  final raiseHandRequests = <RaiseHandRequest>[].obs;

  // ─── Room PK Battle ─────────────────────────────────────────
  final Rx<PKChallenge?> currentPKChallenge = Rxn<PKChallenge?>();
  final pkWins = 0.obs;
  final pkLosses = 0.obs;
  final pkPoints = 0.obs;
  final isRoomPKActive = false.obs;

  // ─── Daily Tasks ────────────────────────────────────────────
  final dailyTasks = <RoomTask>[].obs;

  // ─── Room Ranking ───────────────────────────────────────────
  final roomRankings = <RoomRankingEntry>[].obs;
  final RxString rankingType = 'gift'.obs;

  RoomController({
    super.roomId,
    super.roomOwnerId,
    super.initialSeatCount = 12,
  });

  int get currentAdminCount =>
      members.where((m) => m.role == MemberRole.admin || m.role == MemberRole.coHost).length;

  int get maxAdminsAllowed => 5;

  bool get canManageRoom => currentUserId == roomOwnerId;

  bool get canManageMembers {
    final myRaw = members.firstWhereOrNull((m) => m.userId == currentUserId);
    final myRole = myRaw?.role;
    return currentUserId == roomOwnerId || myRole == MemberRole.admin || myRole == MemberRole.coHost;
  }

  bool get isHost => currentUserId == roomOwnerId;

  bool get isUserMuted => mutedRemoteUsers.isNotEmpty || isMuted.value;

  int? get myCurrentSeatIndex {
    for (var i = 0; i < seats.length; i++) {
      if (seats[i].userId == currentUserId) return i;
    }
    return null;
  }

  final chatScrollController = ScrollController();

  @override
  void sendChatMessage(String text) {
    if (text.trim().isEmpty || socket == null || !isConnected.value) return;
    socket!.emit('send_room_message', {
      'roomId': roomId,
      'senderId': currentUserId,
      'senderName': currentUserName,
      'message': text.trim(),
      'isVip': _storage.read('is_vip') ?? false,
    });
  }

  void sendRaiseHand() {
    if (socket == null || !isConnected.value) return;
    socket!.emit('raise_hand', {
      'roomId': roomId,
      'userId': currentUserId,
      'userName': currentUserName,
    });
  }

  Future<void> approveRaiseHand(int index) async {
    if (!canManageMembers) return;
    final request = raiseHandRequests[index];
    socket?.emit('approve_raise_hand', {
      'roomId': roomId,
      'userId': request.userId,
      'seatIndex': index,
    });
    raiseHandRequests.removeAt(index);
  }

  Future<void> rejectRaiseHand(int index) async {
    if (!canManageMembers) return;
    final request = raiseHandRequests[index];
    socket?.emit('reject_raise_hand', {
      'roomId': roomId,
      'userId': request.userId,
    });
    raiseHandRequests.removeAt(index);
  }

  Future<void> leaveRoom() async {
    socket?.emit('leave_room', {'roomId': roomId, 'userId': currentUserId});
    socket?.disconnect();
    Get.back();
  }

  Future<void> kickMember(String userId) async {
    if (!canManageMembers) return;
    socket?.emit('kick_member', {'roomId': roomId, 'userId': userId});
    members.removeWhere((m) => m.userId == userId);
  }

  Future<void> banMember(String userId) async {
    if (!canManageRoom) return;
    socket?.emit('ban_member', {'roomId': roomId, 'userId': userId});
    bannedUsers.add({'id': userId, 'bannedAt': DateTime.now().toIso8601String()});
    members.removeWhere((m) => m.userId == userId);
  }

  Future<void> promoteToAdmin(String userId) async {
    if (!canManageRoom) return;
    socket?.emit('promote_admin', {'roomId': roomId, 'userId': userId});
    final idx = members.indexWhere((m) => m.userId == userId);
    if (idx != -1) members[idx] = members[idx].copyWith(role: MemberRole.admin);
  }

  Future<void> makeCoHost(String userId) async {
    if (!canManageRoom) return;
    socket?.emit('make_co_host', {'roomId': roomId, 'userId': userId});
    final idx = members.indexWhere((m) => m.userId == userId);
    if (idx != -1) members[idx] = members[idx].copyWith(role: MemberRole.coHost);
  }

  Future<void> takeSeat(int seatIndex) async {
    if (canManageRoom || canManageMembers) {
      joinSeat(seatIndex);
    }
  }

  @override
  Future<void> toggleLockSeat(int seatIndex) async {
    if (!canManageRoom) return;
    super.toggleLockSeat(seatIndex);
  }

  Future<void> toggleMuteSeatByAdmin(int seatIndex) async {
    if (!canManageMembers) return;
    if (seats[seatIndex].isMuted) {
      super.unmuteSeat(seatIndex);
    } else {
      super.muteSeat(seatIndex);
    }
  }

  Future<void> kickUserFromSeat(int seatIndex) async {
    if (!canManageMembers) return;
    super.kickFromSeat(seatIndex);
  }

  Future<void> toggleSelfMute() async {
    super.toggleMute();
  }

  void updateAnnouncement(String announcement) {
    socket?.emit('update_announcement', {'roomId': roomId, 'announcement': announcement});
  }

  void updatePinnedMessage(String message) {
    socket?.emit('update_pinned_message', {'roomId': roomId, 'pinnedMessage': message});
  }

  void updateWelcomeMessage(String message) {
    socket?.emit('update_welcome_message', {'roomId': roomId, 'welcomeMessage': message});
  }

  void updateTopic(String topic) {
    socket?.emit('update_topic', {'roomId': roomId, 'topic': topic});
  }

  void loadRooms({String? type}) {
    isLoading.value = true;
    fetchRooms(type: type).then((_) {
      isLoading.value = false;
    });
  }

  Future<void> fetchRooms({String? type, String? category, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _apiService.get('/rooms/live', queryParams: queryParams);
      if (response is Map && response['success'] == true) {
        final List<dynamic> roomList = response['rooms'] ?? response['data'] ?? [];
        rooms.assignAll(
          roomList.map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e))).toList(),
        );
      }
    } catch (e) {
      debugPrint('[RoomController] fetchRooms error: $e');
    }
  }

  Future<void> fetchRoomDetail(String roomId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/rooms/$roomId');
      if (response is Map && response['success'] == true) {
        currentRoom.value = RoomModel.fromJson(Map<String, dynamic>.from(response['room'] ?? response['data']));
      }
    } catch (e) {
      debugPrint('[RoomController] fetchRoomDetail error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRoomBackground(String backgroundUrl, String backgroundName) async {
    try {
      final response = await _apiService.put('/rooms/$roomId/cosmetics', body: {
        'backgroundUrl': backgroundUrl,
        'backgroundName': backgroundName,
      });
      if (response is Map && response['success'] == true) {
        selectedBackgroundUrl.value = backgroundUrl;
        selectedBackgroundName.value = backgroundName;
        socket?.emit('update_room_background', {
          'roomId': roomId,
          'backgroundUrl': backgroundUrl,
          'backgroundName': backgroundName,
        });
        Get.snackbar('Success', 'Room background updated!',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
      }
    } catch (e) {
      debugPrint('[RoomController] updateBackground error: $e');
    }
  }

  Future<void> updateRoomThemeColor(String colorHex) async {
    try {
      await _apiService.put('/rooms/$roomId/cosmetics', body: {'themeColor': colorHex});
      selectedThemeColor.value = colorHex;
    } catch (e) {
      debugPrint('[RoomController] updateThemeColor error: $e');
    }
  }

  Future<void> purchaseBackground(RoomBackground background) async {
    try {
      final response = await _apiService.post('/rooms/$roomId/cosmetics/purchase-background', body: {
        'backgroundId': background.backgroundId,
        'backgroundName': background.backgroundName,
        'backgroundUrl': background.backgroundUrl,
        'costCoins': background.costCoins,
      });
      if (response is Map && response['success'] == true) {
        ownedBackgrounds.add(background);
        Get.snackbar('Purchased', '${background.backgroundName} added to your collection!',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
      }
    } catch (e) {
      debugPrint('[RoomController] purchaseBackground error: $e');
    }
  }

  Future<void> challengeRoomPK(String opponentRoomId) async {
    try {
      final response = await _apiService.post('/rooms/$roomId/pk/challenge', body: {
        'opponentRoomId': opponentRoomId,
      });
      if (response is Map && response['success'] == true) {
        final challenge = PKChallenge.fromJson(Map<String, dynamic>.from(response['challenge']));
        currentPKChallenge.value = challenge;
        isRoomPKActive.value = true;
        Get.snackbar('PK Started!', 'Battle is now active!',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('[RoomController] challengeRoomPK error: $e');
      Get.snackbar('PK Error', 'Failed to start PK challenge.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> fetchPKStatus() async {
    try {
      final response = await _apiService.get('/rooms/$roomId/pk/status');
      if (response is Map && response['success'] == true) {
        if (response['currentPkChallenge'] != null) {
          currentPKChallenge.value = PKChallenge.fromJson(Map<String, dynamic>.from(response['currentPkChallenge']));
          isRoomPKActive.value = currentPKChallenge.value?.isActive ?? false;
        }
        final stats = response['pkStats'] as Map? ?? {};
        pkWins.value = stats['wins'] ?? 0;
        pkLosses.value = stats['losses'] ?? 0;
        pkPoints.value = stats['points'] ?? 0;
      }
    } catch (e) {
      debugPrint('[RoomController] fetchPKStatus error: $e');
    }
  }

  void updatePKScore({int score = 1}) {
    socket?.emit('pk_update_score', {
      'roomId': roomId,
      'score': score,
      'userId': currentUserId,
    });
  }

  Future<void> fetchDailyTasks() async {
    try {
      final response = await _apiService.get('/rooms/$roomId/tasks');
      if (response is Map && response['success'] == true) {
        final List<dynamic> taskList = response['tasks'] ?? [];
        dailyTasks.assignAll(
          taskList.map((t) => RoomTask.fromJson(Map<String, dynamic>.from(t))).toList(),
        );
      }
    } catch (e) {
      debugPrint('[RoomController] fetchDailyTasks error: $e');
    }
  }

  Future<void> updateTaskProgress(String taskId, {int increment = 1}) async {
    try {
      final response = await _apiService.put('/rooms/$roomId/tasks/$taskId/progress', body: {
        'increment': increment,
      });
      if (response is Map && response['success'] == true) {
        final updatedTask = RoomTask.fromJson(Map<String, dynamic>.from(response['task']));
        final idx = dailyTasks.indexWhere((t) => t.taskId == taskId);
        if (idx != -1) {
          dailyTasks[idx] = updatedTask;
        }
        if (updatedTask.isCompleted) {
          Get.snackbar('Task Complete!', 'You earned rewards!',
              backgroundColor: Colors.greenAccent, colorText: Colors.black);
        }
      }
    } catch (e) {
      debugPrint('[RoomController] updateTaskProgress error: $e');
    }
  }

  Future<void> claimTaskReward(String taskId) async {
    try {
      final response = await _apiService.post('/rooms/$roomId/tasks/$taskId/claim');
      if (response is Map && response['success'] == true) {
        Get.snackbar(
          'Reward Claimed!',
          'You got ${response['rewardedCoins']} coins & ${response['rewardedXp']} XP!',
          backgroundColor: Colors.amberAccent,
          colorText: Colors.black,
        );
        await fetchDailyTasks();
      }
    } catch (e) {
      debugPrint('[RoomController] claimTaskReward error: $e');
    }
  }

  Future<void> fetchRoomRanking({String type = 'gift'}) async {
    rankingType.value = type;
    try {
      final response = await _apiService.get('/rooms/ranking', queryParams: {'type': type, 'limit': '50'});
      if (response is Map && response['success'] == true) {
        final List<dynamic> roomList = response['rooms'] ?? [];
        roomRankings.assignAll(
          roomList.map((r) => RoomRankingEntry.fromJson(Map<String, dynamic>.from(r))).toList(),
        );
      }
    } catch (e) {
      debugPrint('[RoomController] fetchRoomRanking error: $e');
    }
  }

  Future<bool> verifyRoomPassword(String password) async {
    try {
      final response = await _apiService.post('/rooms/$roomId/verify-password', body: {
        'password': password,
      });
      return response is Map && response['success'] == true;
    } catch (e) {
      debugPrint('[RoomController] verifyPassword error: $e');
      return false;
    }
  }

  Future<bool> joinRoomWithPassword(String? password) async {
    try {
      final response = await _apiService.post('/rooms/$roomId/join', body: {
        'password': password ?? '',
      });
      return response is Map && response['success'] == true;
    } catch (e) {
      debugPrint('[RoomController] joinRoom error: $e');
      return false;
    }
  }

  void loadAvailableBackgrounds() {
    availableBackgrounds.assignAll([
      const RoomBackground(backgroundId: 'default', backgroundName: 'Default', backgroundUrl: ''),
      const RoomBackground(backgroundId: 'space', backgroundName: 'Space Galaxy', backgroundUrl: 'assets/backgrounds/space.jpg', costCoins: 100, isAnimated: true, themeColor: '#0D0D2B'),
      const RoomBackground(backgroundId: 'casino', backgroundName: 'Casino Royale', backgroundUrl: 'assets/backgrounds/casino.jpg', costCoins: 200, isAnimated: true, themeColor: '#FFD700'),
      const RoomBackground(backgroundId: 'nature', backgroundName: 'Forest Vibes', backgroundUrl: 'assets/backgrounds/nature.jpg', costCoins: 50, themeColor: '#2E7D32'),
      const RoomBackground(backgroundId: 'party', backgroundName: 'Neon Party', backgroundUrl: 'assets/backgrounds/party.gif', costCoins: 150, isAnimated: true, themeColor: '#FF1493'),
      const RoomBackground(backgroundId: 'ocean', backgroundName: 'Deep Ocean', backgroundUrl: 'assets/backgrounds/ocean.jpg', costCoins: 80, themeColor: '#006064'),
      const RoomBackground(backgroundId: 'festival', backgroundName: 'Festival Lights', backgroundUrl: 'assets/backgrounds/festival.gif', costCoins: 120, isAnimated: true, themeColor: '#FF6F00'),
    ]);
  }

  void setVoiceEffect(VoiceEffect effect) {
    selectedVoiceEffect.value = effect;
    socket?.emit('set_voice_effect', {
      'roomId': roomId,
      'userId': currentUserId,
      'effect': effect.name,
    });
  }

  void toggleNoiseCancellation() {
    isNoiseCancellation.value = !isNoiseCancellation.value;
    socket?.emit('toggle_noise_cancellation', {
      'roomId': roomId,
      'userId': currentUserId,
      'enabled': isNoiseCancellation.value,
    });
  }

  void toggleSpatialAudio() {
    isSpatialAudio.value = !isSpatialAudio.value;
    socket?.emit('toggle_spatial_audio', {
      'roomId': roomId,
      'userId': currentUserId,
      'enabled': isSpatialAudio.value,
    });
  }

  void requestSeat(String seatNumberDisplay) {
    if (seats.isNotEmpty) {
      joinSeat(0);
    }
  }

  Future<void> deleteRoom() async {
    if (!canManageRoom) {
      Get.snackbar('Access Denied', 'Only the room owner can delete the room',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    socket?.emit('delete_room', {'roomId': roomId});
    Get.back();
  }

  @override
  void onInit() {
    super.onInit();
    loadAvailableBackgrounds();
    socket?.on('pk_score_updated', (data) {
      if (data is Map) {
        currentPKChallenge.value = PKChallenge.fromJson(Map<String, dynamic>.from(data));
      }
    });
    socket?.on('room_background_updated', (data) {
      if (data is Map) {
        selectedBackgroundUrl.value = data['backgroundUrl']?.toString() ?? '';
        selectedBackgroundName.value = data['backgroundName']?.toString() ?? '';
      }
    });
  }

  @override
  void onClose() {
    chatScrollController.dispose();
    super.onClose();
  }
}