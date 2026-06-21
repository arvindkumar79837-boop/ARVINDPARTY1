// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/games/presentation/views/game_screen.dart
// ARVIND PARTY - GAMES SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/games_controller.dart';

class GameScreen extends GetView<GamesController> {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── RESULT / ERROR DISPLAY ─────────────────────────────
            Obx(() {
              final err = controller.errorMessage.value;
              if (err.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(err, style: const TextStyle(color: Colors.redAccent)),
                  ),
                );
              }
              final r = controller.lastReward.value;
              if (r != null) {
                final type = r['type'] as String? ?? '';
                final amount = r['amount'] as int? ?? 0;
                final bal = controller.balance.value;
                final coins = bal?['coins'] as int? ?? 0;
                final diamonds = bal?['diamonds'] as int? ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8906), Color(0xFFD4AF37)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('You Won!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          type == 'NOTHING' ? 'Try Again!' : '+$amount ${type == 'DIAMONDS' ? 'Diamonds' : 'Coins'}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (coins > 0 || diamonds > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Balance: $coins coins${diamonds > 0 ? ", $diamonds diamonds" : ""}',
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => controller.clearResult(),
                          child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // ─── GAME CARDS ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _GameCard(
                    icon: Icons.casino,
                    title: 'Lucky Wheel',
                    subtitle: '50 coins / spin',
                    color: const Color(0xFFFF8906),
                    isLoading: controller.isPlaying.value,
                    onTap: () => controller.playLuckyWheel(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GameCard(
                    icon: Icons.credit_card,
                    title: 'Scratch Card',
                    subtitle: '20 coins / card',
                    color: const Color(0xFFE91E63),
                    isLoading: controller.isPlaying.value,
                    onTap: () => controller.playScratchCard(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── LEADERBOARD ────────────────────────────────────────
            const Text(
              'Weekly Leaderboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.leaderboard.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: Text('No rankings yet. Start playing!', style: TextStyle(color: Colors.grey)),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.leaderboard.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = controller.leaderboard[index];
                  final name = entry['name'] as String? ?? 'Player ${index + 1}';
                  final avatar = entry['avatar'] as String?;
                  final won = entry['totalWon'] as int? ?? 0;
                  final rankColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
                  final rankColor = index < 3 ? rankColors[index] : Colors.grey;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: rankColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: rankColor),
                          ),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF2D2D44),
                          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                          child: avatar == null
                              ? Text(name[0], style: const TextStyle(color: Color(0xFFFF8906)))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name, style: const TextStyle(color: Colors.white)),
                        ),
                        Text(
                          '$won coins',
                          style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            if (isLoading)
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Play', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}