// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/controllers/room_controller.dart
// ARVIND PARTY - ROOM CONTROLLER (extends LiveRoomController)
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

  // ─── Room Background ────────────────────────────────────────
  final selectedBackgroundName = ''.obs;

  // ─── Voice Effects & Audio ───────────────────────────────────
  final selectedVoiceEffect = VoiceEffect.none.obs;
  final isNoiseCancellation = false.obs;
  final isSpatialAudio = false.obs;

  // ─── Member Management ──────────────────────────────────────
  @override
  final members = <RoomMemberModel>[].obs;
  final bannedUsers = <Map<String, dynamic>>[].obs;
  final raiseHandRequests = <RaiseHandRequest>[].obs;

  RoomController({
    super.roomId,
    super.roomOwnerId,
    super.initialSeatCount = 12,
  });

  // ─── Member Management ──────────────────────────────────────
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

  // ─── Chat ───────────────────────────────────────────────────
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

  // ─── Raise Hand ─────────────────────────────────────────────
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

  // ─── Room Actions ───────────────────────────────────────────
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

  // ─── Seat Actions ───────────────────────────────────────────
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

  // ─── Room Settings ──────────────────────────────────────────
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

  // ─── Backend fallback for room detail ───────────────────────
  void loadRooms({String? type}) {}

  Future<void> fetchRoomDetail(String roomId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/rooms/$roomId');
      if (response is Map && response['success'] == true) {
        currentRoom.value = RoomModel.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('[RoomController] fetchRoomDetail error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Voice Effect & Audio Features ──────────────────────────
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

  // ─── Additional Seat Methods ───────────────────────────────
  void requestSeat(String seatNumberDisplay) {
    // Parse seat number to index (seatNumber is '${index + 1}')
    // For now, just call joinSeat with a reasonable index
    if (seats.isNotEmpty) {
      joinSeat(0); // Default to first available
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
  void onClose() {
    chatScrollController.dispose();
    super.onClose();
  }
}
