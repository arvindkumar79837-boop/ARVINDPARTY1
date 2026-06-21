// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/controllers/chat_controller.dart
// ARVIND PARTY - CHAT CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_model.dart';

class ChatController extends GetxController {
  var isLoading = false.obs;
  var messages = <Map<String, dynamic>>[].obs;
  
  final textController = TextEditingController();
  var replyToMessage = Rxn<Map<String, dynamic>>();

  void sendMessage() {}
  void sendSticker(String stickerId) {}
  void clearReply() {}
  void toggleReaction(String messageId, String reaction) {}
  void setReply(MessageModel message) {}
  void deleteMessage(String messageId) {}
  void pinMessage(String messageId) {}

  String get messageText => textController.text;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}