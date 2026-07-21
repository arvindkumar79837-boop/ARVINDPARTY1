import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/singing_room_controller.dart';

class LyricsWidget extends StatelessWidget {
  const LyricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SingingRoomController>();
    return Obx(() {
      if (ctrl.currentSong.value == null) return const SizedBox.shrink();
      if (ctrl.lyricsLines.isEmpty) {
        return Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Text(
              '🎶 Enjoy the performance',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        );
      }
      return Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: ctrl.lyricsLines.length,
          itemBuilder: (ctx, i) {
            final line = ctrl.lyricsLines[i];
            final text = line['text'] ?? '';
            final isCurrent = i == ctrl.currentLyricIndex.value;
            final isPast = i < ctrl.currentLyricIndex.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isCurrent
                      ? const Color(0xFFFF6B9D)
                      : isPast
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.6),
                  fontSize: isCurrent ? 18 : 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
