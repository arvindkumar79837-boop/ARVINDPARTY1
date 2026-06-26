import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/vip_system_model.dart';
import '../repositories/vip_system_repository.dart';

class VipSystemController extends GetxController {
  final VipSystemRepository _repository = VipSystemRepository();
  final _storage = GetStorage();

  // Observable state
  final vipStatus = Rxn<VipSystemStatus>();
  final isLoading = false.obs;
  final isPurchasing = false.obs;
  final errorMessage = ''.obs;

  // Collections
  final cosmetics = <CosmeticShopItem>[].obs;
  final vipMissions = <VipMission>[].obs;
  final shopItems = <CosmeticShopItem>[].obs;
  final leaderboardData = <Map<String, dynamic>>[].obs;
  final leaderboardLoading = false.obs;

  // Filters
  final selectedCosmeticType = RxString('all');
  final selectedShopCategory = RxString('all');

  // Premium
  final premiumMonths = 1.obs;
  final premiumDailyBonusClaimed = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVipStatus();
  }

  Future<void> fetchVipStatus() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = _storage.read('token') ?? '';
      if (token.isEmpty) {
        vipStatus.value = null;
        return;
      }
      final status = await _repository.getVipStatus();
      vipStatus.value = status;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ─── VIP XP ──────────────────────────────────────

  Future<void> addVipXP(int amount, {String source = 'bonus', String description = ''}) async {
    try {
      final result = await _repository.addVipXP(amount, source: source, description: description);
      if (result['success'] == true) {
        final data = result['data'];
        if (data['level_up'] == true) {
          Get.snackbar(
            '🎉 LEVEL UP!',
            'Welcome to VIP Level ${data['vip_level']}!',
            backgroundColor: Colors.amber,
            colorText: Colors.black,
            duration: const Duration(seconds: 3),
          );
        }
        await fetchVipStatus();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  // ─── PREMIUM ─────────────────────────────────────

  Future<void> purchasePremium(int months) async {
    isPurchasing.value = true;
    try {
      final result = await _repository.purchasePremium(months);
      if (result['success'] == true) {
        Get.snackbar(
          '✨ Premium Activated!',
          'Premium active for $months month(s)',
          backgroundColor: Colors.purple,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await fetchVipStatus();
      }
    } catch (e) {
      Get.snackbar('Purchase Failed', e.toString(), backgroundColor: Colors.red);
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> cancelAutoRenew() async {
    try {
      await _repository.cancelPremiumAutoRenew();
      Get.snackbar('Cancelled', 'Auto-renew cancelled', backgroundColor: Colors.orange);
      await fetchVipStatus();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<void> claimDailyBonus() async {
    try {
      final result = await _repository.claimPremiumDailyBonus();
      if (result['success'] == true) {
        premiumDailyBonusClaimed.value = true;
        Get.snackbar(
          '🎁 Daily Bonus!',
          '${result['data']['coins_added']} coins earned!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchVipStatus();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  // ─── COSMETICS ───────────────────────────────────

  Future<void> fetchCosmetics({String? itemType}) async {
    try {
      final items = await _repository.getAvailableCosmetics(itemType: itemType);
      cosmetics.value = items;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load cosmetics: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> purchaseCosmetic(String itemId) async {
    isPurchasing.value = true;
    try {
      final result = await _repository.purchaseCosmetic(itemId);
      if (result['success'] == true) {
        Get.snackbar(
          '🎉 Item Purchased!',
          result['message'] ?? 'Cosmetic unlocked!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchCosmetics();
        await fetchVipStatus();
      }
    } catch (e) {
      Get.snackbar('Purchase Failed', e.toString(), backgroundColor: Colors.red);
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> applyCosmetic(String itemId, String itemType, {bool apply = true}) async {
    try {
      final result = await _repository.applyCosmetic(itemId, itemType, apply: apply);
      if (result['success'] == true) {
        Get.snackbar(
          apply ? '✅ Applied' : '❌ Removed',
          result['message'] ?? 'Cosmetic updated',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        await fetchVipStatus();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  List<CosmeticShopItem> getFilteredCosmetics() {
    if (selectedCosmeticType.value == 'all') return cosmetics;
    return cosmetics.where((c) => c.itemType == selectedCosmeticType.value).toList();
  }

  // ─── MISSIONS ────────────────────────────────────

  Future<void> fetchMissions() async {
    try {
      final missions = await _repository.getVipMissions();
      vipMissions.value = missions;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load missions: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> updateMissionProgress(String missionId, double amount) async {
    try {
      final result = await _repository.updateMissionProgress(missionId, amount);
      if (result['success'] == true) {
        await fetchMissions();
      }
    } catch (e) {
      // Silently handle - this is usually auto-triggered
    }
  }

  Future<void> claimReward(String missionId) async {
    try {
      final result = await _repository.claimMissionReward(missionId);
      if (result['success'] == true) {
        Get.snackbar(
          '🎁 Reward Claimed!',
          result['message'] ?? 'Reward received!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchMissions();
        await fetchVipStatus();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  List<VipMission> get activeMissions =>
      vipMissions.where((m) => !m.isCompleted && !m.rewardClaimed).toList();

  List<VipMission> get completedMissions =>
      vipMissions.where((m) => m.isCompleted && !m.rewardClaimed).toList();

  // ─── VIP SHOP ────────────────────────────────────

  Future<void> fetchShopItems() async {
    try {
      final items = await _repository.getVIPShopItems();
      shopItems.value = items;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shop: $e', backgroundColor: Colors.red);
    }
  }

  List<CosmeticShopItem> getFilteredShopItems() {
    if (selectedShopCategory.value == 'all') return shopItems;
    return shopItems.where((item) => item.itemType == selectedShopCategory.value).toList();
  }

  // ─── VIP ENTRY ───────────────────────────────────

  Future<void> triggerVIPEntryEffect(String roomId) async {
    try {
      await _repository.triggerVIPEntry(roomId);
    } catch (e) {
      // Non-critical - entry effect may not be available
    }
  }

  // ─── LEADERBOARD ─────────────────────────────────

  Future<void> fetchLeaderboard({int limit = 50}) async {
    leaderboardLoading.value = true;
    try {
      final data = await _repository.getVIPLeaderboard(limit: limit);
      leaderboardData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load leaderboard: $e', backgroundColor: Colors.red);
    } finally {
      leaderboardLoading.value = false;
    }
  }

  // ─── HELPERS ─────────────────────────────────────

  bool canAccessVIPFeature(int requiredLevel) {
    final status = vipStatus.value;
    if (status == null) return false;
    if (status.isSvip) return true;
    return status.vipLevel >= requiredLevel;
  }

  bool get isPremiumActive => vipStatus.value?.isPremium ?? false;

  bool get isSVIPActive => vipStatus.value?.isSvip ?? false;

  int get currentVIPLevel => vipStatus.value?.vipLevel ?? 0;

  int get currentSVIPLevel => vipStatus.value?.svipLevel ?? 0;
}