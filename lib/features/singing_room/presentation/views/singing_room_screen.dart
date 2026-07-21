import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/singing_room_controller.dart';
import '../widgets/lyrics_widget.dart';
import '../widgets/like_animation_widget.dart';
import '../widgets/mic_queue_widget.dart';
import '../widgets/singing_performer_widget.dart';
import '../widgets/singing_bottom_bar.dart';
import 'song_search_screen.dart';

class SingingRoomScreen extends StatelessWidget {
  const SingingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SingingRoomController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitDialog(ctrl);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0E17),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(ctrl),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        // Performer area
                        const SingingPerformerWidget(),
                        const SizedBox(height: 8),
                        // Lyrics
                        const LyricsWidget(),
                        const SizedBox(height: 8),
                        // Queue info
                        const MicQueueWidget(),
                        const Spacer(),
                        // Bottom bar
                        const SingingBottomBar(),
                      ],
                    ),
                    // Like animation overlay
                    const LikeAnimationOverlay(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SingingRoomController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showExitDialog(ctrl),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎤 Singing Room', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Obx(() => Text(
                  ctrl.currentSong.value?['title'] ?? 'No performance',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
          // Sing Next button
          Obx(() => ctrl.myQueuePosition.value > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: Text('#${ctrl.myQueuePosition.value}', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 13, fontWeight: FontWeight.w600)),
              )
            : IconButton(
                onPressed: () => Get.to(() => const SongSearchScreen()),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF1493)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 18),
                ),
              ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(SingingRoomController ctrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Leave Singing Room?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to leave?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () { ctrl.leaveQueue(); Get.back(); Get.back(); },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
