import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyRankingScreen extends StatelessWidget {
  const AgencyRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Agency Ranking', style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              Get.snackbar('Refreshing', 'Ranking data updated',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange.withValues(alpha: 0.8),
                  colorText: Colors.white);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopThreePodium(),
              const SizedBox(height: 24),
              _buildPeriodSelector(),
              const SizedBox(height: 16),
              _buildRankingList(),
              const SizedBox(height: 24),
              _buildYourRankCard(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopThreePodium() {
    final topThree = [
      {'rank': 1, 'name': 'Star Agency', 'score': '₹1,85,000', 'members': 42, 'color': Colors.amber, 'icon': Icons.emoji_events},
      {'rank': 2, 'name': 'Apex Network', 'score': '₹1,42,000', 'members': 35, 'color': Colors.grey, 'icon': Icons.emoji_events_outlined},
      {'rank': 3, 'name': 'Royal Hub', 'score': '₹1,18,000', 'members': 28, 'color': Colors.orange, 'icon': Icons.emoji_events_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.12),
            Colors.deepOrange.withValues(alpha: 0.06),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildPodiumItem(topThree[1], height: 90),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPodiumItem(topThree[0], height: 120),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPodiumItem(topThree[2], height: 70),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> item, {required double height}) {
    final color = item['color'] as Color;
    final rank = item['rank'] as int;

    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(item['icon'] as IconData, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          item['name'] as String,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          item['score'] as String,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.08),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Weekly', 'Monthly', 'All Time'];
    final selected = 'Monthly'.obs;

    return Obx(() => Row(
          children: periods.map((period) {
            final isSelected = selected.value == period;
            return Expanded(
              child: GestureDetector(
                onTap: () => selected.value = period,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.orange.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.orange : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildRankingList() {
    final rankings = [
      {'rank': 4, 'name': 'Elite Squad', 'score': '₹95,000', 'members': 22, 'change': '+2', 'color': Colors.teal},
      {'rank': 5, 'name': 'Power House', 'score': '₹82,500', 'members': 18, 'change': '-1', 'color': Colors.blue},
      {'rank': 6, 'name': 'Rising Stars', 'score': '₹71,000', 'members': 15, 'change': '+3', 'color': Colors.purple},
      {'rank': 7, 'name': 'Golden Circle', 'score': '₹65,200', 'members': 20, 'change': '0', 'color': Colors.pink},
      {'rank': 8, 'name': 'Impact Agency', 'score': '₹54,800', 'members': 12, 'change': '-2', 'color': Colors.cyan},
      {'rank': 9, 'name': 'Next Gen', 'score': '₹48,000', 'members': 10, 'change': '+1', 'color': Colors.lime},
      {'rank': 10, 'name': 'Fresh Start', 'score': '₹35,000', 'members': 8, 'change': '0', 'color': Colors.brown},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rankings.length,
          itemBuilder: (context, index) {
            final r = rankings[index];
            final color = r['color'] as Color;
            final change = r['change'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      '#${r['rank']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Text(
                      (r['name'] as String)[0],
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('${r['members']} members', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Text(r['score'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: change.startsWith('+')
                          ? Colors.green.withValues(alpha: 0.15)
                          : change == '0'
                              ? Colors.grey.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      change == '0' ? '--' : change,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: change.startsWith('+')
                            ? Colors.green
                            : change == '0'
                                ? Colors.grey
                                : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildYourRankCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.deepOrange.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('#15', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Agency Rank', style: TextStyle(fontSize: 12, color: Colors.white70)),
                SizedBox(height: 4),
                Text('#15 of 128 Agencies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('Top 12% — Keep pushing!', style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
