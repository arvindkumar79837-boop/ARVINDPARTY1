// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/controllers/chat_controller.dart
// ARVIND PARTY - CHAT CONTROLLER (Implementation)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/socket/socket_service.dart';
import '../../models/chat_model.dart';

class ChatController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final SocketService _socket = Get.find<SocketService>();

  var isLoading = false.obs;
  var messages = <MessageModel>[].obs;
  var chatList = <ChatModel>[].obs;
  var unreadCount = 0.obs;

  final textController = TextEditingController();
  var replyToMessage = Rxn<Map<String, dynamic>>();

  String currentChatId = '';
  String currentRecipientId = '';

  @override
  void onInit() {
    super.onInit();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket.onPrivateMessage((data) {
      if (data is Map) {
        final msg = MessageModel.fromJson(Map<String, dynamic>.from(data));
        if (msg.chatId == currentChatId) {
          messages.add(msg);
        }
      }
    });
  }

  Future<void> fetchMessages(String chatId) async {
    isLoading.value = true;
    currentChatId = chatId;
    try {
      final response = await _api.get('/chat/$chatId/messages');
      if (response is Map && response['success'] == true) {
        final list = response['data'] as List? ?? [];
        messages.assignAll(list.map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m))).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty || currentChatId.isEmpty) return;
    _socket.sendPrivateMessage(currentRecipientId, text);
    textController.clear();
  }

  void sendSticker(String stickerId) {
    if (currentChatId.isEmpty) return;
    _socket.sendPrivateMessage(currentRecipientId, stickerId);
  }

  void clearReply() {
    replyToMessage.value = null;
  }

  void toggleReaction(String messageId, String reaction) {
    _socket.emit('chat:reaction', {
      'messageId': messageId,
      'reaction': reaction,
    });
  }

  void setReply(MessageModel message) {
    replyToMessage.value = {
      'id': message.id,
      'text': message.text,
      'senderName': message.senderName,
    };
  }

  void deleteMessage(String messageId) {
    _socket.emit('chat:delete', {
      'chatId': currentChatId,
      'messageId': messageId,
    });
  }

  void pinMessage(String messageId) {
    _socket.emit('chat:pin', {
      'chatId': currentChatId,
      'messageId': messageId,
    });
  }

  Future<void> fetchChatList() async {
    try {
      final response = await _api.get('/chat/list');
      if (response is Map && response['success'] == true) {
        final list = response['data'] as List? ?? [];
        chatList.assignAll(list.map((c) => ChatModel.fromJson(Map<String, dynamic>.from(c))).toList());
        unreadCount.value = chatList.fold(0, (sum, chat) => sum + (chat.unreadCount ?? 0));
      }
    } catch (e) {
    }
  }

  void markAsRead(String chatId) {
    _socket.emit('chat:read', {'chatId': chatId});
  }

  String get messageText => textController.text;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
