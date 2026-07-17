// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/controllers/live_room_controller.dart
// ARVIND PARTY - LIVE STREAMING CONTROLLER (with stub for Agora)
// Agora activated when package is added
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:arvind_party/core/constants/env_config.dart';
import 'package:arvind_party/core/services/api_service.dart';
import 'package:arvind_party/core/services/livekit_service.dart';
import 'package:arvind_party/features/room/models/room_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class LiveRoomController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ─── LiveKit Service ───────────────────────────────────────
  final LiveKitService liveKitService = Get.find<LiveKitService>();

  // ─── Room Identity ──────────────────────────────────────────
  final String roomId;
  final String roomOwnerId;
  final int initialSeatCount;

  LiveRoomController({
    this.roomId = '',
    this.roomOwnerId = '',
    this.initialSeatCount = 12,
  });
  io.Socket? socket;

  String get currentUserId => _storage.read('user_id') ?? '';
  String get currentUserName => _storage.read('user_name') ?? 'Guest';
  String get currentUserAvatar => _storage.read('user_avatar') ?? '';

  // ─── Connection States ──────────────────────────────────────
  final isConnected = false.obs;
  final isLiveKitInitialized = false.obs;
  final liveKitError = Rxn<String>();
  final connectionRetryCount = 0.obs;
  static const int maxRetries = 3;
  Timer? _reconnectTimer;
  Timer? _giftAnimationTimer;

  // ─── Chat ───────────────────────────────────────────────────
  final chatMessages = <ChatMessage>[].obs;

  // ─── Seats (Dynamic 8-30) ──────────────────────────────────
  final seats = <SeatData>[].obs;
  final seatCount = 0.obs;
  final activeSeat = Rxn<int>();

  // ─── Members ───────────────────────────────────────────────
  final members = <RoomMemberModel>[].obs;

  // ─── Gift System ───────────────────────────────────────────
  final activeGiftAnimation = Rxn<GiftAnimation>();
  final availableGifts = <Map<String, dynamic>>[].obs;

  // ─── Audio/Video Control ───────────────────────────────────
  final isMuted = false.obs;
  final isVideoEnabled = false.obs;
  final isSpeakerEnabled = true.obs;

  // ─── Remote Users (LiveKit) ────────────────────────────────
  final remoteUsers = <String>[].obs;
  final mutedRemoteUsers = <int>[].obs;

  // ─── Moderation ─────────────────────────────────────────────
  final kickedUsersList = <Map<String, dynamic>>[].obs;
  final mutedUsersList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSeats(initialSeatCount);
    _initSocket();
    _fetchAvailableGifts();
    _initLiveKit();
  }

  Future<void> _initLiveKit() async {
    await liveKitService.initialize();
    isLiveKitInitialized.value = true;
  }

  /// Initialize dynamic seat layout (8-30 seats) using SeatLayoutService
  void _initializeSeats(int count) {
    final validCount = count;
    seatCount.value = validCount;
    seats.assignAll(
      List.generate(validCount, (i) => SeatData(seatIndex: i)),
    );
  }

  /// Update seat layout dynamically (owner only)
  Future<void> changeSeatLayout(int newCount) async {
    if (currentUserId != roomOwnerId) {
      Get.snackbar('Access Denied', 'Only room owner can change seat layout',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (newCount < 1) return;
    seatCount.value = newCount;
    _initializeSeats(newCount);
    socket?.emit('update_seat_layout', {
      'roomId': roomId,
      'seatCount': newCount,
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // SOCKET CONNECTION - REAL-TIME COMMUNICATION
  // ══════════════════════════════════════════════════════════════════

  void _initSocket() {
    try {
      final userId = _storage.read('user_id');
      if (userId == null) {
        Get.snackbar('Error', 'You are not logged in.',
            backgroundColor: Colors.redAccent);
        return;
      }

      final serverUrl = _storage.read('socket_url') ?? EnvConfig.socketUrl;
      final token = _storage.read('token') ?? '';
      socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth(<String, dynamic>{'token': token})
            .build(),
      );
      socket!.connect();

      socket!.onConnect((_) {
        isConnected.value = true;
        socket!.emit('join_room', {
          'roomId': roomId,
          'userId': userId,
          'userProfile': {'name': currentUserName, 'avatar': currentUserAvatar},
        });
      });

      socket!.onDisconnect((_) {
        isConnected.value = false;
      });

      socket!.onConnectError((data) {
        isConnected.value = false;
      });

      _registerSocketEventListeners();
    } catch (e) {
    }
  }

  void _registerSocketEventListeners() {
    socket!.on('receive_room_message', (data) {
      if (data is Map) {
        chatMessages.insert(
            0, ChatMessage.fromJson(Map<String, dynamic>.from(data)));
      }
    });

    socket!.on('seat_updated', (data) {
      if (data is Map) {
        if (data['seats'] is List) {
          final List<dynamic> jsonSeats = data['seats'];
          final currentCount = seatCount.value;
          final updatedSeats = jsonSeats
              .map((s) => SeatData.fromJson(Map<String, dynamic>.from(s)))
              .where((s) => s.index < currentCount)
              .toList();
          seats.assignAll(updatedSeats);
        } else {
          final updatedSeat =
              SeatData.fromJson(Map<String, dynamic>.from(data));
          final index = seats.indexWhere((s) => s.index == updatedSeat.index);
          if (index != -1) {
            seats[index] = updatedSeat;
          } else if (updatedSeat.index < seatCount.value) {
            seats.add(updatedSeat);
          }
        }
      }
    });

    socket!.on('seat_layout_changed', (data) {
      if (data is Map && data['seatCount'] != null) {
        _initializeSeats(data['seatCount'] as int);
      }
    });

    socket!.on('gift_animation', (data) {
      if (data is Map) {
        activeGiftAnimation.value = GiftAnimation(
          giftId: data['giftId']?.toString() ?? '',
          giftName: data['giftName']?.toString() ?? 'Gift',
          giftImageUrl: data['giftImageUrl']?.toString() ?? '',
          senderName: data['senderName']?.toString() ?? 'Unknown',
          quantity: data['quantity'] ?? 1,
        );
        final animDuration = Duration(seconds: data['duration'] as int? ?? 4);
        _giftAnimationTimer?.cancel();
        _giftAnimationTimer = Timer(animDuration, () {
          if (activeGiftAnimation.value?.giftId == data['giftId']?.toString()) {
            activeGiftAnimation.value = null;
          }
        });
      }
    });

    socket!.on('system_announcement', (data) {
      if (data is Map) {
        Get.snackbar(
          data['title']?.toString() ?? 'System Notice',
          data['message']?.toString() ?? '',
          backgroundColor: Colors.blueAccent.withValues(alpha: 0.95),
          colorText: Colors.white,
          icon: const Icon(Icons.campaign, color: Colors.white, size: 28),
          duration: const Duration(seconds: 8),
          margin: const EdgeInsets.all(16),
        );
      }
    });

    socket!.on('user_kicked', (data) {
      if (data is Map && data['targetUserId']?.toString() == currentUserId) {
        Get.defaultDialog(
          title: 'Kicked from Room',
          middleText: 'You have been removed from the room by the owner.',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          buttonColor: Colors.redAccent,
          barrierDismissible: false,
          onConfirm: () {
            Get.back();
            Get.back();
          },
        );
      }
    });

    socket!.on('user_admin_muted', (data) {
      if (data is Map && data['targetUserId']?.toString() == currentUserId) {
        Get.snackbar('Muted', 'You have been muted by the room owner.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        if (!isMuted.value) {
          isMuted.value = true;
        }
      }
    });

    socket!.on('raise_hand_notification', (data) {
      if (data is Map) {
        Get.snackbar(
          'Raise Hand',
          '${data['userName'] ?? 'Someone'} wants to speak',
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    });

    socket!.on('room_closed', (data) {
      Get.defaultDialog(
        title: 'Room Closed',
        middleText: 'This room has been closed by the owner.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        barrierDismissible: false,
        onConfirm: () {
          Get.back();
          Get.back();
        },
      );
    });

    // ─── Member Events ──────────────────────────────────────────
    socket!.on('member_joined', (data) {
      if (data is Map) {
        final member = RoomMemberModel(
          id: data['id']?.toString() ?? '',
          userId: data['userId']?.toString() ?? '',
          userName: data['userName']?.toString() ?? 'Unknown',
          role: _parseRole(data['role']?.toString() ?? 'member'),
          isOnline: true,
          avatar: data['avatar']?.toString(),
          userLevel: data['userLevel'] as int?,
        );
        if (!members.any((m) => m.userId == member.userId)) {
          members.add(member);
        }
        Get.snackbar(
          'Member Joined',
          '${member.userName} joined the room',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.greenAccent.withValues(alpha: 0.8),
        );
      }
    });

    socket!.on('member_left', (data) {
      if (data is Map && data['userId'] != null) {
        final userId = data['userId'].toString();
        members.removeWhere((m) => m.userId == userId);
        Get.snackbar(
          'Member Left',
          '${data['userName'] ?? 'Someone'} left the room',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.8),
        );
      }
    });

    socket!.on('members_list', (data) {
      if (data is Map && data['members'] is List) {
        final List<dynamic> membersList = data['members'];
        members.assignAll(
          membersList
              .map((m) => RoomMemberModel(
                    id: m['id']?.toString() ?? '',
                    userId: m['userId']?.toString() ?? '',
                    userName: m['userName']?.toString() ?? 'Unknown',
                    role: _parseRole(m['role']?.toString() ?? 'member'),
                    isOnline: m['isOnline'] ?? true,
                    avatar: m['avatar']?.toString(),
                    userLevel: m['userLevel'] as int?,
                  ))
              .toList(),
        );
      }
    });

    // ─── Moderation & Promotion Events ──────────────────────────
    socket!.on('user_unmuted', (data) {
      if (data is Map && data['targetUserId']?.toString() == currentUserId) {
        isMuted.value = false;
        Get.snackbar('Unmuted', 'You have been unmuted',
            backgroundColor: Colors.greenAccent,
            colorText: Colors.black,
            duration: const Duration(seconds: 2));
      }
    });

    socket!.on('member_promoted', (data) {
      if (data is Map) {
        final userId = data['userId']?.toString();
        final newRole = _parseRole(data['newRole']?.toString() ?? 'member');
        final idx = members.indexWhere((m) => m.userId == userId);
        if (idx != -1) {
          members[idx] = members[idx].copyWith(role: newRole);
        }
        if (userId == currentUserId) {
          Get.snackbar('Promoted', 'You have been promoted to ${newRole.name}',
              backgroundColor: Colors.blueAccent,
              colorText: Colors.white);
        }
      }
    });

    socket!.on('member_demoted', (data) {
      if (data is Map) {
        final userId = data['userId']?.toString();
        final newRole = _parseRole(data['newRole']?.toString() ?? 'member');
        final idx = members.indexWhere((m) => m.userId == userId);
        if (idx != -1) {
          members[idx] = members[idx].copyWith(role: newRole);
        }
        if (userId == currentUserId) {
          Get.snackbar('Demoted', 'You have been demoted to ${newRole.name}',
              backgroundColor: Colors.orangeAccent,
              colorText: Colors.white);
        }
      }
    });

    socket!.on('member_banned', (data) {
      if (data is Map && data['targetUserId']?.toString() == currentUserId) {
        Get.defaultDialog(
          title: 'Banned from Room',
          middleText: 'You have been banned from this room.',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          buttonColor: Colors.redAccent,
          barrierDismissible: false,
          onConfirm: () {
            Get.back();
            Get.back();
          },
        );
      } else if (data is Map && data['bannedUserId'] != null) {
        members.removeWhere((m) => m.userId == data['bannedUserId'].toString());
      }
    });

    // ─── Seat & Voice Events ────────────────────────────────────
    socket!.on('seat_claimed', (data) {
      if (data is Map) {
        final seatIndex = data['seatIndex'] as int?;
        if (seatIndex != null && seatIndex < seats.length) {
          seats[seatIndex] = seats[seatIndex].copyWith(
            userId: data['userId']?.toString(),
            userName: data['userName']?.toString(),
            userAvatar: data['userAvatar']?.toString(),
            role: data['role']?.toString() ?? 'broadcaster',
          );
        }
      }
    });

    socket!.on('seat_vacated', (data) {
      if (data is Map) {
        final seatIndex = data['seatIndex'] as int?;
        if (seatIndex != null && seatIndex < seats.length) {
          seats[seatIndex] = seats[seatIndex].copyWith(
            role: 'empty',
            isMuted: false,
          );
        }
      }
    });

    socket!.on('user_voice_state_changed', (data) {
      if (data is Map) {
        final userId = data['userId']?.toString();
        final isMutedRemote = data['isMuted'] as bool? ?? false;

        // Update seat mute state
        final seatIdx = seats.indexWhere((s) => s.userId == userId);
        if (seatIdx != -1) {
          seats[seatIdx] = seats[seatIdx].copyWith(isMuted: isMutedRemote);
        }

        // Track remote user mute state
        final hash = userId.hashCode;
        if (isMutedRemote && !mutedRemoteUsers.contains(hash)) {
          mutedRemoteUsers.add(hash);
        } else if (!isMutedRemote) {
          mutedRemoteUsers.removeWhere((uid) => uid == hash);
        }
      }
    });

    socket!.on('connection_error', (data) {
      if (data is Map) {
        Get.snackbar(
            'Connection Error', data['message']?.toString() ?? 'Unknown error',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  /// Parse role string to MemberRole enum
  MemberRole _parseRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'host':
      case 'owner':
        return MemberRole.host;
      case 'cohost':
      case 'co_host':
        return MemberRole.coHost;
      case 'moderator':
      case 'mod':
        return MemberRole.moderator;
      case 'speaker':
      case 'broadcaster':
        return MemberRole.speaker;
      case 'muted':
        return MemberRole.muted;
      case 'visitor':
        return MemberRole.visitor;
      case 'admin':
        return MemberRole.admin;
      default:
        return MemberRole.listener;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // CHAT & GIFTS
  // ══════════════════════════════════════════════════════════════════

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

  void _fetchAvailableGifts() async {
    try {
      final response = await _apiService.get('/gifts');
      if (response is Map && response['success'] == true) {
        final list =
            response['data'] as List? ?? response['gifts'] as List? ?? [];
        availableGifts
            .assignAll(list.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
    }
  }

  Future<void> fetchModerationList() async {
    if (currentUserId != roomOwnerId) return;
    try {
      final response = await _apiService.get('/rooms/$roomId/moderation');
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        kickedUsersList.assignAll(
          (data['kickedUsers'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
        mutedUsersList.assignAll(
          (data['mutedUsers'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }
    } catch (e) {
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // SEAT MANAGEMENT
  // ══════════════════════════════════════════════════════════════════

  Future<void> joinSeat(int seatIndex) async {
    if (socket == null || !isConnected.value) return;
    if (seatIndex < 0 || seatIndex >= seats.length) return;
    if (seats[seatIndex].isOccupied) {
      Get.snackbar('Seat Taken', 'This seat is already occupied',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    seats[seatIndex] = seats[seatIndex].copyWith(
      userId: currentUserId,
      userName: currentUserName,
      userAvatar: currentUserAvatar,
      role: currentUserId == roomOwnerId ? 'owner' : 'broadcaster',
    );
    activeSeat.value = seatIndex;
    socket!.emit('claim_seat', {
      'roomId': roomId,
      'userId': currentUserId,
      'userName': currentUserName,
      'userAvatar': currentUserAvatar,
      'seatIndex': seatIndex,
    });
  }

  Future<void> leaveSeat() async {
    final idx = activeSeat.value;
    if (idx == null || idx < 0 || idx >= seats.length) return;
    seats[idx] = seats[idx].copyWith(
      role: 'empty',
    );
    activeSeat.value = null;
    isMuted.value = false;
    socket!.emit('leave_seat', {'roomId': roomId, 'seatIndex': idx});
  }

  void toggleLockSeat(int seatIndex) {
    if (currentUserId != roomOwnerId ||
        seatIndex < 0 ||
        seatIndex >= seats.length) {
      return;
    }
    final newLocked = !seats[seatIndex].isLocked;
    seats[seatIndex] = seats[seatIndex].copyWith(isLocked: newLocked);
    socket!.emit(newLocked ? 'lock_seat' : 'unlock_seat', {
      'roomId': roomId,
      'seatIndex': seatIndex,
    });
  }

  void muteSeat(int seatIndex) {
    if (currentUserId != roomOwnerId ||
        seatIndex < 0 ||
        seatIndex >= seats.length) {
      return;
    }
    seats[seatIndex] = seats[seatIndex].copyWith(isMuted: true);
    socket!.emit('admin_mute_seat', {'roomId': roomId, 'seatIndex': seatIndex});
  }

  void unmuteSeat(int seatIndex) {
    if (currentUserId != roomOwnerId ||
        seatIndex < 0 ||
        seatIndex >= seats.length) {
      return;
    }
    seats[seatIndex] = seats[seatIndex].copyWith(isMuted: false);
    socket!
        .emit('admin_unmute_seat', {'roomId': roomId, 'seatIndex': seatIndex});
  }

  void kickFromSeat(int seatIndex) {
    if (currentUserId != roomOwnerId ||
        seatIndex < 0 ||
        seatIndex >= seats.length) {
      return;
    }
    seats[seatIndex] = seats[seatIndex].copyWith(
      isMuted: false,
      role: 'empty',
    );
    if (activeSeat.value == seatIndex) activeSeat.value = null;
    socket!.emit('kick_from_seat', {'roomId': roomId, 'seatIndex': seatIndex});
  }

  void transferSeat(
      int fromSeatIndex, String toUserId, String toUserName, String toUserAvatar) {
    if (currentUserId != roomOwnerId ||
        fromSeatIndex < 0 ||
        fromSeatIndex >= seats.length) {
      return;
    }
    seats[fromSeatIndex] = seats[fromSeatIndex].copyWith(
      userId: toUserId,
      userName: toUserName,
      userAvatar: toUserAvatar,
    );
    socket!.emit('transfer_seat', {
      'roomId': roomId,
      'seatIndex': fromSeatIndex,
      'toUserId': toUserId,
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // AUDIO/VIDEO CONTROLS
  // ══════════════════════════════════════════════════════════════════

  void toggleMute() {
    if (isLiveKitInitialized.value) {
      liveKitService.toggleMicrophone(!isMuted.value);
      isMuted.value = !isMuted.value;
    }
  }

  void toggleVideo() {
    if (isLiveKitInitialized.value) {
      liveKitService.toggleCamera(!isVideoEnabled.value);
      isVideoEnabled.value = !isVideoEnabled.value;
    }
  }

  void toggleSpeaker() {
    if (isLiveKitInitialized.value) {
      liveKitService.toggleSpeaker(!isSpeakerEnabled.value);
      isSpeakerEnabled.value = !isSpeakerEnabled.value;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // GIFT & ROOM CONTROLS
  // ══════════════════════════════════════════════════════════════════

  void sendGiftToRoom(Map<String, dynamic> giftData) {
    if (socket == null || !isConnected.value) return;
    socket!.emit('send_gift', {
      'roomId': roomId,
      'senderId': currentUserId,
      'senderName': currentUserName,
      'receiverId': roomOwnerId,
      'giftId': giftData['id']?.toString() ?? '',
      'giftName': giftData['name']?.toString() ?? 'Gift',
      'quantity': giftData['quantity'] ?? 1,
      'cost': giftData['cost'] ?? 0,
    });
  }

  void raiseHand() {
    if (socket == null || !isConnected.value) return;
    socket!.emit('raise_hand', {
      'roomId': roomId,
      'userId': currentUserId,
      'userName': currentUserName,
    });
    Get.snackbar('Hand Raised', 'Waiting for host approval',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2));
  }

  Future<void> closeRoomEnvironment() async {
    if (currentUserId != roomOwnerId) {
      Get.snackbar('Access Denied', 'Only the room owner can close the room',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    socket?.emit('close_room', {'roomId': roomId, 'ownerId': currentUserId});
    Get.back();
  }

  void closeRoom() {
    if (currentUserId != roomOwnerId) {
      Get.snackbar('Access Denied', 'Only the room owner can close the room',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    socket!.emit('close_room', {'roomId': roomId, 'ownerId': currentUserId});
    Get.back();
  }

  // List of registered socket event names for symmetric cleanup
  static const List<String> _socketEvents = [
    'room_joined', 'room_error', 'seat_updated', 'seat_locked', 'seat_unlocked',
    'user_kicked', 'user_muted', 'user_unmuted',
    'member_joined', 'member_left', 'members_list',
    'member_promoted', 'member_demoted',
    'gift_received', 'live_gift_effect', 'gift_goal_updated',
    'send_gift',
  ];

  @override
  void onClose() {
    _reconnectTimer?.cancel();
    _giftAnimationTimer?.cancel();
    if (socket != null) {
      // Remove all registered listeners before disconnecting
      for (final event in _socketEvents) {
        socket!.off(event);
      }
      if (isConnected.value) {
        socket!.emit('leave_room', {'roomId': roomId, 'userId': currentUserId});
      }
      socket!.disconnect();
      socket!.dispose();
    }
    if (isLiveKitInitialized.value) {
      liveKitService.leaveRoom();
    }
    super.onClose();
  }
}
