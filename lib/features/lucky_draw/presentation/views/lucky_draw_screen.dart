// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/lucky_draw/presentation/views/lucky_draw_screen.dart
// ARVIND PARTY - LUCKY DRAW SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/lucky_draw_controller.dart';

class LuckyDrawScreen extends GetView<LuckyDrawController> {
  const LuckyDrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lucky Draw')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prize Display
            Obx(() {
              final p = controller.prize.value;
              if (p != null) {
                final name = p['name'] as String? ?? '';
                final type = p['type'] as String? ?? 'coin';
                final value = p['value'] as int? ?? 0;
                final icon = type == 'diamond' ? Icons.diamond : Icons.monetization_on;
                return Column(
                  children: [
                    Icon(icon, size: 64, color: const Color(0xFFFF8906)),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    if (value > 0)
                      Text(
                        '+$value ${type == 'diamond' ? 'Diamonds' : 'Coins'}',
                        style: const TextStyle(fontSize: 18, color: Color(0xFFD4AF37)),
                      ),
                  ],
                );
              }
              return const Column(
                children: [
                  Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Spin to win!', style: TextStyle(fontSize: 24, color: Colors.white)),
                ],
              );
            }),

            const SizedBox(height: 16),

            // New Balance
            Obx(() {
              if (controller.newBalance.value > 0) {
                return Text(
                  'Balance: ${controller.newBalance.value} coins',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 40),

            // Spin Button
            Obx(() => ElevatedButton(
              onPressed: controller.isSpinning.value ? null : () => controller.spin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8906),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                controller.isSpinning.value ? 'Spinning...' : 'SPIN (50 coins)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )),

            const SizedBox(height: 24),

            // Rewards Preview
            Obx(() {
              if (controller.rewards.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Prizes:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.rewards.map((r) {
                        return Chip(
                          label: Text(
                            '${r['name'] ?? ''} (${((r['probability'] as num?) ?? 0) * 100}%)',
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                          backgroundColor: const Color(0xFF1A1A2E),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
