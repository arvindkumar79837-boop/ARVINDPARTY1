// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_wars_screen.dart
// ARVIND PARTY - FAMILY WARS SCREEN (Real-time battles)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilyWarsScreen extends StatelessWidget {
  const FamilyWarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FamilyController>();

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
          'Family Wars',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActiveBattleCard(controller),
              const SizedBox(height: 24),
              _buildCountdownTimer(),
              const SizedBox(height: 24),
              _buildLiveScorecard(controller),
              const SizedBox(height: 24),
              _buildBattleHistorySection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBattleCard(FamilyController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ACTIVE BATTLE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFamilyTeam(
                  name: 'Alpha Family',
                  score: 2450,
                  color: Colors.blue,
                  isLeading: true,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFamilyTeam(
                  name: 'Beta Family',
                  score: 2100,
                  color: Colors.purple,
                  isLeading: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBattleStat(label: 'Battle Type', value: '3v3 Ranked'),
                _buildBattleStat(label: 'Round', value: 'Round 2/3'),
                _buildBattleStat(label: 'Prize', value: '5000 🪙'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyTeam({
    required String name,
    required int score,
    required Color color,
    required bool isLeading,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLeading ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLeading ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isLeading ? color : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final displayScore = score;
            return Text(
              '$displayScore',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isLeading ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
            );
          }),
          const SizedBox(height: 2),
          Text(
            isLeading ? 'LEADING' : 'TRAILING',
            style: TextStyle(
              fontSize: 10,
              color: isLeading ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer() {
    final timeRemaining = const Duration(minutes: 5, seconds: 30).obs;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: Colors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Battle Timer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final minutes = timeRemaining.value.inMinutes;
            final seconds = timeRemaining.value.inSeconds % 60;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeUnit(value: minutes.toString().padLeft(2, '0'), label: 'MIN'),
                const SizedBox(width: 12),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                _buildTimeUnit(value: seconds.toString().padLeft(2, '0'), label: 'SEC'),
              ],
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Score updates in real-time. Victory goes to the family with the highest score when time ends.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.3),
            Colors.deepOrange.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveScorecard(FamilyController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart_outlined,
                color: Color(0xFF64B5F6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Live Scoreboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              final isCurrentFamily = index == 0;
              final score = 2450 - (index * 150);
              final memberCount = 8 - index;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentFamily
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrentFamily
                        ? Colors.blue.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCurrentFamily
                            ? Colors.blue
                            : Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCurrentFamily ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCurrentFamily ? 'Your Family' : 'Family ${String.fromCharCode(65 + index)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrentFamily ? FontWeight.w600 : FontWeight.normal,
                              color: isCurrentFamily ? Colors.blue : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$memberCount members',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBattleHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Battles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.refresh,
                size: 14,
                color: Colors.red.withValues(alpha: 0.8),
              ),
              label: Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final isWin = index == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isWin
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isWin ? Icons.emoji_events_outlined : Icons.close_outlined,
                      color: isWin ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWin ? 'Victory' : 'Defeat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isWin ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'vs Family ${String.fromCharCode(66 + index)} • 2 days ago',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isWin
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isWin ? '+500 🪙' : '-200 🪙',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isWin ? Colors.green : Colors.red,
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
}