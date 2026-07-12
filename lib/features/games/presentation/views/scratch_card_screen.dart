// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/games/presentation/views/scratch_card_screen.dart
// ARVIND PARTY - SCRATCH CARD GAME
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/games_controller.dart';

class ScratchCardScreen extends StatelessWidget {
  const ScratchCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GamesController>();

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
          'Scratch Cards',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(controller),
              const SizedBox(height: 24),
              _buildScratchCardGame(controller),
              const SizedBox(height: 24),
              _buildRewardsInfo(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(GamesController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.2),
            Colors.deepPurple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Balance',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Obx(() => Text(
                      '${controller.balance.value?['coins'] ?? 1250} 🪙',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.balance.value?['points'] ?? 350} pts',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScratchCardGame(GamesController controller) {
    final currentCard = 0.obs;
    final isRevealed = false.obs;
    final rewardAmount = 0.obs;
    final isPlaying = false.obs;

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
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                color: Colors.orange,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Scratch to Win',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final revealed = isRevealed.value;

            return Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: revealed
                      ? [Colors.green.withValues(alpha: 0.2), Colors.teal.withValues(alpha: 0.1)]
                      : [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: revealed
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: revealed
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'YOU WON!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${rewardAmount.value} 🪙',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 60,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to Scratch!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (!revealed)
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isPlaying.value
                              ? null
                              : () async {
                                  isPlaying.value = true;
                                  final random = DateTime.now().millisecond % 100;
                                  final won = random > 30;
                                  final amount = won ? (random % 5 + 1) * 10 : 0;

                                  await Future.delayed(const Duration(milliseconds: 500));

                                  if (won) {
                                    rewardAmount.value = amount;
                                  }
                                  isRevealed.value = true;
                                  isPlaying.value = false;
                                },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cost: 20 🪙 per scratch',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              TextButton.icon(
                onPressed: isPlaying.value
                    ? null
                    : () {
                        currentCard.value = (currentCard.value + 1) % 3;
                        isRevealed.value = false;
                        rewardAmount.value = 0;
                      },
                icon: const Icon(
                  Icons.refresh,
                  size: 14,
                  color: Colors.orange,
                ),
                label: Text(
                  'New Card (${3 - currentCard.value} left)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsInfo() {
    final prizes = [
      {'amount': 100, 'probability': '5%', 'color': Colors.green, 'icon': Icons.star},
      {'amount': 50, 'probability': '15%', 'color': Colors.blue, 'icon': Icons.card_giftcard},
      {'amount': 20, 'probability': '30%', 'color': Colors.orange, 'icon': Icons.monetization_on},
      {'amount': 10, 'probability': '25%', 'color': Colors.purple, 'icon': Icons.confirmation_number},
      {'amount': 0, 'probability': '25%', 'color': Colors.red, 'icon': Icons.close},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prize Distribution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prizes.length,
          itemBuilder: (context, index) {
            final prize = prizes[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (prize['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      prize['icon'] as IconData,
                      color: prize['color'] as Color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${prize['amount']} 🪙',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: prize['color'] as Color,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      prize['probability'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
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