// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/ranking/presentation/views/game_leaderboard_screen.dart
// ARVIND PARTY - GAME LEADERBOARD SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ranking_controller.dart';

class GameLeaderboardScreen extends GetView<RankingController> {
  const GameLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.screenTitle))),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.rankings.isEmpty) {
          return const Center(
            child: Text('No rankings available', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.rankings.length,
          itemBuilder: (context, index) {
            final entry = controller.rankings[index];
            final name = entry['userName'] ?? entry['name'] ?? entry['username'] ?? 'Unknown';
            final score = entry[controller.scoreField] ?? entry['score'] ?? 0;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: index < 3 ? const Color(0xFFD4AF37) : const Color(0xFF2D2D44),
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text(name.toString(), style: const TextStyle(color: Colors.white)),
              trailing: Text(
                '$score',
                style: const TextStyle(color: Color(0xFFD4AF37)),
              ),
            );
          },
        );
      }),
    );
  }
}
