import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart' as msg;

class RoomChatScreen extends GetView<ChatController> {
  final String roomId;
  final String roomName;
  const RoomChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());
    // controller.initChat removed - use loadMessages instead
    return Scaffold(
      appBar: AppBar(title: Text(roomName), actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {
        Get.bottomSheet(
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A3E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.search, color: Colors.white),
                  title: const Text('Search Messages', style: TextStyle(color: Colors.white)),
                  onTap: () { Get.back(); },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_off_outlined, color: Colors.orange),
                  title: const Text('Mute Notifications', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    Get.snackbar('Muted', 'Notifications muted for this chat',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange.withValues(alpha: 0.8),
                        colorText: Colors.white);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Clear Chat', style: TextStyle(color: Colors.red)),
                  onTap: () { Get.back(); },
                ),
              ],
            ),
          ),
        );
      })]),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        return Column(children: [
          Expanded(child: ListView.builder(reverse: true, itemCount: controller.messages.length, itemBuilder: (context, index) {
            final message = controller.messages[controller.messages.length - 1 - index];
            return msg.MessageBubble(message: message, isMe: message.senderId == 'currentUserId');
          })),
          const ChatInputBar(),
        ]);
      }),
    );
  }
}