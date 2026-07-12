// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/media/presentation/views/media_player_screen.dart
// ARVIND PARTY - MEDIA PLAYER SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/media_item.dart';
import '../controllers/media_player_controller.dart';

class MediaPlayerScreen extends StatelessWidget {
  const MediaPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaPlayerController>();

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
          'Now Playing',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
              controller.loopMode.value == PlayerLoopMode.off
                      ? Icons.repeat
                      : controller.loopMode.value == PlayerLoopMode.all
                          ? Icons.repeat
                          : Icons.repeat_one,
                  color: controller.loopMode.value != PlayerLoopMode.off
                      ? const Color(0xFFFF9800)
                      : Colors.white70,
                ),
                onPressed: controller.cycleLoopMode,
              )),
          Obx(() => IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: controller.isShuffled.value
                      ? const Color(0xFFFF9800)
                      : Colors.white70,
                ),
                onPressed: controller.toggleShuffle,
              )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9800)),
            );
          }
          if (controller.errorMessage.value != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadPlaylist,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final media = controller.currentMedia.value;
          if (media == null) {
            return const Center(
              child: Text(
                'No media selected',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Album Art
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B1FA2), Color(0xFF303F9F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B1FA2).withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _buildAlbumArt(media),
                  ),
                ),
                const SizedBox(height: 40),
                // Track Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        media.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        media.artist,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          media.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF9800),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: const Color(0xFFFF9800),
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                          thumbColor: const Color(0xFFFF9800),
                        ),
                        child: Slider(
                          value: controller.currentPosition.value.inSeconds
                              .toDouble(),
                          max: controller.totalDuration.value.inSeconds.toDouble() > 0
                              ? controller.totalDuration.value.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) =>
                              controller.seekTo(Duration(seconds: value.toInt())),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(controller.currentPosition.value),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              _formatDuration(controller.totalDuration.value),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Playback Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.skip_previous_rounded,
                        size: 40,
                        onTap: controller.previous,
                      ),
                      Obx(() => GestureDetector(
                            onTap: controller.togglePlayPause,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x33FF9800),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                controller.isPlaying.value
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          )),
                      _buildControlButton(
                        icon: Icons.skip_next_rounded,
                        size: 40,
                        onTap: controller.next,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Volume Control
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Icon(Icons.volume_down, color: Colors.white.withValues(alpha: 0.6)),
                      Expanded(
                        child: Obx(() => SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                                activeTrackColor: const Color(0xFFFF9800),
                                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                                thumbColor: const Color(0xFFFF9800),
                              ),
                              child: Slider(
                                value: controller.volume.value,
                                onChanged: controller.setVolume,
                              ),
                            )),
                      ),
                      Icon(Icons.volume_up, color: Colors.white.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Playlist Queue
                _buildPlaylistQueue(controller),
                const SizedBox(height: 80),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAlbumArt(MediaItem media) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade800,
            Colors.deepPurple.shade900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          media.category == 'music'
              ? Icons.music_note
              : media.category == 'ambient'
                  ? Icons.nature_people
                  : Icons.warning_amber_rounded,
          size: 100,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: size),
      onPressed: onTap,
    );
  }

  Widget _buildPlaylistQueue(MediaPlayerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Up Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${controller.playlist.length} tracks',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                ),
              ],
            ),
          ),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.playlist.length,
                itemBuilder: (context, index) {
                  final track = controller.playlist[index];
                  final isCurrent = controller.currentMedia.value?.id == track.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFFF9800).withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent
                          ? Border.all(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.3))
                          : null,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A4E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.music_note,
                            color: isCurrent
                                ? const Color(0xFFFF9800)
                                : Colors.white54,
                            size: 20,
                          ),
                        ),
                      ),
                      title: Text(
                        track.title,
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFFFF9800) : Colors.white,
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track.artist,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                      ),
                      trailing: Text(
                        _formatDuration(track.duration),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => controller.selectMedia(track),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}