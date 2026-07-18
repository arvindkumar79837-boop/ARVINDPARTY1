// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/services/room_socket_service.dart
// ARVIND PARTY - REAL-TIME ROOM EVENTS VIA SOCKET.IO
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:get/get.dart';
import '../../../core/socket/socket_service.dart';

class RoomSocketService extends GetxService {
  static RoomSocketService get to => Get.find<RoomSocketService>();

  late SocketService _socket;
  // Observables
  final connectedRooms = <String>[].obs;
  final roomMembers = <String, List<Map<String, dynamic>>>{}.obs;
  final seats = <String, Map<String, dynamic>>{}.obs;
  final messages = <String, List<Map<String, dynamic>>>{}.obs;
  final gifts = <String, List<Map<String, dynamic>>>{}.obs;

  // Stream controllers for events
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _giftController = StreamController<Map<String, dynamic>>.broadcast();
  final _seatController = StreamController<Map<String, dynamic>>.broadcast();
  final _memberController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get giftStream => _giftController.stream;
  Stream<Map<String, dynamic>> get seatStream => _seatController.stream;
  Stream<Map<String, dynamic>> get memberStream => _memberController.stream;
  Stream<String> get errorStream => _errorController.stream;

  @override
  void onInit() {
    super.onInit();
    _socket = Get.find<SocketService>();    _setupEventListeners();  }

  void _setupEventListeners() {
    // Room events
    _socket.on('room:user_joined', (data) {
      _handleUserJoined(data);
    });

    _socket.on('room:user_left', (data) {
      _handleUserLeft(data);
    });

    _socket.on('room:updated', (data) {
      _handleRoomUpdated(data);
    });

    // Message events
    _socket.on('room:message', (data) {
      _handleNewMessage(data);
    });

    _socket.on('chat:private', (data) {
      _handlePrivateMessage(data);
    });

    _socket.on('chat:typing', (data) {
      // Handle typing indicator
    });

    // Gift events
    _socket.on('gift:received', (data) {
      _handleGiftReceived(data);
    });

    _socket.on('gift:animation', (data) {
      _handleGiftAnimation(data);
    });

    // Seat events
    _socket.on('seat:occupied', (data) {
      _handleSeatOccupied(data);
    });

    _socket.on('seat:vacant', (data) {
      _handleSeatVacant(data);
    });

    _socket.on('seat:media-updated', (data) {
      _handleMediaUpdated(data);
    });

    _socket.on('seat:muted', (data) {
      _handleSeatMuted(data);
    });

    _socket.on('seat:update', (data) {
      _handleSeatUpdate(data);
    });

    _socket.on('seat:updated', (data) {
      _handleSeatUpdate(data);
    });

    // PK Battle events
    _socket.on('pk:started', (data) {
    });

    _socket.on('pk:ended', (data) {
    });

    // Host events
    _socket.on('user:kicked', (data) {
      _handleUserKicked(data);
    });

    _socket.on('kicked:from-room', (data) {
      _handleKickedFromRoom(data);
    });

    // Error events
    _socket.on('error', (data) {
      _errorController.add(data['message'] ?? 'Unknown error');
    });

    // Legacy events for backward compatibility
    _socket.on('receive_message', (data) {
      _handleNewMessage(data);
    });

    _socket.on('room_online_update', (data) {
      _handleRoomUpdated(data);
    });

    _socket.on('new_raise_hand', (data) {
      _handleNewRaiseHand(data);
    });

    _socket.on('raise_hand_approved', (data) {
    });

    _socket.on('gift_error', (data) {
      _errorController.add(data['message'] ?? 'Gift error');
    });
  }

  // ═══════ ROOM ACTIONS ═══════════════════════════════════════════════════

  Future<void> joinRoom(String roomId) async {
    try {
      _socket.emit('room:join', {'roomId': roomId});
      if (!connectedRooms.contains(roomId)) {
        connectedRooms.add(roomId);
      }
    } catch (e) {
      _errorController.add('Failed to join room');
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      _socket.emit('room:leave', {'roomId': roomId});
      connectedRooms.remove(roomId);
      roomMembers.remove(roomId);
      seats.remove(roomId);
      messages.remove(roomId);
      gifts.remove(roomId);
    } catch (e) {
    }
  }

  // ═══════ CHAT ACTIONS ═══════════════════════════════════════════════════

