import 'package:arvind_party/features/room/presentation/controllers/live_room_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBox extends GetView<LiveRoomController> {
  const ChatBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: Obx(
        () => ListView.builder(
          itemCount: controller.chatMessages.length,
          reverse: true, // To show latest messages at the bottom
          itemBuilder: (context, index) {
            final message = controller.chatMessages[index];
            final isMe = message.senderId == controller.currentUserId;

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFFFF8906).withOpacity(0.8)
                      : Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.senderName,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
