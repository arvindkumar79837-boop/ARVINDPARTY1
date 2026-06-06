import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../auth/views/api_service.dart';
import '../models/room_models.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class LiveRoomController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  IO.Socket? socket;
  final String roomId;

  // --- Reactive State Variables ---
  final isConnected = false.obs;
  final messages = <ChatMessage>[].obs;
  final seats = <Seat>[].obs;
  final currentGift = Rxn<GiftAnimation>();
  final availableGifts = <Map<String, dynamic>>[].obs;
  final isMicMuted = false.obs;
  final activeSeat = Rxn<int>();

  LiveRoomController({required this.roomId});

  @override
  void onInit() {
    super.onInit();
    _initSocket();
    _fetchAvailableGifts();
  }

  void _initSocket() {
    try {
      // Get logged-in user profile from storage
      final userId = _storage.read('user_id');
      final userName = _storage.read('user_name');
      final userAvatar = _storage.read('user_avatar');

      if (userId == null) {
        Get.snackbar('Error', 'You are not logged in.',
            backgroundColor: Colors.redAccent);
        return;
      }

      // Connect to the Node.js Socket.IO server
      socket = IO.io(
          _apiService.baseUrl.replaceAll('/api/', ''),
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build());

      socket!.connect();

      // --- Standard Socket Event Listeners ---
      socket!.onConnect((_) {
        print('✅ Connected to Live Room Socket');
        isConnected.value = true;

        // Join the real room on the backend with full profile
        socket!.emit('join_room', {
          'roomId': roomId,
          'userId': userId,
          'userProfile': {'name': userName, 'avatar': userAvatar}
        });
      });

      socket!.onDisconnect((_) {
        print('❌ Disconnected from Live Room Socket');
        isConnected.value = false;
      });

      socket!.onConnectError((data) => print('Connection Error: $data'));
      socket!.onError((data) => print('Socket Error: $data'));

      // --- Custom App-Specific Event Listeners ---
      _registerAppEventListeners();
    } catch (e) {
      print('Socket Initialization Failed: $e');
      Get.snackbar('Error', 'Could not connect to the live server.');
    }
  }

  void _registerAppEventListeners() {
    // Listen for incoming chat messages
    socket!.on('receive_room_message', (data) {
      messages.insert(0, ChatMessage.fromJson(data));
    });

    // Listen for seat updates (mic seats)
    socket!.on('seat_updated', (data) {
      final updatedSeat = Seat.fromJson(data);
      final index =
          seats.indexWhere((s) => s.seatIndex == updatedSeat.seatIndex);
      if (index != -1) {
        seats[index] = updatedSeat;
      } else {
        seats.add(updatedSeat);
      }
    });

    // Listen for gift animations
    socket!.on('gift_animation', (data) {
      currentGift.value = GiftAnimation(
          giftId: data['giftId'],
          giftImageUrl: data['giftImageUrl'],
          senderName: data['senderName'],
          quantity: data['quantity']);
      // The UI will observe `currentGift` and play the animation
    });

    // Listen for system-wide announcements
    socket!.on('system_announcement', (data) {
      Get.snackbar(
        data['title'] ?? 'System Notice',
        data['message'] ?? '',
        backgroundColor: Colors.blueAccent.withOpacity(0.95),
        colorText: Colors.white,
        icon: const Icon(Icons.campaign, color: Colors.white, size: 28),
        duration: const Duration(seconds: 8),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  void _fetchAvailableGifts() async {
    try {
      final response = await _apiService.get('gifts');
      if (response.statusCode == 200 && response.data['gifts'] != null) {
        availableGifts
            .assignAll(List<Map<String, dynamic>>.from(response.data['gifts']));
      }
    } catch (e) {
      // Silently fail, the gift sheet will just be empty.
      // Or show a snackbar if this is critical.
      print('Failed to fetch gifts: $e');
    }
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty || socket == null || !isConnected.value) return;

    socket!.emit('send_room_message', {
      'roomId': roomId,
      'senderId': _storage.read('user_id'),
      'senderName': _storage.read('user_name') ?? 'Guest',
      'message': text,
      'isVip': false,
    });
  }

  void toggleMic() {
    if (socket == null || !isConnected.value) return;
    isMicMuted.value = !isMicMuted.value;
    socket!.emit('toggle_mic', {
      'roomId': roomId,
      'userId': _storage.read('user_id'),
      'isMuted': isMicMuted.value
    });
  }

  void sendGift(String receiverId, String giftId, {int quantity = 1}) {
    if (socket == null || !isConnected.value) return;
    socket!.emit('send_gift', {
      'roomId': roomId,
      'senderId': _storage.read('user_id'),
      'receiverId': receiverId,
      'giftId': giftId, // e.g., 'rose', 'diamond_ring'
      'quantity': quantity
    });
  }

  void claimSeat(int seatIndex) {
    if (socket == null || !isConnected.value) return;

    socket!.emit('claim_seat', {
      'roomId': roomId,
      'userId': _storage.read('user_id'),
      'userName': _storage.read('user_name') ?? 'Guest',
      'userAvatar': _storage.read('user_avatar') ?? '',
      'seatIndex': seatIndex
    });
  }

  @override
  void onClose() {
    // Let the backend know we are leaving so it can decrement activeUsers
    if (socket != null && isConnected.value) {
      socket!.emit(
          'leave_room', {'roomId': roomId, 'userId': _storage.read('user_id')});
      socket!.disconnect();
      socket!.dispose();
    }
    super.onClose();
  }
}
