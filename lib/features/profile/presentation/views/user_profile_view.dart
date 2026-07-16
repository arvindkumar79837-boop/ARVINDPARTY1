import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Obx(() {
        if (controller.isLoading.value && controller.userProfile.value == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        final user = controller.userProfile.value;
        final name = user?.name ?? 'User';
        final uid = user?.uid ?? 'N/A';
        final avatar = user?.avatar ?? '';

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFF1A1A2E),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.15),
                        Colors.orange.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.amber.withValues(alpha: 0.2),
                          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                          child: avatar.isEmpty
                              ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber))
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('UID: $uid', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildLevelSection(),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(),
                    const SizedBox(height: 24),
                    _buildActivitySection(),
                    const SizedBox(height: 24),
                    _buildActionsSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _buildStatItem('Following', '128', Colors.blue),
          _buildDivider(),
          _buildStatItem('Followers', '2,340', Colors.pink),
          _buildDivider(),
          _buildStatItem('Posts', '86', Colors.green),
          _buildDivider(),
          _buildStatItem('Gifts', '1.2K', Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.08));
  }

  Widget _buildLevelSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.12),
            Colors.orange.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              const Text('VIP Level 5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Gold', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.68,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '4,560 / 6,700 XP to Level 6',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
      {'title': 'First Gift', 'icon': Icons.card_giftcard, 'color': Colors.pink, 'unlocked': true},
      {'title': 'Social Star', 'icon': Icons.star, 'color': Colors.amber, 'unlocked': true},
      {'title': 'Live Legend', 'icon': Icons.live_tv, 'color': Colors.red, 'unlocked': true},
      {'title': 'Family Hero', 'icon': Icons.family_restroom, 'color': Colors.blue, 'unlocked': false},
      {'title': 'Top Gifter', 'icon': Icons.redeem, 'color': Colors.purple, 'unlocked': false},
      {'title': 'Night Owl', 'icon': Icons.nightlight_round, 'color': Colors.indigo, 'unlocked': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final a = achievements[index];
              final color = a['color'] as Color;
              final unlocked = a['unlocked'] as bool;
              return Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: unlocked ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: unlocked ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: unlocked ? color : Colors.white24,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a['title'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    final activities = [
      {'text': 'Sent a gift to Priya', 'time': '2 hours ago', 'icon': Icons.card_giftcard_outlined, 'color': Colors.pink},
      {'text': 'Completed daily mission', 'time': '5 hours ago', 'icon': Icons.task_alt, 'color': Colors.green},
      {'text': 'Joined Family Game Night', 'time': 'Yesterday', 'icon': Icons.videogame_asset_outlined, 'color': Colors.blue},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        ...activities.map((a) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(a['icon'] as IconData, color: a['color'] as Color, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(a['text'] as String, style: const TextStyle(fontSize: 13, color: Colors.white)),
                  ),
                  Text(a['time'] as String, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActionsSection() {
    final actions = [
      {'title': 'Edit Profile', 'icon': Icons.edit_outlined, 'color': Colors.blue},
      {'title': 'QR Code', 'icon': Icons.qr_code, 'color': Colors.teal},
      {'title': 'Share Profile', 'icon': Icons.share_outlined, 'color': Colors.green},
    ];

    return Row(
      children: actions.map((a) {
        final color = a['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(a['icon'] as IconData, color: color, size: 24),
                const SizedBox(height: 6),
                Text(a['title'] as String, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
