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
      appBar: AppBar(
        title: Obx(() => Text(controller.screenTitle)),
        actions: [
          Obx(() => DropdownButton<String>(
            value: controller.selectedPeriod.value,
            onChanged: (value) {
              if (value != null) {
                controller.selectedPeriod.value = value;
                controller.fetchRankings(controller.selectedType.value);
              }
            },
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Daily')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
            ],
          )),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildFilterChip('Global', 'global'),
                const SizedBox(width: 8),
                _buildFilterChip('India', 'India'),
                const SizedBox(width: 8),
                _buildFilterChip('UAE', 'UAE'),
                const SizedBox(width: 8),
                _buildFilterChip('Saudi', 'Saudi Arabia'),
              ],
            ),
          )),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.rankings.isEmpty) {
                return const Center(
                  child: Text('No rankings available', style: TextStyle(color: Colors.grey)),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.refreshRankings(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.rankings.length,
                  itemBuilder: (context, index) {
                    final entry = controller.rankings[index];
                    final name = entry['userName'] ?? entry['name'] ?? entry['username'] ?? entry['familyName'] ?? entry['agencyName'] ?? entry['roomName'] ?? 'Unknown';
                    final score = entry[controller.scoreField] ?? entry['score'] ?? 0;
                    final avatar = entry['avatar'] ?? entry['logo'] ?? entry['icon'] ?? '';
                    final subtitle = _getSubtitle(entry);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: index < 3 ? const Color(0xFF2D2D44).withOpacity(0.9) : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRankColor(index),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          name.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        subtitle: subtitle != null ? Text(
                          subtitle.toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ) : null,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFF4E285)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$score',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.selectedCountry.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.selectedCountry.value = value;
          controller.fetchRankings(controller.selectedType.value);
        }
      },
      selectedColor: const Color(0xFFD4AF37),
      checkmarkColor: Colors.black,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF2D2D44);
    }
  }

  String? _getSubtitle(Map<String, dynamic> entry) {
    final type = controller.selectedType.value;
    switch (type) {
      case 'families':
        return 'Members: ${entry['memberCount'] ?? 'N/A'}';
      case 'agencies':
        return 'Hosts: ${entry['totalHosts'] ?? 'N/A'}';
      case 'rooms':
        return 'Viewers: ${entry['activeUsers'] ?? 'N/A'}';
      case 'pk-battles':
        return 'Wins: ${entry['wins'] ?? 'N/A'}';
      default:
        return entry['country'] != null ? '${entry['country']}' : null;
    }
  }
}