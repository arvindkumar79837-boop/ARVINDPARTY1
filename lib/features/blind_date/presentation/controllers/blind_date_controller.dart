// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/blind_date/presentation/controllers/blind_date_controller.dart
// ARVIND PARTY - BLIND DATE CONTROLLER (REFACTORED for REAL-TIME SOCKETS)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';

class BlindDateController extends GetxController {
  final isSearching = false.obs;
  final match = Rxn<Map<String, dynamic>>();
  final errorMessage = RxString('');
  final newRoomId = RxnString(); // To store the room ID for the new match

  io.Socket? _socket;
  final AuthSessionManager _session = Get.find<AuthSessionManager>();

  @override
  void onInit() {
    super.onInit();
    _initSocket();
  }

  void _initSocket() {
    try {
      final serverUrl = EnvConfig.socketUrl;
      final token = _session.token.value;

      _socket = io.io(serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .disableAutoConnect()
            .build());

      _socket!.connect();

      _socket!.onConnect((_) {
        print('[BlindDateSocket] Connected');
        _registerSocketListeners();
      });

      _socket!.onConnectError((data) => print('[BlindDateSocket] Connection Error: $data'));
      _socket!.onError((data) => print('[BlindDateSocket] Error: $data'));

    } catch (e) {
      errorMessage.value = 'Could not connect to matchmaking service.';
      print('[BlindDateSocket] Init failed: $e');
    }
  }

  void _registerSocketListeners() {
    // Listen for the 'match_found' event from the server
    _socket!.on('blind_date:match_found', (data) {
      print('[BlindDateSocket] Match Found!: $data');
      if (data is Map<String, dynamic>) {
        // Update the state with the matched user's info
        match.value = data['match'] as Map<String, dynamic>?;
        newRoomId.value = data['roomId'] as String?;
        isSearching.value = false;
      }
    });

    // Listen for any errors from the matchmaking service
    _socket!.on('matchmaking:error', (data) {
      errorMessage.value = data['message'] as String? ?? 'An unknown error occurred.';
      isSearching.value = false;
    });
  }

  /// Start searching for a blind date match by emitting an event
  void startSearch() {
    if (isSearching.value) return;
    if (_socket == null || !_socket!.connected) {
      errorMessage.value = 'Not connected to service. Retrying...';
      _initSocket(); // Attempt to reconnect
      return;
    }

    isSearching.value = true;
    errorMessage.value = '';
    match.value = null;
    newRoomId.value = null;

    _socket!.emit('blind_date:start_search');
  }

  /// Stop searching by emitting an event
  void stopSearch() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('blind_date:cancel_search');
    }
    isSearching.value = false;
    match.value = null;
    errorMessage.value = '';
  }

  /// Navigates to the newly created private room for the blind date
  void joinMatchRoom() {
    if (newRoomId.value != null) {
      // Navigate to the live room, passing the new room ID
      Get.toNamed('/room_screen', arguments: {'roomId': newRoomId.value});
    }
  }

  /// Reset to try again
  void reset() {
    match.value = null;
    errorMessage.value = '';
    isSearching.value = false;
    newRoomId.value = null;
  }

  @override
  void onClose() {
    // Clean up the socket connection when the controller is closed
    if (_socket != null) {
      if(isSearching.value) {
        stopSearch();
      }
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.onClose();
  }
}