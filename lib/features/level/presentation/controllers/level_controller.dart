// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/level/presentation/controllers/level_controller.dart
// ARVIND PARTY - LEVEL & XP CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/level_repository.dart';

class LevelController extends GetxController {
  final LevelRepository _repo = LevelRepository();
  
  final currentLevel = 1.obs;
  final currentXp = 0.obs;
  final xpToNextLevel = 1000.obs;
  final totalXpEarned = 0.obs;
  final isLoading = false.obs;

  // Level milestones
  final milestones = <LevelMilestone>[].obs;
  final unlockedMilestones = <LevelMilestone>[].obs;

  // XP breakdown
  final xpToday = 0.obs;
  final xpThisWeek = 0.obs;
  final xpBreakdown = <XpSource>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLevelData();
  }

  Future<void> loadLevelData() async {
    isLoading.value = true;
    try {
      final data = await _repo.getLevelData();
      
      if (data['success'] == true) {
        final levelData = data['data'] as Map<String, dynamic>;
        currentLevel.value = levelData['currentLevel'] ?? 1;
        currentXp.value = levelData['currentXp'] ?? 0;
        xpToNextLevel.value = levelData['xpToNextLevel'] ?? 1000;
        totalXpEarned.value = levelData['totalXpEarned'] ?? 0;
      }

      final xpData = await _repo.getXpBreakdown();
      xpBreakdown.value = xpData.map((e) => XpSource(
        e['label'] ?? '',
        e['xp'] ?? 0,
        Icons.star,
      )).toList();

      xpToday.value = xpBreakdown.fold(0, (sum, s) => sum + s.xp);
      xpThisWeek.value = xpToday.value * 7;

      // TODO: Replace with API data from _repo.getMilestones()
      milestones.value = [
        LevelMilestone(1, 'Newcomer', 'Join the party!', false, true),
        LevelMilestone(5, 'Socialite', 'Send 10 gifts', true, true),
        LevelMilestone(10, 'Party Star', 'Host 5 voice rooms', false, false),
        LevelMilestone(15, 'Influencer', 'Reach 100 followers', false, false),
        LevelMilestone(20, 'VIP Elite', 'Unlock VIP lounge', false, false),
        LevelMilestone(25, 'Legend', 'Top 1% of users', false, false),
      ];

      unlockedMilestones.value =
          milestones.where((m) => m.unlocked).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load level data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  double get progressPercent => currentXp.value / xpToNextLevel.value;

  String get levelTitle {
    if (currentLevel.value >= 25) return 'Legend';
    if (currentLevel.value >= 20) return 'VIP Elite';
    if (currentLevel.value >= 15) return 'Influencer';
    if (currentLevel.value >= 10) return 'Party Star';
    if (currentLevel.value >= 5) return 'Socialite';
    return 'Newcomer';
  }
}

class LevelMilestone {
  final int level;
  final String title;
  final String description;
  final bool unlocked;
  final bool rewardClaimed;
  final String? rewardIcon;

  LevelMilestone(
    this.level,
    this.title,
    this.description,
    this.unlocked,
    this.rewardClaimed, {
    this.rewardIcon,
  });
}

class XpSource {
  final String label;
  final int xp;
  final IconData icon;

  XpSource(this.label, this.xp, this.icon);
}