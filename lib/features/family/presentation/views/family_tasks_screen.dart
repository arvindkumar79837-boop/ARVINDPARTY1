// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_tasks_screen.dart
// ARVIND PARTY - FAMILY TASKS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilyTasksScreen extends GetView<FamilyController> {
  const FamilyTasksScreen({super.key});

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
          'Family Tasks',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.familyTasks.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchFamilyTasks(),
            color: const Color(0xFFFF8906),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTasksList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.3),
            Colors.teal.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.task_alt, color: Colors.green.shade300, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Daily Family Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Complete tasks together to earn rewards for the entire family!',
            style: TextStyle(color: Colors.green.shade100, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Challenges",
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        if (controller.familyTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No tasks available right now. Check back later!',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.familyTasks.length,
            itemBuilder: (context, index) {
              final task = controller.familyTasks[index];
              return _buildTaskCard(task);
            },
          ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final target = task['target'] ?? 0;
    final current = task['current'] ?? 0;
    final progressPercent = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final isCompleted = task['isCompleted'] ?? false;

    Color progressColor;
    if (progressPercent >= 1.0) {
      progressColor = Colors.green;
    } else if (progressPercent >= 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.blue;
    }

    String rewardIcon;
    Color rewardColor;
    switch (task['rewardType']) {
      case 'coins':
        rewardIcon = '🪙';
        rewardColor = Colors.amber;
        break;
      case 'xp':
        rewardIcon = '⚡';
        rewardColor = Colors.purple;
        break;
      case 'family_points':
        rewardIcon = '⭐';
        rewardColor = Colors.deepOrange;
        break;
      default:
        rewardIcon = '🎁';
        rewardColor = Colors.pink;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF252542),
            Color(0xFF1E1E3A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task['title'] ?? 'Task',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task['description'] ?? '',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [progressColor, progressColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current / $target ${task['unit'] ?? ''}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              Row(
                children: [
                  Text(rewardIcon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '+${task['rewardAmount'] ?? 0}',
                    style: TextStyle(color: rewardColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          // Claim Button
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: controller.isClaiming.value
                        ? null
                        : () => controller.claimTaskReward(task['taskId'] ?? ''),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.teal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: controller.isClaiming.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'CLAIM REWARD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}