// ═══════════════════════════════════════════════════════════════════════════
// PRIVATE CHAT SCREEN - Redirects to presentation/views
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'chat_screen.dart';

class PrivateChatScreen extends StatelessWidget {
  final String roomId;
  final String roomName;

  const PrivateChatScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(ChatController());
    return const ChatScreen();
  }
}