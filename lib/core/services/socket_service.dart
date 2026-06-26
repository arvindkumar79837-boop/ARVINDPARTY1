import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketService extends GetxService {
  static SocketService get to => Get.find<SocketService>();

  IO.Socket? _socket;
  final RxBool isConnected = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;

  // Callbacks
  final RxMap<String, Function> eventListeners = <String, Function>{}.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await connect();
  }

  Future<void> connect() async {
    try {
      const String serverUrl = 'http://192.168.1.100:5000';

      _socket = IO.io(
        serverUrl,
        <String, dynamic>{
          'transports': ['websocket', 'polling'],
          'autoConnect': true,
          'reconnection': true,
          'reconnectionAttempts': 5,
          'reconnectionDelay': 1000,
          'reconnectionDelayMax': 5000,
          'auth': {'token': 'YOUR_JWT_TOKEN_HERE'},
          'extraHeaders': {'Authorization': 'Bearer YOUR_JWT_TOKEN_HERE'},
        },
      );

      _socket!.onConnect((event) {
        isConnected.value = true;
        connectionStatus.value = 'Connected';
        print('✅ Socket connected: ${_socket!.id}');
      });

      _socket!.onDisconnect((event) {
        isConnected.value = false;
        connectionStatus.value = 'Disconnected';
        print('❌ Socket disconnected');
      });

      _socket!.onConnectError((error) {
        isConnected.value = false;
        connectionStatus.value = 'Connection Error';
        print('❌ Socket connection error: $error');
      });

      _socket!.onError((error) {
        isConnected.value = false;
        connectionStatus.value = 'Error';
        print('❌ Socket error: $error');
      });

      _socket!.onReconnect((event) {
        print('🔄 Socket reconnected');
      });

      _socket!.onReconnectAttempt((attempt) {
        print('🔄 Reconnection attempt: $attempt');
      });

      _socket!.onReconnectError((error) {
        print('❌ Reconnection error: $error');
      });

      _socket!.onReconnectFailed((event) {
        print('❌ Reconnection failed');
      });
    } catch (e) {
      print('❌ Socket connection failed: $e');
      connectionStatus.value = 'Failed';
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    isConnected.value = false;
    connectionStatus.value = 'Disconnected';
  }

  // Emit events
  void emit(String event, dynamic data) {
    if (_socket != null && isConnected.value) {
      _socket!.emit(event, data);
      print('📤 Emitted: $event');
    } else {
      print('⚠️ Cannot emit event $event: Socket not connected');
    }
  }

  // Listen to events
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
    eventListeners[event] = callback;
    print('👂 Listening to: $event');
  }

  void off(String event) {
    _socket?.off(event);
    eventListeners.remove(event);
    print('🔇 Stopped listening to: $event');
  }

  // Room management
  void joinRoom(String roomId) {
    emit('join_room', {'roomId': roomId});
  }

  void leaveRoom(String roomId) {
    emit('leave_room', {'roomId': roomId});
  }

  // Gift events
  void onGiftReceived(Function(dynamic) callback) {
    on('gift_received', callback);
  }

  void onNotificationUpdate(Function(dynamic) callback) {
    on('notification_update', callback);
  }

  // VIP events
  void onVipEntry(Function(dynamic) callback) {
    on('vip_entry', callback);
  }

  void onVipGlobalAlert(Function(dynamic) callback) {
    on('vip_global_alert', callback);
  }

  // PK Battle events
  void onPkBattleUpdate(Function(dynamic) callback) {
    on('pk_battle_update', callback);
  }

  void onPkBattleResult(Function(dynamic) callback) {
    on('pk_battle_result', callback);
  }

  // Room events
  void onUserJoined(Function(dynamic) callback) {
    on('user_joined', callback);
  }

  void onUserLeft(Function(dynamic) callback) {
    on('user_left', callback);
  }

  void onRoomUpdated(Function(dynamic) callback) {
    on('room_updated', callback);
  }

  // Seat events
  void onSeatTaken(Function(dynamic) callback) {
    on('seat_taken', callback);
  }

  void onSeatReleased(Function(dynamic) callback) {
    on('seat_released', callback);
  }

  // Analytics events
  void onRevenueSummaryUpdated(Function(dynamic) callback) {
    on('revenue_summary_updated', callback);
  }

  // Mission events
  void onMissionProgress(Function(dynamic) callback) {
    on('mission_progress', callback);
  }

  // Level up events
  void onFriendLevelUp(Function(dynamic) callback) {
    on('friend_level_up', callback);
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}