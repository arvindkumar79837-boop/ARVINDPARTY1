// ═══════════════════════════════════════════════════════════════════════════
// VIEW: LuckySpinView — Real-time Lucky Spin with dynamic rewards
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/lucky_draw_controller.dart';

class LuckySpinView extends GetView<LuckyDrawController> {
  const LuckySpinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucky Spin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
            tooltip: 'Refresh Prizes',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: controller.loadRewards, child: const Text('Retry')),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfigInfo(),
              const SizedBox(height: 24),
              _buildSpinButton(),
              const SizedBox(height: 24),
              _buildLastWin(),
              const SizedBox(height: 24),
              _buildPrizeList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildConfigInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Configuration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    'v${controller.configVersion.value}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Spin Cost: ${controller.currentSpinCost.value} coins',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  controller.currentJackpotEnabled.value ? Icons.star : Icons.star_border,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                Text(
                  'Jackpot: ${controller.currentJackpotEnabled.value ? "Enabled" : "Disabled"}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (controller.currentJackpotEnabled.value) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.savings, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Jackpot Pool: ${controller.currentJackpotPool.value} coins',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpinButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: controller.isSpinning.value ? null : controller.spin,
        icon: controller.isSpinning.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.casino, size: 32),
        label: Text(
          controller.isSpinning.value ? 'Spinning...' : 'SPIN NOW',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildLastWin() {
    return Obx(() {
      if (controller.prize.value == null) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Spin the wheel to win amazing prizes!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      final prize = controller.prize.value!;
      final isJackpot = prize['jackpot_hit'] == true;

      return Card(
        color: isJackpot ? Colors.yellow.withOpacity(0.2) : Colors.green.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                isJackpot ? Icons.emoji_events : Icons.card_giftcard,
                size: 64,
                color: isJackpot ? Colors.amber : Colors.green,
              ),
              const SizedBox(height: 12),
              Text(
                isJackpot ? '🎰 JACKPOT! 🎰' : 'Congratulations!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isJackpot ? Colors.amber : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                prize['prize_name'] ?? 'Unknown Prize',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              if (prize['prize_value'] != null && prize['prize_value'] > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Value: ${prize['prize_value']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPrizeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Rewards',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.rewards.isEmpty) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No rewards available', style: TextStyle(color: Colors.grey)),
            ));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.rewards.length,
            itemBuilder: (context, index) {
              final reward = controller.rewards[index];
              return _buildRewardCard(reward);
            },
          );
        }),
      ],
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final tier = reward['tier'] ?? 'common';
    final colors = {
      'common': Colors.grey,
      'uncommon': Colors.green,
      'rare': Colors.blue,
      'epic': Colors.purple,
      'legendary': Colors.orange,
      'mythic': Colors.red,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (colors[tier] ?? Colors.grey).withOpacity(0.2),
          child: Icon(
            _getPrizeIcon(reward['itemType']),
            color: colors[tier] ?? Colors.grey,
          ),
        ),
        title: Text(
          reward['itemName'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reward['itemValue'] != null && reward['itemValue'] > 0)
              Text('Value: ${reward['itemValue']}'),
            Text('Win Chance: ${reward['probability']?.toStringAsFixed(1) ?? '0'}%'),
          ],
        ),
        trailing: Chip(
          label: Text(
            tier.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          backgroundColor: (colors[tier] ?? Colors.grey).withOpacity(0.2),
        ),
      ),
    );
  }

  IconData _getPrizeIcon(String? itemType) {
    switch (itemType) {
      case 'coins':
        return Icons.monetization_on;
      case 'diamonds':
        return Icons.diamond;
      case 'xp':
        return Icons.trending_up;
      case 'frame':
        return Icons.photo;
      case 'badge':
        return Icons.verified;
      case 'mount':
        return Icons.directions_bike;
      case 'entry_effect':
        return Icons.auto_awesome;
      case 'avatar_decoration':
        return Icons.brush;
      case 'chat_bubble':
        return Icons.chat_bubble;
      case 'seat_frame':
        return Icons.event_seat;
      case 'vip_days':
        return Icons.card_membership;
      case 'rocket':
        return Icons.rocket_launch;
      case 'entry_car':
        return Icons.drive_eta;
      default:
        return Icons.card_giftcard;
    }
  }
}