  void sendRoomMessage(String roomId, String message, {String messageType = 'text'}) {
    _socket.emit('room:message', {
      'roomId': roomId,
      'message': message,
      'messageType': messageType,
    });
  }

  void sendPrivateMessage(String receiverId, String message) {
    _socket.emit('chat:private', {
      'receiverId': receiverId,
      'message': message,
    });
  }

  void sendTypingIndicator(String chatId, bool isTyping) {
    _socket.emit('chat:typing', {
      'chatId': chatId,
      'isTyping': isTyping,
    });
  }

  void sendGift(String roomId, String giftId, String receiverId, int quantity) {
    _socket.emit('gift:send', {
      'roomId': roomId,
      'giftId': giftId,
      'receiverId': receiverId,
      'quantity': quantity,
    });
  }

  // ═══════ SEAT ACTIONS ═══════════════════════════════════════════════════

  void joinSeat(String roomId, int seatNumber) {
    _socket.emit('seat:join', {
      'roomId': roomId,
      'seatNumber': seatNumber,
    });
  }

  void leaveSeat(String roomId, int seatNumber) {
    _socket.emit('seat:leave', {
      'roomId': roomId,
      'seatNumber': seatNumber,
    });
  }

  void toggleSeatMute(String roomId, int seatNumber, bool muted) {
    _socket.emit('seat:mute', {
      'roomId': roomId,
      'seatNumber': seatNumber,
      'muted': muted,
    });
  }

  void lockSeat(String roomId, int seatNumber, bool locked) {
    _socket.emit('seat:lock', {
      'roomId': roomId,
      'seatNumber': seatNumber,
      'locked': locked,
    });
  }

  void raiseHand(String roomId) {
    _socket.emit('seat:raise_hand', {'roomId': roomId});
  }

  void approveHand(String roomId, String userId) {
    _socket.emit('seat:approve', {'roomId': roomId, 'userId': userId});
  }

  // ═══════ EVENT HANDLERS ════════════════════════════════════════════════

  void _handleUserJoined(dynamic data) {
    final event = Map<String, dynamic>.from(data);
    final roomId = event['roomId']?.toString() ?? '';
    final userId = event['userId']?.toString() ?? '';

    if (roomId.isNotEmpty && userId.isNotEmpty) {
      if (!roomMembers.containsKey(roomId)) {
        roomMembers[roomId] = [];
      }
      roomMembers[roomId]!.add({
        'userId': userId,
        'userName': event['userName'] ?? 'Unknown',
        'userAvatar': event['userAvatar'],
        'joinedAt': event['timestamp'],
      });
      _memberController.add(event);
    }
  }

  void _handleUserLeft(dynamic data) {
    final event = Map<String, dynamic>.from(data);
    final roomId = event['roomId']?.toString() ?? '';
    final userId = event['userId']?.toString() ?? '';

    if (roomId.isNotEmpty && userId.isNotEmpty && roomMembers.containsKey(roomId)) {
      roomMembers[roomId]!.removeWhere((m) => m['userId'] == userId);
      _memberController.add(event);
    }
  }

  void _handleRoomUpdated(dynamic data) {
    final event = Map<String, dynamic>.from(data);
    _memberController.add(event);
  }

  void _handleNewMessage(dynamic data) {
    final msg = Map<String, dynamic>.from(data);
    final roomId = msg['roomId']?.toString() ?? '';

    if (roomId.isNotEmpty) {
      if (!messages.containsKey(roomId)) {
        messages[roomId] = [];
      }
      messages[roomId]!.add(msg);
      _messageController.add(msg);
    }
  }

  void _handlePrivateMessage(dynamic data) {
    final msg = Map<String, dynamic>.from(data);
    _messageController.add(msg);
  }

  void _handleGiftReceived(dynamic data) {
    final gift = Map<String, dynamic>.from(data);
    final roomId = gift['roomId']?.toString() ?? '';

    if (roomId.isNotEmpty) {
      if (!gifts.containsKey(roomId)) {
        gifts[roomId] = [];
      }
      gifts[roomId]!.add(gift);
      _giftController.add(gift);
    }
  }

  void _handleGiftAnimation(dynamic data) {
    final gift = Map<String, dynamic>.from(data);
    _giftController.add(gift);
  }

