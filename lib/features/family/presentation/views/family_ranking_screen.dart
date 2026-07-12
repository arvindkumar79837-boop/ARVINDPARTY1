// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_ranking_screen.dart
// ARVIND PARTY - FAMILY RANKING SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilyRankingScreen extends GetView<FamilyController> {
  const FamilyRankingScreen({super.key});

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
          'Family Rankings',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Period Selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF252542),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  _buildPeriodTab('Daily', 'daily'),
                  _buildPeriodTab('Weekly', 'weekly'),
                  _buildPeriodTab('Monthly', 'monthly'),
                ],
              ),
            ),

            // Rankings List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.familyRanking.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
                }

                if (controller.familyRanking.isEmpty) {
                  return const Center(
                    child: Text('No rankings available', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.familyRanking.length,
                  itemBuilder: (context, index) {
                    final family = controller.familyRanking[index];
                    return _buildRankingTile(family, index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label, String period) {
    final isSelected = controller.selectedPeriod.value == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePeriod(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF8906), Color(0xFFF6F7F8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingTile(Map<String, dynamic> family, int index) {
    final rank = family['rank'] ?? index + 1;
    final familyName = family['familyName'] ?? 'Unknown';
    final familyBadge = family['familyBadge'] ?? 'TA';
    final level = family['level'] ?? 1;
    final memberCount = family['memberCount'] ?? 0;
    final totalXP = family['totalXP'] ?? 0;

    Color rankColor;
    IconData? rankIcon;
    if (rank == 1) {
      rankColor = Colors.yellow;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.orange;
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = Colors.white;
      rankIcon = null;
    }

    final bool isVip = rank <= 3;

    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        top: isVip ? 0 : 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVip
              ? [
                  rankColor.withValues(alpha: 0.2),
                  rankColor.withValues(alpha: 0.05),
                ]
              : [
                  const Color(0xFF252542),
                  const Color(0xFF1E1E3A),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVip ? rankColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
          width: isVip ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [rankColor.withValues(alpha: 0.8), rankColor.withValues(alpha: 0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isVip
                  ? [
                      BoxShadow(
                        color: rankColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: rankIcon != null
                  ? Icon(rankIcon, color: Colors.white, size: 20)
                  : Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Family Badge Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8906), Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                familyBadge.substring(0, familyBadge.length > 2 ? 2 : familyBadge.length).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Family Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        familyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: rankColor.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          'VIP',
                          style: TextStyle(
                            color: rankColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'Lv.$level',
                        style: const TextStyle(color: Colors.deepPurple, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people, color: Colors.grey.shade600, size: 14),
                    Text(
                      '$memberCount',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_upward, color: Colors.green.shade400, size: 14),
                    Text(
                      '$totalXP XP',
                      style: TextStyle(color: Colors.green.shade400, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}