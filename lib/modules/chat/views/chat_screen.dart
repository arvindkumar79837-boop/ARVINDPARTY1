import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const ChatScreen(
      {super.key, required this.targetUserId, required this.targetUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController controller;

  @override
  void initState() {
    super.initState();
    // Ensure the controller is registered globally beforehand, or put it here
    controller = Get.find<ChatController>();

    // Trigger history load when opening this screen
    controller.openChat(widget.targetUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: Text(widget.targetUserName,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingHistory.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8906)));
              }
              if (controller.messages.isEmpty) {
                return const Center(
                    child: Text("Say hi!",
                        style: TextStyle(color: Colors.white54)));
              }
              return ListView.builder(
                reverse: true, // Builds from bottom to top
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe = msg.senderId == controller.currentUserId;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFFFF8906)
                            : const Color(0xFF2A2940),
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isMe
                              ? const Radius.circular(0)
                              : const Radius.circular(16),
                          bottomLeft: isMe
                              ? const Radius.circular(16)
                              : const Radius.circular(0),
                        ),
                      ),
                      child: Text(msg.content,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ),
                  );
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF15141F),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageInputController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2940),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFFFF8906),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: controller.sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
