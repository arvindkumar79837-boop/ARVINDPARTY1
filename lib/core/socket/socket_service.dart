// ---------------------------------------------------------------------------
// FILE: lib/core/socket/socket_service.dart
// ARVIND PARTY - PRODUCTION SOCKET SERVICE
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../routes/app_routes.dart';
import '../constants/env_config.dart';
import '../services/auth_session_manager.dart';

class SocketService extends GetxService {
  io.Socket? _socket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  Worker? _authTokenWorker;

  final isConnected = false.obs;
  final connectionAttempts = 0.obs;

  static const int _maxReconnectAttempts = 10;
  static const int _reconnectDelayMs = 3000;
  static const int _heartbeatIntervalMs = 25000;

  String? _currentToken;

  io.Socket get socket {
    if (_socket == null) {
      throw Exception('SocketService: Call connect() first');
    }
    return _socket!;
  }

  @override
  void onInit() {
    super.onInit();
    _waitForAuthAndConnect();
  }

  Future<void> _waitForAuthAndConnect() async {
    final authSession = Get.find<AuthSessionManager>();

    if (authSession.token.value != null && authSession.token.value!.isNotEmpty) {
      await connect(token: authSession.token.value!);
      return;
    }

    _authTokenWorker = ever(authSession.token, (String? token) {
      if (token != null && token.isNotEmpty) {
        connect(token: token);
      }
    });
  }

  @override
  void onClose() {
    _authTokenWorker?.dispose();
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    disconnect();
    super.onClose();
  }

  Future<void> connect({String? token}) async {
    if (_socket != null && _socket!.connected) return;

    _currentToken = token;

    _socket = io.io(
      EnvConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(_maxReconnectAttempts)
          .setReconnectionDelay(_reconnectDelayMs)
          .setExtraHeaders({
            if (_currentToken != null) 'Authorization': 'Bearer ${_currentToken!}',
          })
          .setAuth({
            if (_currentToken != null) 'token': _currentToken!,
          })
          .build(),
    );

    _socket!.onConnect((_) {
      isConnected.value = true;
      connectionAttempts.value = 0;
      _startHeartbeat();
    });

    _socket!.on('force_logout', (data) async {
      final authSession = Get.find<AuthSessionManager>();
      await authSession.clearSession();
      disconnect();
      Get.offAllNamed(AppRoutes.login);
    });

    _socket!.onDisconnect((_) {
      isConnected.value = false;
      _stopHeartbeat();
    });

    _socket!.onConnectError((err) {
      isConnected.value = false;
      connectionAttempts.value++;
      _scheduleReconnect();
    });

    _socket!.onError((err) {
      debugPrint('SocketService: onError: $err');
    });

    _socket!.connect();
  }

  void _scheduleReconnect() {
    if (connectionAttempts.value >= _maxReconnectAttempts) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(milliseconds: _reconnectDelayMs * (connectionAttempts.value + 1)),
      () => connect(token: _currentToken),
    );
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(milliseconds: _heartbeatIntervalMs),
      (_) {
        if (_socket != null && _socket!.connected) {
          _socket!.emit('heartbeat', {'timestamp': DateTime.now().millisecondsSinceEpoch});
        }
      },
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void disconnect() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
    connectionAttempts.value = 0;
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    } else {
      debugPrint('SocketService: emit($event) dropped — socket not connected');
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void once(String event, Function(dynamic) callback) {
    _socket?.once(event, callback);
  }

  // Emit with acknowledgment (for request-response pattern)
  Future<dynamic> emitWithAck(String event, dynamic data, {Duration timeout = const Duration(seconds: 5)}) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    final completer = Completer<dynamic>();

    try {
      _socket!.emitWithAck(event, data, ack: (data) {
        if (!completer.isCompleted) {
          completer.complete(data);
        }
      });

      return await completer.future.timeout(timeout);
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    }
  }

  // --- ROOM EVENTS -------------------------------------------------
  void joinRoom(String roomId) { emit('room:join', {'roomId': roomId}); }
  void leaveRoom(String roomId) { emit('room:leave', {'roomId': roomId}); }
  void sendRoomMessage(String roomId, String message, String messageType) {
    emit('room:message', {'roomId': roomId, 'message': message, 'messageType': messageType});
  }
  void raiseHand(String roomId) { emit('seat:raise_hand', {'roomId': roomId}); }
  void approveHand(String roomId, String userId) {
    emit('seat:approve', {'roomId': roomId, 'userId': userId});
  }
  void joinSeat(String roomId, int seatNumber) {
    emit('seat:join', {'roomId': roomId, 'seatNumber': seatNumber});
  }
  void leaveSeat(String roomId, int seatNumber) {
    emit('seat:leave', {'roomId': roomId, 'seatNumber': seatNumber});
  }
  void toggleSeatMute(String roomId, int seatNumber, bool muted) {
    emit('seat:mute', {'roomId': roomId, 'seatNumber': seatNumber, 'muted': muted});
  }
  void lockSeat(String roomId, int seatNumber, bool locked) {
    emit('seat:lock', {'roomId': roomId, 'seatNumber': seatNumber, 'locked': locked});
  }
  void sendGift(String roomId, String giftId, String receiverId, int quantity) {
    emit('gift:send', {'roomId': roomId, 'giftId': giftId, 'receiverId': receiverId, 'quantity': quantity});
  }
  void sendPrivateMessage(String receiverId, String message) {
    emit('chat:private', {'receiverId': receiverId, 'message': message});
  }
  void sendTypingIndicator(String chatId, bool isTyping) {
    emit('chat:typing', {'chatId': chatId, 'isTyping': isTyping});
  }

  void onRoomMessage(Function(dynamic) callback) => on('room:message', callback);
  void onSeatUpdate(Function(dynamic) callback) => on('seat:update', callback);
  void onGiftAnimation(Function(dynamic) callback) => on('gift:animation', callback);
  void onUserJoined(Function(dynamic) callback) => on('room:user_joined', callback);
  void onUserLeft(Function(dynamic) callback) => on('room:user_left', callback);
  void onPrivateMessage(Function(dynamic) callback) => on('chat:private', callback);
  void onTypingIndicator(Function(dynamic) callback) => on('chat:typing', callback);
  void onError(Function(dynamic) callback) => on('error', callback);

  // --- LEGACY BACKWARD COMPATIBILITY --------------------------------
  void onReceiveMessage(Function(dynamic) callback) => on('receive_message', callback);
  void onRoomOnlineUpdate(Function(dynamic) callback) => on('room_online_update', callback);
  void onNewRaiseHand(Function(dynamic) callback) => on('new_raise_hand', callback);
  void onRaiseHandApproved(Function(dynamic) callback) => on('raise_hand_approved', callback);
  void onSeatUpdated(Function(dynamic) callback) => on('seat_updated', callback);
  void onGiftError(Function(dynamic) callback) => on('gift_error', callback);
  void offEvent(String event) => off(event);
}
