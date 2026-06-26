// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_screen.dart
// ARVIND PARTY - FAMILY HOME SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';
import 'create_family_screen.dart';
import 'join_family_screen.dart';
import 'family_members_screen.dart';
import 'family_tasks_screen.dart';
import 'family_chat_screen.dart';
import 'family_ranking_screen.dart';

class FamilyScreen extends GetView<FamilyController> {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.myFamily.value == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
          }

          if (controller.myFamily.value == null) {
            return _buildNoFamilyView(context);
          }

          return _buildFamilyHome(context);
        }),
      ),
    );
  }

  Widget _buildNoFamilyView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8906), Color(0xFFF6F7F8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.group_add, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 30),
          const Text(
            'Create Your Dynasty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Join forces with friends, compete in epic wars, and rule the leaderboard together!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 40),
          _buildActionButton(
            context,
            label: 'Create Family (-5000 Coins)',
            icon: Icons.add_circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8906), Color(0xFFF6F7F8)],
            ),
            onTap: () {
              Get.to(() => const CreateFamilyScreen());
            },
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context,
            label: 'Join Existing Family',
            icon: Icons.login,
            gradient: LinearGradient(
              colors: [Colors.blue.withValues(alpha: 0.8), Colors.purple.withValues(alpha: 0.8)],
            ),
            onTap: () {
              Get.to(() => const JoinFamilyScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyHome(BuildContext context) {
    final family = controller.myFamily.value!;
    final myRole = family['myRole'] ?? 'Member';
    final isLeader = myRole == 'Patriarch';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Family Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF8906).withValues(alpha: 0.3),
                  const Color(0xFFFF8906).withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF8906).withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8906), Colors.orangeAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          (family['family_badge'] ?? 'TA').substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            family['family_name'] ?? 'Unknown Family',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLeader
                                  ? Colors.purple.withValues(alpha: 0.3)
                                  : Colors.blue.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isLeader ? Colors.purple : Colors.blue,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              myRole.toUpperCase(),
                              style: TextStyle(
                                color: isLeader ? Colors.purple : Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip('Level', '${family['current_level'] ?? 1}', Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatChip('Members', '${(family['members_list'] ?? []).length}/${family['member_limit'] ?? 20}', Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatChip('XP', '${family['total_xp'] ?? 0}', Colors.purple),
                    ),
                  ],
                ),
                if (family['family_slogan'] != null && family['family_slogan'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"${family['family_slogan']}"',
                      style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Family Points Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF8906).withValues(alpha: 0.2),
                  Colors.deepPurple.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF8906).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: Colors.yellow.shade700, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${family['family_points'] ?? 0}',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Text(
                  'Family Points',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions Grid
          const Text(
            'Quick Actions',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildQuickAction(
                context,
                icon: Icons.people,
                label: 'Members',
                color: Colors.green,
                onTap: () {
                  Get.to(() => const FamilyMembersScreen());
                },
              ),
              _buildQuickAction(
                context,
                icon: Icons.task_alt,
                label: 'Tasks',
                color: Colors.blue,
                onTap: () {
                  Get.to(() => const FamilyTasksScreen());
                },
              ),
              _buildQuickAction(
                context,
                icon: Icons.chat_bubble,
                label: 'Family Chat',
                color: Colors.purple,
                onTap: () {
                  Get.to(() => const FamilyChatScreen());
                },
              ),
              _buildQuickAction(
                context,
                icon: Icons.leaderboard,
                label: 'Rankings',
                color: Colors.orange,
                onTap: () {
                  Get.to(() => const FamilyRankingScreen());
                },
              ),
              _buildQuickAction(
                context,
                icon: Icons.store,
                label: 'Family Shop',
                color: Colors.pink,
                onTap: () {
                  Get.snackbar('Coming Soon', 'Family Shop will be available soon!');
                },
              ),
              _buildQuickAction(
                context,
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.grey,
                onTap: () {
                  Get.snackbar('Coming Soon', 'Family Settings will be available soon!');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Unlocked Powers
          const Text(
            'Unlocked Powers',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if ((family['unlocked_powers'] ?? []).isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Level up to unlock special family powers!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (family['unlocked_powers'] as List<dynamic>? ?? [])
                  .map((power) => Chip(
                        label: Text(
                          power.toString().replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
                        side: const BorderSide(color: Colors.deepPurple, width: 1),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8906).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}