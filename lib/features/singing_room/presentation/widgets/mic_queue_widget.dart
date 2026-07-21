import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/singing_room_controller.dart';

class MicQueueWidget extends StatelessWidget {
  const MicQueueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SingingRoomController>();
    return Obx(() {
      if (ctrl.micQueue.isEmpty && ctrl.myQueuePosition.value <= 0) return const SizedBox.shrink();
      return Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Queue position badge
            if (ctrl.myQueuePosition.value > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic, color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'You are #${ctrl.myQueuePosition.value}',
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            if (ctrl.myQueuePosition.value > 0 && ctrl.micQueue.isNotEmpty) const SizedBox(width: 8),
            // Queue avatars
            ...ctrl.micQueue.asMap().entries.map((entry) {
              final i = entry.key;
              final user = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
                      child: user['avatar'] == null ? Text('${i + 1}', style: const TextStyle(color: Colors.white70, fontSize: 11)) : null,
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F0E17), width: 2),
                        ),
                        child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Leave queue button
            if (ctrl.myQueuePosition.value > 0)
              GestureDetector(
                onTap: () => ctrl.leaveQueue(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 14),
                ),
              ),
          ],
        ),
      );
    });
  }
}
