// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/media/presentation/views/playlist_screen.dart
import 'package:arvind_party/features/media/presentation/views/media_player_screen.dart';
// ARVIND PARTY - PLAYLIST SELECTOR SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/media_item.dart';
import '../controllers/media_player_controller.dart';



class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

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
          'Playlist',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  Icons.search,
                  color: controller.searchQuery.value.isNotEmpty
                      ? const Color(0xFFFF9800)
                      : Colors.white70,
                ),
                onPressed: () {
                  controller.onSearchChanged(controller.searchQuery.value);
                },
              )),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search tracks or artists...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: const Color(0xFF2A2A4E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.4)),
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () => controller.onSearchChanged(''),
                        )
                      : const SizedBox()),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // Category Filters
            Obx(() => Container(
                  height: 44,
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(controller, 'All', 'all'),
                      _buildFilterChip(controller, 'Music', 'music'),
                      _buildFilterChip(controller, 'Ambient', 'ambient'),
                      _buildFilterChip(controller, 'Sound Effects', 'soundEffect'),
                    ],
                  ),
                )),
            // Now Playing Bar
            Obx(() {
              final current = controller.currentMedia.value;
              if (current == null) return const SizedBox();
              return GestureDetector(
                onTap: () => Get.to(() => const MediaPlayerScreen()),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0x33FF9800), Color(0x11FF9800)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.music_note, color: Color(0xFFFF9800), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              current.artist,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Obx(() => Icon(
                            controller.isPlaying.value
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: const Color(0xFFFF9800),
                            size: 32,
                          )),
                    ],
                  ),
                ),
              );
            }),
            // Track List
            Expanded(
              child: Obx(() {
                final displayList = controller.searchQuery.value.isNotEmpty ||
                        controller.categoryFilter.value != 'all'
                    ? controller.filteredPlaylist
                    : controller.playlist;
                if (displayList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_off, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'No tracks found'
                              : 'No tracks in playlist',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final track = displayList[index];
                    return _buildTrackItem(controller, track);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(MediaPlayerController controller, String label, String value) {
    return Obx(() {
      final isSelected = controller.categoryFilter.value == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => controller.setCategoryFilter(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF2A2A4E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF9800)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTrackItem(MediaPlayerController controller, MediaItem track) {
    final isPlaying = controller.currentMedia.value?.id == track.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isPlaying ? const Color(0xFFFF9800).withValues(alpha: 0.1) : const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(12),
        border: isPlaying
            ? Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isPlaying ? const Color(0xFFFF9800).withValues(alpha: 0.2) : const Color(0xFF3A3A5E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            track.category == 'music'
                ? Icons.music_note
                : track.category == 'ambient'
                    ? Icons.nature_people
                    : Icons.warning_amber_rounded,
            color: isPlaying ? const Color(0xFFFF9800) : Colors.white54,
            size: 22,
          ),
        ),
        title: Text(
          track.title,
          style: TextStyle(
            color: isPlaying ? const Color(0xFFFF9800) : Colors.white,
            fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              track.artist,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${track.playCount >= 1000 ? '${(track.playCount / 1000).toStringAsFixed(1)}K' : track.playCount} plays',
                style: const TextStyle(color: Color(0xFFFF9800), fontSize: 10),
              ),
            ),
          ],
        ),
        trailing: Obx(() => IconButton(
              icon: Icon(
                isPlaying && controller.isPlaying.value
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: isPlaying ? const Color(0xFFFF9800) : Colors.white54,
                size: 28,
              ),
              onPressed: () => controller.selectMedia(track),
            )),
      ),
    );
  }
}
