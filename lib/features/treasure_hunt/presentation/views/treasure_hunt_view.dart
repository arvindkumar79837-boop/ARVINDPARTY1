// ═══════════════════════════════════════════════════════════════════════════
// VIEW: TreasureHuntView — Real-time Treasure Hunt with dynamic rewards
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/treasure_hunt_controller.dart';

class TreasureHuntView extends GetView<TreasureHuntController> {
  final String roomId;
  
  const TreasureHuntView({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasure Hunt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadActiveTreasureHunt(roomId),
            tooltip: 'Refresh',
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
                ElevatedButton(
                  onPressed: () => controller.loadActiveTreasureHunt(roomId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.activeTreasureHunt.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No active treasure hunt in this room',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHuntInfo(),
              const SizedBox(height: 24),
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              _buildCollectButton(),
              const SizedBox(height: 24),
              _buildRewardsPreview(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHuntInfo() {
    final hunt = controller.activeTreasureHunt.value!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hunt['huntName'] ?? 'Treasure Hunt',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(controller.huntStatus.value),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.huntStatus.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hunt['description'] != null && hunt['description'].isNotEmpty)
              Text(
                hunt['description'],
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Keys Collected',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${controller.keysCollected.value} / ${controller.keysRequired.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: controller.keysCollected.value / controller.keysRequired.value,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                controller.keysCollected.value >= controller.keysRequired.value
                    ? Colors.green
                    : Colors.blue,
              ),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            Text(
              controller.keysCollected.value >= controller.keysRequired.value
                  ? '🎉 Ready to open treasure!'
                  : '${controller.keysRequired.value - controller.keysCollected.value} more keys needed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectButton() {
    final canCollect = !controller.hasKey.value && 
                       !controller.isTreasureFound.value &&
                       controller.keysCollected.value < controller.keysRequired.value;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canCollect && !controller.isCollectingKey.value
            ? controller.collectKey
            : null,
        icon: controller.isCollectingKey.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                controller.hasKey.value
                    ? Icons.check_circle
                    : Icons.vpn_key,
                size: 24,
              ),
        label: Text(
          controller.isCollectingKey.value
              ? 'Collecting...'
              : controller.hasKey.value
                  ? 'Key Collected'
                  : controller.isTreasureFound.value
                      ? 'Treasure Found!'
                      : 'Collect Key',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.hasKey.value || controller.isTreasureFound.value
              ? Colors.green
              : Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildRewardsPreview() {
    final hunt = controller.activeTreasureHunt.value!;
    final rewards = hunt['rewards'] ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Treasure Rewards',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((rewards['coins'] ?? 0) > 0)
                  _buildRewardRow(
                    Icons.monetization_on,
                    'Coins',
                    rewards['coins'].toString(),
                    Colors.amber,
                  ),
                if ((rewards['diamonds'] ?? 0) > 0)
                  _buildRewardRow(
                    Icons.diamond,
                    'Diamonds',
                    rewards['diamonds'].toString(),
                    Colors.blue,
                  ),
                if ((rewards['xp'] ?? 0) > 0)
                  _buildRewardRow(
                    Icons.trending_up,
                    'XP',
                    rewards['xp'].toString(),
                    Colors.purple,
                  ),
                if ((rewards['frames'] ?? []).isNotEmpty)
                  _buildRewardRow(
                    Icons.photo,
                    'Frames',
                    '${(rewards['frames'] as List).length} items',
                    Colors.orange,
                  ),
                if ((rewards['badges'] ?? []).isNotEmpty)
                  _buildRewardRow(
                    Icons.verified,
                    'Badges',
                    '${(rewards['badges'] as List).length} items',
                    Colors.green,
                  ),
                if ((rewards['cars'] ?? []).isNotEmpty)
                  _buildRewardRow(
                    Icons.drive_eta,
                    'Vehicles',
                    '${(rewards['cars'] as List).length} items',
                    Colors.red,
                  ),
                if ((rewards['specialEffects'] ?? []).isNotEmpty)
                  _buildRewardRow(
                    Icons.auto_awesome,
                    'Special Effects',
                    '${(rewards['specialEffects'] as List).length} items',
                    Colors.pink,
                  ),
                if (rewards.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Mystery rewards await...',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'FOUND':
        return Colors.amber;
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}