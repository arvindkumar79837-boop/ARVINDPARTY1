// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/games/presentation/views/game_leaderboard_screen.dart
// ARVIND PARTY - GAME LEADERBOARD & STATS
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/games_controller.dart';

class GameLeaderboardScreen extends StatelessWidget {
  const GameLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GamesController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Game Leaderboard',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
              Tab(text: 'All Time'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildLeaderboardTab(controller, period: 'weekly'),
              _buildLeaderboardTab(controller, period: 'monthly'),
              _buildLeaderboardTab(controller, period: 'all_time'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(GamesController controller, {required String period}) {
    final leaderboard = controller.leaderboard;

    return Obx(() {
      if (leaderboard.isEmpty && controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        );
      }

      // Convert GameLeaderboardEntry objects to Map for display
      final players = leaderboard.isEmpty
          ? List.generate(10, (index) {
              final score = 10000 - (index * 750);
              return {
                'rank': index + 1,
                'name': 'Player ${String.fromCharCode(65 + index)}',
                'score': score,
                'wins': 50 - index * 3,
                'gamesPlayed': 100 - index * 5,
                'avatar': null,
              };
            })
          : leaderboard.map((entry) => {
                'rank': leaderboard.indexOf(entry) + 1,
                'name': entry.name.isNotEmpty ? entry.name : 'Player ${leaderboard.indexOf(entry) + 1}',
                'score': entry.totalWon,
                'wins': entry.sessionsPlayed,
                'gamesPlayed': entry.sessionsPlayed,
                'avatar': entry.avatar.isNotEmpty ? entry.avatar : null,
              }).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopThreePodium(players: players.take(3).toList()),
            const SizedBox(height: 24),
            _buildFullRankingsList(players: players),
            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }

  Widget _buildTopThreePodium({required List<Map<String, dynamic>> players}) {
    final second = players[1];
    final first = players[0];
    final third = players[2];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.deepOrange.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Players',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumCard(player: second, rank: 2, color: Colors.grey, height: 140),
              const SizedBox(width: 12),
              _buildPodiumCard(player: first, rank: 1, color: Colors.amber, height: 170, showCrown: true),
              const SizedBox(width: 12),
              _buildPodiumCard(player: third, rank: 3, color: Colors.brown, height: 120),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard({
    required Map<String, dynamic> player,
    required int rank,
    required Color color,
    required double height,
    bool showCrown = false,
  }) {
    return Container(
      width: 100,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: rank == 1 ? 2 : 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showCrown)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 28),
            ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            player['name'],
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${player['score']}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            '${player['wins']} wins',
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildFullRankingsList({required List<Map<String, dynamic>> players}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Rankings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            final isTopThree = index < 3;
            final rank = player['rank'] as int;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isTopThree ? Colors.orange.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTopThree ? Colors.orange.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isTopThree ? Colors.orange : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isTopThree ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                player['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isTopThree ? FontWeight.w600 : FontWeight.normal,
                                  color: isTopThree ? Colors.orange : Colors.white,
                                ),
                              ),
                            ),
                            if (isTopThree)
                              const Icon(Icons.emoji_events_outlined, size: 16, color: Colors.amber),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${player['wins']} wins • ${player['gamesPlayed']} games',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${player['score']} pts',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isTopThree ? Colors.orange : Colors.white,
                        ),
                      ),
                      Text(
                        '${((player['wins'] / player['gamesPlayed']) * 100).toInt()}% win rate',
                        style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}