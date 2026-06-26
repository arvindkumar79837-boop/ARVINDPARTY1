import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vip_system_controller.dart';
import '../models/vip_system_model.dart';

class VipMissionsView extends GetView<VipSystemController> {
  const VipMissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Missions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMissions(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.vipMissions.isEmpty) {
          controller.fetchMissions();
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.fetchMissions,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Active Missions', Icons.flag, Colors.blue),
                const SizedBox(height: 8),
                if (controller.activeMissions.isEmpty)
                  _buildEmptyState('All missions completed! Check back tomorrow.')
                else
                  ...controller.activeMissions.map((m) => _buildMissionCard(m)),
                const SizedBox(height: 24),
                _buildSectionHeader('Completed', Icons.check_circle, Colors.green),
                const SizedBox(height: 8),
                if (controller.completedMissions.isEmpty)
                  _buildEmptyState('Complete missions to claim rewards')
                else
                  ...controller.completedMissions.map((m) => _buildCompletedMissionCard(m)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 14), textAlign: TextAlign.center),
    );
  }

  Widget _buildMissionCard(VipMission mission) {
    final progress = mission.progressPercent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mission.missionColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: mission.missionColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(mission.missionIcon, color: mission.missionColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.missionName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(mission.timeRemainingText, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mission.missionColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${mission.rewardValue.toInt()} ${mission.rewardType == 'coins' ? '🪙' : '⭐'}',
                    style: TextStyle(color: mission.missionColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade800,
                valueColor: AlwaysStoppedAnimation<Color>(mission.missionColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${mission.currentProgress.toInt()} / ${mission.targetValue.toInt()}',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(color: mission.missionColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedMissionCard(VipMission mission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade900.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade400.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.missionName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Reward: ${mission.rewardValue.toInt()} ${mission.rewardType}', style: TextStyle(color: Colors.green.shade300, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => controller.claimReward(mission.missionId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Claim', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}