// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/games/presentation/views/game_history_screen.dart
// ARVIND PARTY - GAME HISTORY LOGS
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Game History',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 20,
                itemBuilder: (context, index) {
                  final game = _getGameHistoryItem(index);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                game['color'] as Color,
                                (game['color'] as Color).withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            game['icon'] as IconData,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game['name'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                game['result'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: game['isWin'] as bool ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              game['reward'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: game['isWin'] as bool ? Colors.green : Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              game['time'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          _buildFilterChip(label: 'All Games', isSelected: true),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Lucky Wheel', isSelected: false),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Scratch Cards', isSelected: false),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Dice', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.orange.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.orange : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Map<String, dynamic> _getGameHistoryItem(int index) {
    final games = [
      {'name': 'Lucky Wheel', 'icon': Icons.casino_outlined, 'color': Colors.purple},
      {'name': 'Scratch Card', 'icon': Icons.card_giftcard_outlined, 'color': Colors.orange},
      {'name': 'Dice Roll', 'icon': Icons.casino_outlined, 'color': Colors.blue},
      {'name': 'Lucky Number', 'icon': Icons.confirmation_number_outlined, 'color': Colors.green},
    ];

    final game = games[index % games.length];
    final isWin = index % 3 != 2;
    final reward = isWin ? '+${(index % 5 + 1) * 15} 🪙' : '0 🪙';
    final result = isWin ? 'Won ${(index % 5 + 1) * 15} 🪙' : 'Better luck next time';

    return {
      ...game,
      'isWin': isWin,
      'reward': reward,
      'result': result,
      'time': _getTimeAgo(index),
    };
  }

  String _getTimeAgo(int index) {
    if (index < 3) return 'Just now';
    if (index < 10) return '${index * 5} min ago';
    if (index < 15) return '${(index - 10) * 2} hours ago';
    return '${index - 15} days ago';
  }
}