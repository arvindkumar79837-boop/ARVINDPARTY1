// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/media/presentation/views/sound_effects_panel.dart
// ARVIND PARTY - SOUND EFFECTS TRIGGER PANEL
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/media_player_controller.dart';
import '../../domain/entities/media_item.dart';

class SoundEffectsPanel extends StatelessWidget {
  const SoundEffectsPanel({super.key});

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
          'Sound Effects',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Volume Control
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
                      'SFX Volume',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          children: [
                            Icon(Icons.volume_down, color: Colors.white.withValues(alpha: 0.6), size: 20),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  activeTrackColor: Colors.purple,
                                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                                  thumbColor: Colors.purple,
                                ),
                                child: Slider(
                                  value: controller.soundEffectVolume.value,
                                  onChanged: controller.setSoundEffectVolume,
                                ),
                              ),
                            ),
                            Icon(Icons.volume_up, color: Colors.white.withValues(alpha: 0.6), size: 20),
                          ],
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Active Sound Effect
              Obx(() {
                final active = controller.activeSoundEffect.value;
                if (active == null) return const SizedBox();
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.withValues(alpha: 0.15), Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up, color: Colors.purple, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Now Playing',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            Text(
                              active.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.activeSoundEffect.value = null,
                        child: const Text('Stop', style: TextStyle(color: Colors.purple)),
                      ),
                    ],
                  ),
                );
              }),
              // Sound Effects Grid
              const Text(
                'Quick Sounds',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Obx(() => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: controller.soundEffects.length,
                    itemBuilder: (context, index) {
                      final sfx = controller.soundEffects[index];
                      return _buildSoundEffectCard(controller, sfx);
                    },
                  )),
              const SizedBox(height: 24),
              // Preset Categories
              const Text(
                'Room SFX Presets',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildPresetCard(
                icon: Icons.celebration,
                label: 'Party Starter',
                effects: 'Applause + Air Horn',
                color: Colors.orange,
                onTap: () {
                  controller.triggerSoundEffect('sfx_001');
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.triggerSoundEffect('sfx_003');
                  });
                },
              ),
              _buildPresetCard(
                icon: Icons.emoji_events,
                label: 'Winner Effect',
                effects: 'Drum Roll + Winning Sound',
                color: Colors.amber,
                onTap: () {
                  controller.triggerSoundEffect('sfx_004');
                  Future.delayed(const Duration(milliseconds: 800), () {
                    controller.triggerSoundEffect('sfx_005');
                  });
                },
              ),
              _buildPresetCard(
                icon: Icons.sentiment_very_satisfied,
                label: 'Funny Moment',
                effects: 'Laugh Track + Applause',
                color: Colors.green,
                onTap: () {
                  controller.triggerSoundEffect('sfx_002');
                  Future.delayed(const Duration(milliseconds: 400), () {
                    controller.triggerSoundEffect('sfx_001');
                  });
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundEffectCard(MediaPlayerController controller, MediaItem sfx) {
    return GestureDetector(
      onTap: () => controller.triggerSoundEffect(sfx.id),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A4E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.activeSoundEffect.value?.id == sfx.id
                ? Colors.purple
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: controller.activeSoundEffect.value?.id == sfx.id
                    ? Colors.purple.withValues(alpha: 0.3)
                    : Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.music_note,
                color: controller.activeSoundEffect.value?.id == sfx.id
                    ? Colors.purple
                    : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                sfx.title,
                style: TextStyle(
                  color: controller.activeSoundEffect.value?.id == sfx.id
                      ? Colors.purple
                      : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard({
    required IconData icon,
    required String label,
    required String effects,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(effects, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: Icon(Icons.play_circle_fill, color: color, size: 28),
        onTap: onTap,
      ),
    );
  }
}