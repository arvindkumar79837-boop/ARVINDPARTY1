import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/singing_room_controller.dart';

class SingingPerformerWidget extends StatelessWidget {
  const SingingPerformerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SingingRoomController>();
    return Obx(() {
      final hasPerformer = ctrl.performerId.value != null;
      final song = ctrl.currentSong.value;
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: hasPerformer
              ? LinearGradient(
                  colors: [const Color(0xFFFF6B9D).withOpacity(0.15), const Color(0xFF1A0033)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: hasPerformer ? null : Colors.white.withOpacity(0.05),
        ),
        child: hasPerformer
            ? Stack(
                children: [
                  // Animated background effect
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          center: Alignment.center,
                          colors: [
                            const Color(0xFFFF6B9D).withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Performer info
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar with glow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.3),
                            child: const Icon(Icons.mic, color: Colors.white, size: 36),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Song info
                        if (song != null) ...[
                          Text(
                            song['title'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song['artist'] ?? '',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          ),
                        ] else ...[
                          const Text('🎤 On Stage', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                        const SizedBox(height: 8),
                        // Like counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${ctrl.likeCount.value}',
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Host controls
                  if (ctrl.isHost.value || ctrl.isCoHost.value)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _controlButton(
                            icon: Icons.skip_next,
                            onTap: () => ctrl.startPerformance(),
                            tooltip: 'Next',
                          ),
                          const SizedBox(width: 8),
                          _controlButton(
                            icon: Icons.stop_circle,
                            onTap: () => ctrl.endPerformance(),
                            tooltip: 'End',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_off, color: Colors.white.withOpacity(0.3), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No one is performing',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Queue up to be the next singer!',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  Widget _controlButton({required IconData icon, required VoidCallback onTap, String? tooltip, Color color = Colors.white}) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
