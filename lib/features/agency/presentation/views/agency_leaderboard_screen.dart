// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_leaderboard_screen.dart
// ARVIND PARTY - AGENCY LEADERBOARD (Top-performing agencies)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyLeaderboardScreen extends StatelessWidget {
  const AgencyLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

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
            'Agency Leaderboard',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildLeaderboardTab(controller, period: 'daily'),
              _buildLeaderboardTab(controller, period: 'weekly'),
              _buildLeaderboardTab(controller, period: 'monthly'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(AgencyController controller, {required String period}) {
    final agencies = List.generate(10, (index) {
      final score = 10000 - (index * 750);
      final members = 25 - index;
      final earnings = 50000 - (index * 3000);
      return {
        'rank': index + 1,
        'name': 'Agency ${String.fromCharCode(65 + index)}',
        'score': score,
        'members': members,
        'earnings': earnings,
        'trend': index < 3 ? 'up' : (index > 7 ? 'down' : 'same'),
      };
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopThreePodium(agencies: agencies.take(3).toList()),
          const SizedBox(height: 24),
          _buildFullRankingsList(agencies: agencies),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTopThreePodium({required List<Map<String, dynamic>> agencies}) {
    final second = agencies[1];
    final first = agencies[0];
    final third = agencies[2];

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
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Agencies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumCard(
                agency: second,
                rank: 2,
                color: Colors.grey,
                height: 140,
                showCrown: false,
              ),
              const SizedBox(width: 12),
              _buildPodiumCard(
                agency: first,
                rank: 1,
                color: Colors.amber,
                height: 170,
                showCrown: true,
              ),
              const SizedBox(width: 12),
              _buildPodiumCard(
                agency: third,
                rank: 3,
                color: Colors.brown,
                height: 120,
                showCrown: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard({
    required Map<String, dynamic> agency,
    required int rank,
    required Color color,
    required double height,
    required bool showCrown,
  }) {
    return Container(
      width: 100,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: rank == 1 ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showCrown)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: Colors.amber,
                size: 28,
              ),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            agency['name'],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${agency['score']}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${agency['members']} members',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullRankingsList({required List<Map<String, dynamic>> agencies}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Rankings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: agencies.length,
          itemBuilder: (context, index) {
            final agency = agencies[index];
            final isTopThree = index < 3;
            final rank = agency['rank'] as int;

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
                                agency['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isTopThree ? FontWeight.w600 : FontWeight.normal,
                                  color: isTopThree ? Colors.orange : Colors.white,
                                ),
                              ),
                            ),
                            if (isTopThree)
                              const Icon(
                                Icons.emoji_events_outlined,
                                size: 16,
                                color: Colors.amber,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.people_outlined,
                              size: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${agency['members']} members',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.trending_up_outlined,
                              size: 11,
                              color: agency['trend'] == 'up'
                                  ? Colors.green
                                  : agency['trend'] == 'down'
                                      ? Colors.red
                                      : Colors.white54,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${agency['score']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isTopThree ? Colors.orange : Colors.white,
                        ),
                      ),
                      Text(
                        '₹${agency['earnings']}',
                        style: TextStyle(
                          fontSize: 10,
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
      ],
    );
  }
}