  void _handleSeatOccupied(dynamic data) {
    final seat = Map<String, dynamic>.from(data);
    final roomId = seat['roomId']?.toString() ?? '';

    if (roomId.isNotEmpty) {
      if (!seats.containsKey(roomId)) {
        seats[roomId] = {};
      }
      final seatNumber = seat['seatNumber']?.toString() ?? '0';
      seats[roomId]![seatNumber] = {
        'userId': seat['userId'],
        'userName': seat['userName'],
        'userAvatar': seat['userAvatar'],
        'status': 'joined',
        'isAudioEnabled': true,
        'isVideoEnabled': true,
      };
      _seatController.add(seat);
    }
  }

  void _handleSeatVacant(dynamic data) {
    final seat = Map<String, dynamic>.from(data);
    final roomId = seat['roomId']?.toString() ?? '';

    if (roomId.isNotEmpty && seats.containsKey(roomId)) {
      final seatNumber = seat['seatNumber']?.toString() ?? '0';
      seats[roomId]!.remove(seatNumber);
      _seatController.add(seat);
    }
  }

  void _handleMediaUpdated(dynamic data) {
    final update = Map<String, dynamic>.from(data);
    final roomId = update['roomId']?.toString() ?? '';

    if (roomId.isNotEmpty && seats.containsKey(roomId)) {
      final userId = update['userId']?.toString() ?? '';
      final seatNumber = update['seatNumber']?.toString() ?? '0';

      for (final entry in seats[roomId]!.entries) {
        if (entry.value['userId'] == userId) {
          seats[roomId]![seatNumber] = {
            ...entry.value,
            'isAudioEnabled': update['isAudioEnabled'] ?? entry.value['isAudioEnabled'],
            'isVideoEnabled': update['isVideoEnabled'] ?? entry.value['isVideoEnabled'],
          };
          break;
        }
      }
      _seatController.add(update);
    }
  }

  void _handleSeatMuted(dynamic data) {
    final seat = Map<String, dynamic>.from(data);
    _seatController.add(seat);
  }

  void _handleSeatUpdate(dynamic data) {
    final update = Map<String, dynamic>.from(data);
    _seatController.add(update);
  }

  void _handleUserKicked(dynamic data) {
    final event = Map<String, dynamic>.from(data);
    final roomId = event['roomId']?.toString() ?? '';
    final userId = event['userId']?.toString() ?? '';

    if (roomId.isNotEmpty && roomMembers.containsKey(roomId)) {
      roomMembers[roomId]!.removeWhere((m) => m['userId'] == userId);
      _memberController.add(event);
    }
  }

  void _handleKickedFromRoom(dynamic data) {
    final event = Map<String, dynamic>.from(data);
    final roomId = event['roomId']?.toString() ?? '';

    if (roomId.isNotEmpty) {
      leaveRoom(roomId);
    }
    connectedRooms.clear();
    _errorController.add('You have been removed from the room');
  }

  void _handleNewRaiseHand(dynamic data) {
  }

  // ═══════ UTILITY METHODS ═══════════════════════════════════════════════

  bool isInRoom(String roomId) {
    return connectedRooms.contains(roomId);
  }

  List<Map<String, dynamic>> getRoomMembers(String roomId) {
    return roomMembers[roomId] ?? [];
  }

  int getRoomMemberCount(String roomId) {
    return (roomMembers[roomId] ?? []).length;
  }

  void clearRoomData(String roomId) {
    roomMembers.remove(roomId);
    seats.remove(roomId);
    messages.remove(roomId);
    gifts.remove(roomId);
  }

  @override
  void onClose() {
    for (final roomId in connectedRooms.toList()) {
      leaveRoom(roomId);
    }

    _socket.off('room:user_joined');
    _socket.off('room:user_left');
    _socket.off('room:updated');
    _socket.off('room:message');
    _socket.off('chat:private');
    _socket.off('chat:typing');
    _socket.off('gift:received');
    _socket.off('gift:animation');
    _socket.off('seat:occupied');
    _socket.off('seat:vacant');
    _socket.off('seat:media-updated');
    _socket.off('seat:muted');
    _socket.off('seat:update');
    _socket.off('seat:updated');
    _socket.off('pk:started');
    _socket.off('pk:ended');
    _socket.off('user:kicked');
    _socket.off('kicked:from-room');
    _socket.off('error');
    _socket.off('receive_message');
    _socket.off('room_online_update');
    _socket.off('new_raise_hand');
    _socket.off('raise_hand_approved');
    _socket.off('gift_error');

    _messageController.close();
    _giftController.close();
    _seatController.close();
    _memberController.close();
    _errorController.close();

    super.onClose();
  }
}