// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/media/presentation/views/youtube_screen.dart
// ARVIND PARTY - YOUTUBE MEDIA SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/media_player_controller.dart';

class YoutubeScreen extends StatelessWidget {
  const YoutubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaPlayerController controller = Get.find<MediaPlayerController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'YouTube',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          Obx(() => controller.isYouTubeMode.value
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: controller.exitYouTubeMode,
                )
              : const SizedBox()),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // URL Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A4E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Play YouTube Audio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Paste YouTube URL here...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: const Color(0xFF1A1A2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.link, color: Colors.red.shade300),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFFFF9800)),
                          onPressed: () {
                            // URL would be captured via controller
                            Get.snackbar(
                              'YouTube',
                              'Stream loading...',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          controller.setYouTubeUrl(value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Stream audio from YouTube directly in your voice room',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Current Stream
              Obx(() {
                if (!controller.isYouTubeMode.value) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A4E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.play_circle_outline,
                            size: 64, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          'No stream playing',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Paste a YouTube URL above to start streaming',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.withValues(alpha: 0.15), Colors.red.withValues(alpha: 0.05)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YouTube Stream Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.youtubeTitle.value,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop, color: Colors.red),
                        onPressed: controller.exitYouTubeMode,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              // Quick Links (YouTube shortcuts)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Links',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickLink(
                icon: Icons.trending_up,
                label: 'Trending Music',
                color: Colors.red,
                onTap: () {
                  controller.setYouTubeUrl('https://youtube.com/trending-music');
                },
              ),
              _buildQuickLink(
                icon: Icons.music_note,
                label: 'Party Mix 2024',
                color: Colors.purple,
                onTap: () {
                  controller.setYouTubeUrl('https://youtube.com/party-mix');
                },
              ),
              _buildQuickLink(
                icon: Icons.headphones,
                label: 'Live DJ Sets',
                color: Colors.blue,
                onTap: () {
                  controller.setYouTubeUrl('https://youtube.com/live-dj');
                },
              ),
              _buildQuickLink(
                icon: Icons.celebration,
                label: 'Festival Beats',
                color: Colors.orange,
                onTap: () {
                  controller.setYouTubeUrl('https://youtube.com/festival-beats');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLink({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
        tileColor: const Color(0xFF2A2A4E),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.play_circle_outline, color: color, size: 24),
        onTap: onTap,
      ),
    );
  }
}