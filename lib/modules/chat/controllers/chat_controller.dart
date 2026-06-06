import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;

  ChatMessage(
      {required this.id,
      required this.senderId,
      required this.receiverId,
      required this.content});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class ChatController extends GetxController {
  IO.Socket? socket;
  var isConnected = false.obs;
  var messages = <ChatMessage>[].obs;
  final messageInputController = TextEditingController();

  final String currentUserId = GetStorage().read('user_id') ?? '';
  var targetUserId =
      ''.obs; // The person you are currently viewing the chat with
  var isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initChatSocket();
  }

  void _initChatSocket() {
    if (currentUserId.isEmpty) return;

    socket = IO.io(
      ApiConstants.baseUrl, // Connect to base URL
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      isConnected.value = true;
      socket!.emit('register_user', {'userId': currentUserId});
    });

    socket!.on('receive_private_message', (data) {
      final newMessage = ChatMessage.fromJson(data);

      // Only display immediately if we are actively chatting with this user
      if (newMessage.senderId == targetUserId.value) {
        messages.insert(0, newMessage);
      } else {
        // Otherwise, show a global notification bubble
        Get.snackbar('New Message', 'You received a private message.',
            backgroundColor: const Color(0xFF15141F), colorText: Colors.white);
      }
    });

    socket!.on('message_sent_ack', (data) {
      if (data['success'] == true) {
        messages.insert(0, ChatMessage.fromJson(data['message']));
      }
    });
  }

  Future<void> openChat(String targetId) async {
    targetUserId.value = targetId;
    messages.clear();
    isLoadingHistory.value = true;
    try {
      final response =
          await ApiClient().get('/chat/history/$currentUserId/$targetId');
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        messages.assignAll(data.map((m) => ChatMessage.fromJson(m)).toList());
      }
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void sendMessage() {
    final text = messageInputController.text.trim();
    if (text.isEmpty || targetUserId.value.isEmpty || socket == null) return;

    socket!.emit('send_private_message', {
      'senderId': currentUserId,
      'receiverId': targetUserId.value,
      'content': text,
    });
    messageInputController.clear();
  }
}
