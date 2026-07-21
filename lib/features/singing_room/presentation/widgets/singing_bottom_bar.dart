import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/singing_room_controller.dart';
import '../views/song_search_screen.dart';
import '../../../gift/presentation/widgets/gift_picker_dialog.dart';

class SingingBottomBar extends StatelessWidget {
  const SingingBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SingingRoomController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Sing Next button
          _bottomButton(
            icon: ctrl.myQueuePosition.value > 0 ? Icons.queue : Icons.mic,
            label: ctrl.myQueuePosition.value > 0 ? '#${ctrl.myQueuePosition.value}' : 'Sing Next',
            color: ctrl.myQueuePosition.value > 0 ? const Color(0xFFFFD700) : const Color(0xFFFF6B9D),
            onTap: ctrl.myQueuePosition.value > 0 ? null : () => Get.to(() => const SongSearchScreen()),
          ),
          // Like button
          _bottomButton(
            icon: Icons.favorite,
            label: '${ctrl.likeCount.value}',
            color: Colors.red,
            onTap: () => ctrl.sendLike(),
          ),
          // Gift button
          _bottomButton(
            icon: Icons.card_giftcard,
            label: 'Gift',
            color: const Color(0xFFFFD700),
            onTap: () => _openGiftPicker(),
          ),
          // Queue view
          _bottomButton(
            icon: Icons.people_outline,
            label: '${ctrl.micQueue.length}',
            color: Colors.white70,
            onTap: () => _showQueueDialog(ctrl),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(onTap != null ? 0.15 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color.withOpacity(onTap != null ? 1.0 : 0.4), size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color.withOpacity(onTap != null ? 0.9 : 0.4), fontSize: 11)),
        ],
      ),
    );
  }

  void _openGiftPicker() {
    // Reuse existing gift picker — gift goes to current performer in room
    Get.find<GiftController>().openGiftPicker(targetType: 'PERFORMER');
  }

  void _showQueueDialog(SingingRoomController ctrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Sing Next Queue', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (ctrl.micQueue.isEmpty) {
              return const Center(child: Text('Queue is empty', style: TextStyle(color: Colors.white54)));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: ctrl.micQueue.length,
              itemBuilder: (_, i) {
                final user = ctrl.micQueue[i];
                final song = user['song'];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
                    child: user['avatar'] == null ? Text('${i + 1}', style: const TextStyle(color: Colors.white70)) : null,
                  ),
                  title: Text(user['name'] ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  subtitle: song != null ? Text(song['title'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)) : null,
                  trailing: (ctrl.isHost.value || ctrl.isCoHost.value)
                      ? IconButton(
                          onPressed: () => ctrl.removeUserFromQueue(user['userId'] ?? user['_id']),
                          icon: const Icon(Icons.close, color: Colors.red, size: 16),
                        )
                      : null,
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close', style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }
}
