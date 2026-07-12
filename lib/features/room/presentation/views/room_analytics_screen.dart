// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/views/room_analytics_screen.dart
// ARVIND PARTY - ROOM ANALYTICS SCREEN (Live tracking)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RoomAnalyticsScreen extends StatelessWidget {
  const RoomAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoomController>();

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
          'Room Analytics',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLiveStatsCard(controller),
          const SizedBox(height: 24),
          _buildListenersStats(),
          const SizedBox(height: 24),
              _buildGiftsReceivedCard(controller),
              const SizedBox(height: 24),
              _buildEngagementStatsCard(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatsCard(RoomController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.15),
            Colors.green.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
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
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Live Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final members = controller.members.length;
            final seats = controller.seats.length;
            final duration = _calculateDuration();

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.people_outlined,
                  label: 'Listeners',
                  value: '$members',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.mic_outlined,
                  label: 'Active Seats',
                  value: '$seats',
                  color: Colors.purple,
                ),
                _buildStatItem(
                  icon: Icons.access_time_outlined,
                  label: 'Duration',
                  value: duration,
                  color: Colors.orange,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildListenersStats() {
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
                Icons.show_chart_outlined,
                color: Color(0xFF64B5F6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Listener Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBarStat(label: '10m ago', value: 15, max: 50, color: Colors.blue),
              _buildBarStat(label: '20m ago', value: 25, max: 50, color: Colors.green),
              _buildBarStat(label: '30m ago', value: 20, max: 50, color: Colors.orange),
              _buildBarStat(label: 'Now', value: 38, max: 50, color: Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarStat({
    required String label,
    required int value,
    required int max,
    required Color color,
  }) {
    final height = (value / max) * 120;
    return Column(
      children: [
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
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

  Widget _buildGiftsReceivedCard(RoomController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.15),
            Colors.pink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.pink.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                color: Colors.pink,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Gifts Received',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            const totalGifts = 156;
            const totalValue = 12500;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGiftStatItem(
                  icon: Icons.send_outlined,
                  label: 'Total Gifts',
                  value: '$totalGifts',
                  color: Colors.pink,
                ),
                _buildGiftStatItem(
                  icon: Icons.diamond_outlined,
                  label: 'Total Value',
                  value: '$totalValue',
                  color: Colors.blue,
                ),
                _buildGiftStatItem(
                  icon: Icons.person_outlined,
                  label: 'Top Gifter',
                  value: 'User123',
                  color: Colors.amber,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGiftStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEngagementStatsCard() {
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
                Icons.trending_up_outlined,
                color: Color(0xFF64B5F6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Engagement Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEngagementRow(
            label: 'Peak Listeners',
            value: '45',
            percentage: 0.9,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildEngagementRow(
            label: 'Average Stay Time',
            value: '12 min',
            percentage: 0.75,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildEngagementRow(
            label: 'Chat Messages',
            value: '234',
            percentage: 0.65,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildEngagementRow(
            label: 'New Followers',
            value: '18',
            percentage: 0.45,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementRow({
    required String label,
    required String value,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _calculateDuration() {
    final now = DateTime.now();
    final minutes = now.minute % 60;
    final seconds = now.second;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}